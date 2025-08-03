import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class MessButton extends StatelessWidget {
  const MessButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => AppNavigator.push(context, '/conversation'),
          style: IconButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.sm,
              vertical: AppDimensions.sm,
            ),
            backgroundColor: Colors.white.safeOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            ),
          ),
          icon: const Icon(
            Icons.cloud_outlined,
            size: AppDimensions.iconLg,
            color: Colors.white70,
          ),
        ),
        Positioned(
          top: -16,
          right: -2,
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.sm),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '1',
              style: AppTypography.bodyLarge.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
