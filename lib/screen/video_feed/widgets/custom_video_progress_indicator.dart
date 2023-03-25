import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MyProgressIndicator extends StatefulWidget {
  final VideoPlayerController controller;

  const MyProgressIndicator(this.controller, {super.key});

  @override
  State<MyProgressIndicator> createState() => _MyProgressIndicatorState();
}

class _MyProgressIndicatorState extends State<MyProgressIndicator> {
  _MyProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  late VoidCallback listener;

  VideoPlayerController get controller => widget.controller;

  final _bufferedColor = Colors.white60;
  final _playedColor = Colors.white;
  final _backgroundColor = Colors.white10;
  final _minHeight = 1.5;

  @override
  void initState() {
    super.initState();
    controller.addListener(listener);
  }

  @override
  void dispose() {
    controller.removeListener(listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget progressIndicator;
    if (controller.value.isInitialized) {
      final int duration = controller.value.duration.inMilliseconds;
      final int position = controller.value.position.inMilliseconds;

      int maxBuffering = 0;
      for (final DurationRange range in controller.value.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }

      progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[

          LinearProgressIndicator(
            value: maxBuffering / duration,
            valueColor: AlwaysStoppedAnimation<Color>(_bufferedColor),
            backgroundColor: _backgroundColor,
            minHeight: _minHeight,
          ),
          LinearProgressIndicator(
            value: position / duration,
            valueColor: AlwaysStoppedAnimation<Color>(_playedColor),
            backgroundColor: _backgroundColor,
            minHeight: _minHeight,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_playedColor),
        backgroundColor: _backgroundColor,
        minHeight: _minHeight,
      );
    }

    return progressIndicator;
  }
}
