import 'package:flutter/material.dart';
import 'package:videoz/screen/video_feed/widgets/video_player_item.dart';

import '../../data/injector.dart';
import '../../data/model/video/video.dart';
import '../../data/repository/video/video_repository.dart';
import '../../widgets/faster_page_view_scroll_physics.dart';

class VideoFeed extends StatefulWidget {
  const VideoFeed({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    this.useHero = true,
    this.onRefresh,
  });

  final List<Video> videos;
  final int initialIndex;
  final bool useHero;
  final Function(VoidCallback onInvoke)? onRefresh;

  @override
  State<VideoFeed> createState() => _VideoFeedState();
}

class _VideoFeedState extends State<VideoFeed> {
  late final PageController _pageController;

  List<Video> _videos = [];

  // queue controller to dispose

  var _useHero = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    _useHero = widget.useHero;

    _videos = widget.videos;

    widget.onRefresh?.call(() async {
      _videos = await getIt<VideoRepository>().getAllVideos();
      setState(() {
        _videos.shuffle();

        _pageController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
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
        key: UniqueKey(),
        controller: _pageController,
        itemCount: _videos.length,
        scrollDirection: Axis.vertical,
        physics: const FasterPageViewScrollPhysics(),
        itemBuilder: (context, index) {
          final video = _videos[index];

          return VideoPlayerItem(
            key: ValueKey(video.id),
            video: video,
            index: index,
            useHero: _useHero,
            onVideoEnded: () {
              if (index == _videos.length - 1) {
                return;
              }

              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            },
          );
        },
      ),
    );
  }
}
