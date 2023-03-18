import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../data/model/video/video.dart';

class VideoPlayerItem extends StatefulWidget {
  final Video video;
  final Function(VideoPlayerController) onControllerInitialized;
  final bool loop;

  const VideoPlayerItem({
    Key? key,
    required this.video,
    required this.onControllerInitialized,
    this.loop = false,
  }) : super(key: key);

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.video.getPath))
      ..initialize().then((_) {
        setState(() {});
        widget.onControllerInitialized(_controller);
      })
      ..setLooping(widget.loop);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(
            _controller,
          ),
        ),
      ),
    );
  }
}
