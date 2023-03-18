part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object> get props => [];
}

class LoadVideos extends VideoEvent {}

class SelectVideo extends VideoEvent {
  final Video video;

  const SelectVideo(this.video);

  @override
  List<Object> get props => [video];
}

class DeselectVideo extends VideoEvent {
  final Video video;

  const DeselectVideo(this.video);

  @override
  List<Object> get props => [video];
}

class DeleteVideos extends VideoEvent {
  final List<Video> videos;

  const DeleteVideos(this.videos);

  @override
  List<Object> get props => [videos];
}

class ExitSelectionMode extends VideoEvent {}
