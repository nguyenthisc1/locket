import 'package:flutter/material.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';

class ConverstationItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String timestamp;
  final String imageUrl;

  const ConverstationItem({
    super.key,
    required this.name,
    required this.lastMessage,
    required this.timestamp,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AVT
        Stack(
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
            UserImage(imageUrl: imageUrl, size: AppDimensions.avatarXl),
          ],
        ),
        const SizedBox(width: AppDimensions.md),

        // NAME
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: AppTypography.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    timestamp,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                lastMessage,
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: AppDimensions.md),

        // Arrow icon
        Transform.rotate(
          angle: 3.1,
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ],
    );
  }
}
