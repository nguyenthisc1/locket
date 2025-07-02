import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';

class FriendTopbar extends StatelessWidget {
  const FriendTopbar({super.key});

  void _showFriendBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Friends', style: AppTypography.bodyLarge),
              const SizedBox(height: 16),
              // Add your friend list content here
              const Expanded(
                child: Center(
                  child: Text('Friend list will be displayed here'),
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
    return GestureDetector(
      onTap: () => _showFriendBottomSheet(context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        ),
        child: Row(
          children: [
            // Icon double user
            const Icon(Icons.people, size: 28, color: Colors.white70),
            const SizedBox(width: AppDimensions.sm),
            // Count friend
            Text(
              '0 người bạn',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
