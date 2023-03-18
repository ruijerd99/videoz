import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/model/video/video.dart';
import 'custom_video_progress_indicator.dart';

class VideoPlayerItem extends StatefulWidget {
  final Video video;
  final VideoPlayerController controller;

  const VideoPlayerItem({
    Key? key,
    required this.video,
    required this.controller,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    if (widget.controller.value.isInitialized) {
      return;
    }
    // print("=== initialize video ${video.id}");
    await widget.controller.initialize();
    await widget.controller.setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.controller.value.isPlaying) {
          widget.controller.pause();
          _iconAnimationController.forward();
        } else {
          widget.controller.play();
          _iconAnimationController.reverse();
        }
      },
      onHorizontalDragEnd: (details) => Navigator.of(context).pop(),
      child: Scaffold(
        body: GestureDetector(
          onTap: () {
            if (widget.controller.value.isPlaying) {
              widget.controller.pause();
              _iconAnimationController.forward();
            } else {
              widget.controller.play();
              _iconAnimationController.reverse();
            }
          },
          onHorizontalDragEnd: (details) {
            // catch only left to right and distance long enough
            // print("=== ${details.primaryVelocity}");
            if (details.primaryVelocity! > 300) {
              Navigator.of(context).pop();
            }
          },
          child: Hero(
            tag: widget.video.id,
            child: Center(
              child: FutureBuilder(
                future: _initializeVideoPlayer(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Image.file(File(widget.video.getThumbnailPath));
                  }
          
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AspectRatio(
                            aspectRatio: widget.controller.value.aspectRatio,
                            child: VideoPlayer(widget.controller),
                          ),
                          FadeTransition(
                            opacity: _iconAnimation,
                            child: MyProgressIndicator(
                              widget.controller,
                            ),
                          ),
                        ],
                      ),
                      FadeTransition(
                        opacity: _iconAnimation,
                        child: AnimatedIcon(
                          icon: AnimatedIcons.pause_play,
                          progress: _iconAnimation,
                          size: 100,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
