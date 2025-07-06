import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class PressedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PressedButton({
    super.key,
    this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<PressedButton> createState() => PressedStateButton();
}

class PressedStateButton extends State<PressedButton>
    with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 0.9).animate(_controller),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ElevatedButton(
            onPressed: _onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.backgroundColor ?? Colors.white.safeOpacity(0.2),
              foregroundColor: widget.foregroundColor ?? Colors.white70,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
