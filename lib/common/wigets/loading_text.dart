import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';

class LoadingText extends StatelessWidget {
  final String text;
  final Color? background;

  const LoadingText({super.key, required this.text, this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background ?? Colors.white,
      padding: const EdgeInsets.all(AppDimensions.xs),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.dark,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
