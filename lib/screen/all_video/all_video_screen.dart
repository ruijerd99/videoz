import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../data/model/video/video.dart';
import 'bloc/video_bloc.dart';
import 'widgets/grid_video_item.dart';

class AllVideoScreen extends StatefulWidget {
  const AllVideoScreen({super.key});

  @override
  State<AllVideoScreen> createState() => _AllVideoScreenState();
}

class _AllVideoScreenState extends State<AllVideoScreen> {
  final _videoBloc = AllVideoBloc();
  bool _selectionMode = false;
  List<Video> _selectedVideos = [];

  @override
  void initState() {
    super.initState();
    _videoBloc.add(LoadVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectionMode ? Text('${_selectedVideos.length} selected') : const Text('#videoz'),
        centerTitle: true,
        actions: [
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                // Delete selected videos
                // TODO: Implement delete functionality
                setState(() {
                  _selectionMode = false;
                  _selectedVideos.clear();
                });
              },
            ),
        ],
      ),
      body: BlocBuilder<AllVideoBloc, VideoState>(
        bloc: _videoBloc,
        builder: (context, state) {
          if (state is VideoInitial) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
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
          } else if (state is VideoLoaded) {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: state.videos.length,
              itemBuilder: (context, index) {
                final video = state.videos[index];
                return GridVideoItem(
                  video: video,
                  selected: _selectedVideos.contains(video),
                  onTap: () {
                    if (_selectionMode) {
                      setState(() {
                        if (_selectedVideos.contains(video)) {
                          _selectedVideos.remove(video);
                          if (_selectedVideos.isEmpty) {
                            _selectionMode = false;
                          }
                        } else {
                          _selectedVideos.add(video);
                        }
                      });
                    } else {
                      // TODO: Implement video playback
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      _selectionMode = true;
                      _selectedVideos.add(video);
                    });
                  },
                );
              },
            );
          } else {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
        },
      ),
    );
  }
}
