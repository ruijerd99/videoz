part of 'video_bloc.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoaded extends VideoState {
  final List<Video> videos;
  final List<Video> selectedVideos;

  const VideoLoaded(
    this.videos, [
    this.selectedVideos = const [],
  ]);

  @override
  List<Object> get props => [videos, selectedVideos];

  bool isSelected(Video video) => selectedVideos.contains(video);
  bool selectionMode() => selectedVideos.isNotEmpty;
}
