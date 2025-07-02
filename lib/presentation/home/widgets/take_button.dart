import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_colors.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';

class TakeButton extends StatelessWidget {
  final double size;

  const TakeButton({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
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
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}
