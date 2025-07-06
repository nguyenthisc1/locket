import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';

import '../../../core/configs/theme/index.dart';

class ConversationDetailPage extends StatelessWidget {
  const ConversationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
              size: AppDimensions.avatarMd,
            ),
            const SizedBox(width: AppDimensions.md),
            Text(
              'Name 1123',
              style: AppTypography.headlineLarge.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        action: Icon(Icons.more_horiz, size: AppDimensions.iconLg),
      ),

      body: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          top: AppDimensions.lg,
        ),
        child: SingleChildScrollView(),
      ),
    );
  }
}
