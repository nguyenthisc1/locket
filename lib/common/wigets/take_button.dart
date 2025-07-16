import 'package:flutter/material.dart';
import 'package:locket/common/wigets/progress_circle_painter.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';

class TakeButton extends StatelessWidget {
  final double size;
  final bool? isSizeSync;
  final Duration animationDuration;
  final Animation<double>? progress;

  const TakeButton({
    super.key,
    required this.size,
    this.animationDuration = const Duration(
      milliseconds: AppDimensions.durationFast,
    ),
    this.isSizeSync = true,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // BORDER OUTSIZE
        Positioned(
          top: -8,
          left: -8,
          right: -8,
          bottom: -8,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: AppDimensions.xs,
              ),
            ),
          ),
        ),

        // BORDER PROGRESS WHEN RECORD VIDEO
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          child: CustomPaint(
            painter: ProgressCirclePainter(
              progress: progress?.value ?? 0.0,
              color: Colors.white,
            ),
          ),
        ),

        SizedBox(
          width: isSizeSync ?? true ? size : AppDimensions.xxl * 2,
          height: isSizeSync ?? true ? size : AppDimensions.xxl * 2,
          child: Center(
            child: AnimatedContainer(
              duration: animationDuration,
              curve: Curves.easeInOut,
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
