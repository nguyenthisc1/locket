import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class MessButton extends StatelessWidget {
  const MessButton({super.key});

  void _showMessBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Messages', style: AppTypography.bodyLarge),
              const SizedBox(height: 16),
              // Add your message list content here
              const Expanded(
                child: Center(
                  child: Text('Message list will be displayed here'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () => _showMessBottomSheet(context),
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
