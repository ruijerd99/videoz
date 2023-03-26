part of 'video_player_cubit.dart';

abstract class VideoPlayerState extends Equatable {
  const VideoPlayerState();

  @override
  List<Object> get props => [];
}

class VideoPlayerInitial extends VideoPlayerState {}

class VideoPlayerInitilized extends VideoPlayerState {}
