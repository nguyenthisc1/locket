import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';

class HistoryFeed extends StatelessWidget {
  const HistoryFeed({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Image.network(
                'https://images.unsplash.com/photo-1751217052634-cd51e3519355?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHwyNHx8fGVufDB8fHx8fA%3D%3D',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'Lịch sử',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Transform.rotate(
          angle: -1.55,
          child: Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
        ),
      ],
    );
  }
}
