import 'package:flutter/material.dart';

class FadeAnimationController {
  late final AnimationController controller;
  late final Animation<double> animation;

  FadeAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);

    controller.value = 1;
    animation = CurvedAnimation(parent: controller, curve: curve);
  }

  void fadeIn() => controller.forward();

  void fadeOut() => controller.reverse();

  void dispose() => controller.dispose();
}
