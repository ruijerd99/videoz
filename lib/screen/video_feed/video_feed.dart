import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:videoz/screen/video_feed/widgets/video_player_item.dart';

import '../../data/model/video/video.dart';

class VideoFeed extends StatefulWidget {
  const VideoFeed({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  final List<Video> videos;
  final int initialIndex;

  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  late final PageController _pageController;

  final Map<int, VideoPlayerController> _controllers = {};

  var _currentIndex = 0;
  var _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _pageController = PageController(initialPage: _currentIndex);

    _pageController.addListener(() {
      if (_currentIndex - 1 < _pageController.page! &&
          _currentIndex + 1 > _pageController.page!) {
        return;
      }

      _previousIndex = _currentIndex;
      _currentIndex = _pageController.page!.round();

      // print("=== reset video ${widget.videos[_previousIndex].id}");
      _controllers[widget.videos[_previousIndex].id]?.pause();
      _controllers[widget.videos[_previousIndex].id]?.seekTo(Duration.zero);

      // print("=== play video ${widget.videos[_currentIndex].id}");
      _controllers[widget.videos[_currentIndex].id]?.play();

      // dispose all controllers except n, n-1, n+1
      print("=== dispose video ${widget.videos[_currentIndex - 2].id}");
      print("=== dispose video ${widget.videos[_currentIndex + 2].id}");
      _controllers[widget.videos[_currentIndex - 2].id]?.dispose();
      _controllers[widget.videos[_currentIndex + 2].id]?.dispose();
      _controllers.remove(widget.videos[_currentIndex - 2].id);
      _controllers.remove(widget.videos[_currentIndex + 2].id);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.videos.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final video = widget.videos[index];
          // check if controller is not created yet
          final controller = _controllers.putIfAbsent(video.id, () {
            return VideoPlayerController.file(File(video.getPath));
          });

          if (_currentIndex == index) {
            controller.play();
          }

          return VideoPlayerItem(
            video: video,
            controller: controller,
          );
        },
      ),
    );
  }
}
