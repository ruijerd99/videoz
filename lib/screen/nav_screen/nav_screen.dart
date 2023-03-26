import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:videoz/screen/video_feed/video_feed.dart';

import '../../data/model/video/video.dart';
import '../all_video/all_video_screen.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key, required this.videos});
  final List<Video> videos;

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  late final List<Widget> _screen;

  var _currentIndex = 0;
  bool isRefresh = false;

  Function onRefresh = () {};

  @override
  void initState() {
    super.initState();
    _screen = [
      VideoFeed(
        videos: widget.videos,
        useHero: false,
        onRefresh: (onInvoke) {
          onRefresh = onInvoke;
        },
      ),
      const AllVideoScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screen,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 0,
            thickness: 1,
            color: Colors.white10,
          ),
          SizedBox(
            height: kBottomNavigationBarHeight +
                MediaQuery.of(context).padding.bottom,
            child: BottomNavigationBar(
              backgroundColor: Colors.black,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.house),
                  label: 'Videos',
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(FontAwesomeIcons.hashtag),
                  label: 'Playlists',
                ),
              ],
              currentIndex: _currentIndex,
              onTap: (index) async {
                if (_currentIndex == 0 && index == 0 && !isRefresh) {
                  isRefresh = true;
                  await onRefresh();
                  isRefresh = false;
                } else {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
