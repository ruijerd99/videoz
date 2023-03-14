import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videoz/data/injector.dart';
import 'package:videoz/data/model/video/video.dart';
import 'package:videoz/data/repository/video/video_repository.dart';

part 'video_event.dart';
part 'video_state.dart';

class AllVideoBloc extends Bloc<VideoEvent, VideoState> {
  AllVideoBloc() : super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
  }

  FutureOr<void> _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    final videos = await getIt<VideoRepository>().getAllVideos();
    emit(VideoLoaded(videos));
  }

  
}
