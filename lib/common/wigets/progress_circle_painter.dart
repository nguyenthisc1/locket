import 'dart:math' as math;

import 'package:flutter/material.dart';

class ProgressCirclePainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;
  final double strokeWidth;

  ProgressCirclePainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.width / 2 - strokeWidth / 2;

    final Paint baseCircle =
        Paint()
          ..color = color.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final Paint progressCircle =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawCircle(center, radius, baseCircle);

    // Draw progress arc
    double startAngle = -math.pi / 2; // top
    double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressCircle,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressCirclePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
