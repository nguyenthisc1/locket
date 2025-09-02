import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConverstationItem extends StatelessWidget {
  final ConversationEntity data;

  const ConverstationItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String lastMessageText = data.lastMessage!.text;
    final DateTime timestampText = data.lastMessage!.timestamp;
    final bool isRead = data.lastMessage!.isRead;
    final String nameText = data.name!;
    final String? imageUrl = data.participants[0].avatarUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AVT
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (!isRead)
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
                      nameText,
                      style: AppTypography.headlineLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.sm),
                  Text(
                    formatVietnameseTimestamp(timestampText),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                lastMessageText,
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isRead ? AppColors.textSecondary : Colors.white,
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
