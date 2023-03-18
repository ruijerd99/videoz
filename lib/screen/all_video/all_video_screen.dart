import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../video_feed/video_feed.dart';
import 'bloc/video_bloc.dart';
import 'widgets/grid_video_item.dart';

class AllVideoScreen extends StatefulWidget {
  const AllVideoScreen({super.key});

  @override
  State<AllVideoScreen> createState() => _AllVideoScreenState();
}

class _AllVideoScreenState extends State<AllVideoScreen> {
  late final AllVideoBloc _videoBloc;

  @override
  void initState() {
    super.initState();
    _videoBloc = AllVideoBloc()..add(LoadVideos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<AllVideoBloc, VideoState>(
          bloc: _videoBloc,
          buildWhen: (previous, current) {
            if (current is VideoLoaded && previous is VideoLoaded) {
              return previous.selectedVideos != current.selectedVideos;
            }
            return false;
          },
          builder: (context, state) {
            if (state is VideoLoaded) {
              final selectedVideos = state.selectedVideos;
              if (state.selectionMode()) {
                return Text('${selectedVideos.length} selected');
              }
            }
            return const Text('#videoz');
          },
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<AllVideoBloc, VideoState>(
            bloc: _videoBloc,
            buildWhen: (previous, current) {
              if (current is VideoLoaded && previous is VideoLoaded) {
                return previous.selectedVideos != current.selectedVideos;
              }
              return false;
            },
            builder: (context, state) {
              if (state is VideoLoaded) {
                final selectedVideos = state.selectedVideos;
                if (selectedVideos.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _videoBloc.add(DeleteVideos(selectedVideos));
                    },
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AllVideoBloc, VideoState>(
        bloc: _videoBloc,
        builder: (context, state) {
          if (state is VideoInitial) {
            return _buildShimmerGridView();
          } else if (state is VideoLoaded) {
            return _buildVideoGridView(state);
          } else {
            return const Center(
              child: Text('Something went wrong'),
            );
          }
        },
      ),
    );
  }

  Widget _buildShimmerGridView() {
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
  }

  Widget _buildVideoGridView(VideoLoaded state) {
    final videos = state.videos;
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return GridVideoItem(
          video: video,
          selected: state.isSelected(video),
          onTap: () {
            if (state.selectionMode()) {
              _videoBloc.add(
                state.isSelected(video)
                    ? DeselectVideo(video)
                    : SelectVideo(video),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoFeed(
                    videos: videos,
                    initialIndex: index,
                  ),
                ),
              );
            }
          },
          onLongPress: () {
            _videoBloc.add(SelectVideo(video));
          },
        );
      },
    );
  }
}
