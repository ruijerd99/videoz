import 'package:flutter/material.dart';

import '../all_video/all_video_screen.dart';
import 'cubit/video_import_cubit.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final _screen = <Widget>[
    const AllVideoScreen(),
    const Center(
      child: Text('Playlists'),
    ),
  ];

  var _currentIndex = 0;

  final _videoImportCubit = VideoImportCubit();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: _screen
            .asMap()
            .map((i, screen) => MapEntry(
                  i,
                  Offstage(
                    offstage: _currentIndex != i,
                    child: screen,
                  ),
                ))
            .values
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _videoImportCubit.addVideosButtonPressed(context);
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection_outlined),
            activeIcon: Icon(Icons.video_collection_rounded),
            label: 'Videos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tag_outlined),
            activeIcon: Icon(Icons.tag_rounded),
            label: 'Playlists',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
