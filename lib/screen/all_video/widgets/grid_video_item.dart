import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../data/model/video/video.dart';

class GridVideoItem extends StatelessWidget {
  const GridVideoItem({
    super.key,
    required this.video,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  final Video video;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.file(
              File(video.getThumbnailPath),
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                return frame == null
                    ? Shimmer.fromColors(
                        direction: ShimmerDirection.ltr,
                        baseColor: Colors.white24,
                        highlightColor: Colors.white30,
                        child: Container(
                          color: Colors.white24,
                        ),
                      )
                    : child;
              },
              errorBuilder: (context, error, stackTrace) {
                return Shimmer.fromColors(
                  direction: ShimmerDirection.ltr,
                  baseColor: Colors.white24,
                  highlightColor: Colors.white30,
                  child: Container(
                    color: Colors.white24,
                  ),
                );
              },
              fit: BoxFit.cover,
            ),
          ),
          if (selected)
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.3),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
