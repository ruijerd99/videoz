import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:videoz/screen/nav_screen/cubit/video_import_cubit.dart';

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
  late final VideoImportCubit _videoImportCubit;
  late final ScrollController _scrollController;
  final gridViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _videoBloc = AllVideoBloc()..add(LoadVideos());
    _videoImportCubit = VideoImportCubit();
    _scrollController = ScrollController();
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
            return const Text('#toptop');
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
        leading: BlocBuilder<AllVideoBloc, VideoState>(
          bloc: _videoBloc,
          buildWhen: (previous, current) {
            if (current is VideoLoaded && previous is VideoLoaded) {
              return previous.selectionMode() != current.selectionMode();
            }
            return false;
          },
          builder: (context, state) {
            if (state is VideoLoaded) {
              if (state.selectionMode()) {
                return IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _videoBloc.add(ExitSelectionMode());
                  },
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _videoImportCubit.addVideosButtonPressed(context);
        },
        child: const Icon(Icons.add),
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

    return Builder(builder: (context) {
      return GridView.builder(
        key: gridViewKey,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        controller: _scrollController,
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
                Navigator.of(context)
                    .push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, _) {
                      return VideoFeed(
                        videos: videos,
                        initialIndex: index,
                      );
                    },
                    transitionsBuilder: (context, animation, _, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                )
                    .then((popIndex) {
                  if (popIndex != null) {
                    final gridItemHeight =
                        MediaQuery.of(context).size.width / 3;
                    final gridViewHeight =
                        gridViewKey.currentContext!.size!.height;

                    // calculate position of pop video, positon is top of gridview
                    final newPos = popIndex ~/ 3 * gridItemHeight;

                    // if new position is out view of grid view then scroll to new position
                    if (newPos + gridItemHeight >
                            _scrollController.offset + gridViewHeight ||
                        newPos < _scrollController.offset) {
                      // calculate new position that on bottom of grid view
                      var transformPos =
                          newPos - gridViewHeight + gridItemHeight;
                      if (transformPos < 0) {
                        _scrollController.jumpTo(0);
                        return;
                      }

                      _scrollController.jumpTo(transformPos);
                    }
                  }
                });
              }
            },
            onLongPress: () {
              _videoBloc.add(SelectVideo(video));
            },
          );
        },
      );
    });
  }
}
