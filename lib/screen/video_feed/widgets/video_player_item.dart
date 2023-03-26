import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:videoz/screen/video_feed/cubit/video_player_cubit.dart';
import 'package:videoz/screen/video_feed/dispose_video_controller_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../data/model/video/video.dart';
import '../../../main.dart';
import 'custom_video_progress_indicator.dart';

class VideoPlayerItem extends StatefulWidget {
  final Video video;

  final int index;
  final bool useHero;
  final VoidCallback onVideoEnded;

  const VideoPlayerItem({
    Key? key,
    required this.video,
    required this.index,
    this.useHero = true,
    required this.onVideoEnded,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconAnimationController;
  late final Animation<double> _iconAnimation;
  late VideoPlayerController _controller;
  final _videoPlayerCubit = VideoPlayerCubit();

  var isVideoEnded = false;

  void _onVideoEnded() {
    var value = _controller.value;
    if (!value.isInitialized) return;

    if (value.isLooping) return;

    if (value.position == value.duration && !isVideoEnded) {
      isVideoEnded = true;
      widget.onVideoEnded();
    }
  }

  void updateVideoConfig() {
    _controller.setLooping(isLoop.value);
  }

  @override
  void initState() {
    super.initState();

    VisibilityDetectorController.instance.updateInterval = const Duration(
      milliseconds: 10,
    );

    _controller = VideoPlayerController.file(File(widget.video.getPath));

    updateVideoConfig();

    _videoPlayerCubit
        .initialize(_controller)
        .then((_) => _controller.addListener(_onVideoEnded));

    isLoop.addListener(updateVideoConfig);

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      _iconAnimationController,
    );
  }

  @override
  void dispose() {
    _controller.pause();
    _iconAnimationController.dispose();
    _controller.removeListener(_onVideoEnded);
    isLoop.removeListener(updateVideoConfig);
    DisposeVideoControllerService().addController(_controller);
    // _controller.dispose();
    super.dispose();
  }

  BoxFit selectBoxFit({
    required double videoWidth,
    required double videoHeight,
    required double deviceWidth,
    required double deviceHeight,
  }) {
    final videoRatio = videoWidth / videoHeight;
    final deviceRatio = deviceWidth / deviceHeight;

    final dif = (videoRatio - deviceRatio).abs();

    // print("=== videoRatio: $videoRatio, deviceRatio: $deviceRatio, dif: $dif");

    if (videoRatio >= 0.6) {
      return BoxFit.contain;
    }

    if (dif > 1) {
      return BoxFit.contain;
    }

    return BoxFit.cover;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = widget.useHero
        ? kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom
        : 0.0;

    var fit = selectBoxFit(
      videoWidth: widget.video.width,
      videoHeight: widget.video.height,
      deviceWidth: MediaQuery.of(context).size.width,
      deviceHeight: MediaQuery.of(context).size.height - bottomPadding,
    );

    if (widget.useHero) {
      fit = BoxFit.contain;
    }

    final thumbnail = Image.file(
      File(widget.video.getThumbnailPath),
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return frame == null
            ? Shimmer.fromColors(
                direction: ShimmerDirection.ltr,
                baseColor: Colors.white24,
                highlightColor: Colors.white30,
                child: Container(
                  color: Colors.white24,
                ),
              )
            : child;
      },
      errorBuilder: (context, error, stackTrace) {
        return Shimmer.fromColors(
          direction: ShimmerDirection.ltr,
          baseColor: Colors.white24,
          highlightColor: Colors.white30,
          child: Container(
            color: Colors.white24,
          ),
        );
      },
    );

    return VisibilityDetector(
      key: ValueKey(widget.video.id),
      onVisibilityChanged: (VisibilityInfo info) {
        if (mounted == false) return;

        if (info.visibleFraction == 0 && _controller.value.isPlaying == true) {
          print('=== pause ${widget.video.id} ${widget.index}');

          _controller.pause();
          _iconAnimationController.forward();
        } else if (info.visibleFraction == 1 &&
            _controller.value.isPlaying == false) {
          print('=== play ${widget.video.id} ${widget.index}');
          _controller.play();
          _iconAnimationController.reverse();
        }
      },
      child: GestureDetector(
        onTap: () {
          if (_controller.value.isPlaying == true) {
            _controller.pause();
            _iconAnimationController.forward();
          } else {
            _controller.play();
            _iconAnimationController.reverse();
          }
        },
        onHorizontalDragEnd: (details) {
          // catch only left to right and distance long enough
          // print("=== ${details.primaryVelocity}");
          if (details.primaryVelocity! > 300 && widget.useHero) {
            print("=== pop ${widget.index}");
            _controller.pause();
            Navigator.of(context).pop(widget.index);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: ClipRect(
                  child: FittedBox(
                    fit: fit,
                    child: widget.useHero
                        ? Hero(
                            tag: widget.video.id,
                            child: thumbnail,
                          )
                        : thumbnail,
                  ),
                ),
              ),
              BlocBuilder<VideoPlayerCubit, VideoPlayerState>(
                bloc: _videoPlayerCubit,
                builder: (context, state) {
                  if (state is VideoPlayerInitilized) {
                    return SizedBox.expand(
                      child: ClipRect(
                        child: FittedBox(
                          fit: fit,
                          child: SizedBox(
                            width: _controller.value.size.width,
                            height: _controller.value.size.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              FadeTransition(
                opacity: _iconAnimation,
                child: AnimatedIcon(
                  icon: AnimatedIcons.pause_play,
                  progress: _iconAnimation,
                  size: 100,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _iconAnimation,
                    child: MyProgressIndicator(
                      _controller,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
