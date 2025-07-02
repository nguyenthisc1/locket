import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';

class BuildIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? color;
  final double? size;

  const BuildIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: color ?? Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
      ),
      icon: Icon(icon, color: Colors.white, size: size ?? AppDimensions.xxl),
    );
  }
}
