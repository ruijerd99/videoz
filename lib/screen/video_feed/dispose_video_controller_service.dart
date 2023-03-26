import 'dart:async';
import 'dart:collection';

import 'package:video_player/video_player.dart';

class DisposeVideoControllerService {
  static DisposeVideoControllerService? _instance;

  factory DisposeVideoControllerService() {
    _instance ??= DisposeVideoControllerService._();

    return _instance!;
  }

  DisposeVideoControllerService._();

  var controllerQueue = Queue<VideoPlayerController>();

  Timer? _timer;

  void addController(VideoPlayerController controller) {
    controllerQueue.add(controller);

    if (_instance!._timer == null) {
      _instance!._timer = Timer.periodic(
        const Duration(seconds: 2),
        (timer) {
          if (controllerQueue.isNotEmpty) {
            final controller = controllerQueue.removeFirst();
            print('=== dispose controller ===');
            controller.dispose();
          } else {
            timer.cancel();
            _instance!._timer = null;
          }
        },
      );
    }
  }
}
