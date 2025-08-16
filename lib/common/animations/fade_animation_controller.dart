import 'package:flutter/material.dart';

class FadeAnimationController {
  late final AnimationController controller;
  late final Animation<double> animation;
  bool _isDisposed = false;

  FadeAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);

    controller.value = 1;
    animation = CurvedAnimation(parent: controller, curve: curve);
  }

  void fadeIn() {
    if (!_isDisposed) {
      controller.forward();
    }
  }

  void fadeOut() {
    if (!_isDisposed) {
      controller.reverse();
    }
  }

  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      controller.dispose();
    }
  }

  bool get isDisposed => _isDisposed;
}
