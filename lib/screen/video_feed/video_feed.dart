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

  VideoPlayerController? _nextVideoController;
  VideoPlayerController? _previousVideoController;

  var _currentIndex = 0;
  var _previousIndex = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;

    _pageController.addListener(() {
      if (_currentIndex - 1 < _pageController.page! &&
          _currentIndex + 1 > _pageController.page!) {
        return;
      }

      // complete new page
      _previousIndex = _currentIndex;
      _currentIndex = _pageController.page!.toInt();
      if (_currentIndex < _previousIndex) {
        _previousVideoController?.play();
        print('play previous: $_currentIndex');
      } else if (_currentIndex > _previousIndex) {
        _nextVideoController?.play();
        print('play next: $_currentIndex');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.videos.length,
        scrollDirection: Axis.vertical,
        onPageChanged: (value) {
          print('onPageChanged: $value');
        },
        itemBuilder: (context, index) {
          final video = widget.videos[index];

          return VideoPlayerItem(
            video: video,
            onControllerInitialized: (controller) {
              if (index < _currentIndex) {
                _previousVideoController = controller;
                print('previous: $index');
              } else if (index > _currentIndex) {
                _nextVideoController = controller;
                print('next: $index');
              }

              if (index == _currentIndex) {
                controller.play();
              }
            },
            loop: true,
          );
        },
      ),
    );
  }
}
