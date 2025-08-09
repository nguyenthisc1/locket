import 'package:flutter/material.dart';

class RatioClip extends StatelessWidget {
  final double radiusRatio; 
  final Widget child;

  const RatioClip({required this.radiusRatio, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final minSide = constraints.biggest.shortestSide;
        return ClipRRect(
          borderRadius: BorderRadius.circular(minSide * radiusRatio),
          child: child,
        );
      },
    );
  }
}
