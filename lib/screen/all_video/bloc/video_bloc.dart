import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:videoz/data/injector.dart';
import 'package:videoz/data/model/video/video.dart';
import 'package:videoz/data/repository/video/video_repository.dart';
import 'package:videoz/utils/common_func.dart';

part 'video_event.dart';
part 'video_state.dart';

class AllVideoBloc extends Bloc<VideoEvent, VideoState> {
  StreamSubscription<void>? _videoSubscription;

  AllVideoBloc() : super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<SelectVideo>(_onSelectVideo);
    on<DeselectVideo>(_onDeselectVideo);
    on<DeleteVideos>(_onDeleteVideos);

    _videoSubscription = getIt<VideoRepository>().watchVideos().listen((videos) {
      add(LoadVideos());
    });
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    final videos = await getIt<VideoRepository>().getAllVideos();

    emit(VideoLoaded(videos));
  }

  void _onSelectVideo(SelectVideo event, Emitter<VideoState> emit) {
    final currentState = state as VideoLoaded;
    if (!currentState.isSelected(event.video)) {
      final selectedVideos = [...currentState.selectedVideos, event.video];

      emit(VideoLoaded(currentState.videos, selectedVideos));
    }
  }

  void _onDeselectVideo(DeselectVideo event, Emitter<VideoState> emit) {
    final currentState = state as VideoLoaded;
    if (currentState.isSelected(event.video)) {
      final selectedVideos = List.of(currentState.selectedVideos)..remove(event.video);

      emit(VideoLoaded(currentState.videos, selectedVideos));
    }
  }

  Future<void> _onDeleteVideos(DeleteVideos event, Emitter<VideoState> emit) async {
    showLoading();
    var deletes = await getIt<VideoRepository>().deleteVideos(event.videos);
    hideLoading();

    if (deletes == 0) {
      BotToast.showText(text: 'Failed to delete videos');
    } else {
      BotToast.showText(text: 'Deleted $deletes videos');
    }

    final videos = await getIt<VideoRepository>().getAllVideos();

    emit(VideoLoaded(videos));
  }

  @override
  Future<void> close() {
    _videoSubscription?.cancel();
    return super.close();
  }
}
