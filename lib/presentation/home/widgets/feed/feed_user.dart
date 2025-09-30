import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';

class FeedUser extends StatelessWidget {
  final String? avatarUrl;
  final String username;
  final DateTime createdAt;

  const FeedUser({
    super.key,
    required this.username,
    required this.createdAt,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserImage(imageUrl: avatarUrl ?? null),
        const SizedBox(width: AppDimensions.sm),
        Text(
          username,
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Text(
          formatVietnameseTimestamp(createdAt),
          style: AppTypography.bodyLarge.copyWith(color: AppColors.offline),
        ),
      ],
    );
  }
}
