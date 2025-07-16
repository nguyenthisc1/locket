import 'package:flutter/material.dart';

class FadeSlideAnimationController {
  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;

  late AnimationController controller;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  FadeSlideAnimationController({
    required this.vsync,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) {
    controller = AnimationController(vsync: vsync, duration: duration);
  }

  void configure({required Offset beginOffset}) {
    fadeAnimation = CurvedAnimation(parent: controller, curve: curve);

    slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: curve));
  }

  void fadeIn() => controller.forward();
  void fadeOut() => controller.reverse();
  void dispose() => controller.dispose();
}
