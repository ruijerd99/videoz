import 'package:flutter/material.dart';

class FasterPageViewScrollPhysics extends ScrollPhysics {
  const FasterPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  FasterPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FasterPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 0.8,
      );
}