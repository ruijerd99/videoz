import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../data/model/video/video.dart';
import 'custom_video_progress_indicator.dart';

class VideoPlayerItem extends StatefulWidget {
  final Video video;

  final int index;
  final bool useHero;

  const VideoPlayerItem({
    Key? key,
    required this.video,
    required this.index,
    this.useHero = true,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconAnimationController;
  late final Animation<double> _iconAnimation;
  late VideoPlayerController _controller;

  _initController() async {
    await _controller.initialize();
    await _controller.setLooping(true);
  }

  @override
  void initState() {
    super.initState();
    VisibilityDetectorController.instance.updateInterval = const Duration(milliseconds: 100);
    _controller = VideoPlayerController.file(File(widget.video.getPath));

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
    _iconAnimationController.dispose();
    _controller.dispose();
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

    final fit = selectBoxFit(
      videoWidth: widget.video.width,
      videoHeight: widget.video.height,
      deviceWidth: MediaQuery.of(context).size.width,
      deviceHeight: MediaQuery.of(context).size.height - bottomPadding,
    );

    return VisibilityDetector(
      key: Key(widget.video.id.toString()),
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction == 0 && _controller.value.isPlaying == true) {
          print('=== pause ${widget.video.id} ${widget.index}');

          if (mounted) {
            _controller.pause();
            _iconAnimationController.forward();
          }
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
                            child: Image.file(
                              File(widget.video.getThumbnailPath),
                            ),
                          )
                        : Image.file(
                            File(widget.video.getThumbnailPath),
                          ),
                  ),
                ),
              ),
              FutureBuilder(
                future: _initController(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink();
                  }

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
