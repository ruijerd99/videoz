import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/model/video/video.dart';

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

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // reset video player
    _controller.pause();
    _controller.seekTo(Duration.zero);
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = widget.controller;
    if (_controller.value.isInitialized) {
      return;
    }
    print("=== initialize video player");
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        },
        child: Center(
          child: FutureBuilder(
            future: _initializeVideoPlayer(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Image.file(File(widget.video.getThumbnailPath));
              }

              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              );
            },
          ),
        ),
      ),
    );
  }
}
