import 'package:flutter/material.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';

class FeedUser extends StatelessWidget {
  const FeedUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserImage(
          imageUrl:
              'https://images.unsplash.com/photo-1751217052634-cd51e3519355?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwyNHx8fGVufDB8fHx8fA%3D%3D',
          size: 40,
        ),
        const SizedBox(width: AppDimensions.sm),
        Text(
          'Yến',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppDimensions.md),
        Text(
          '1ngày',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.offline),
        ),
      ],
    );
  }
}
