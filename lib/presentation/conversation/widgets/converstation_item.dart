import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConversationItem extends StatelessWidget {
  final ConversationEntity data;

  const ConversationItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<UserService>().currentUser?.id;
    final lastMessage = data.lastMessage;
    final String lastMessageText = lastMessage?.text ?? '';
    final DateTime? timestamp = lastMessage?.timestamp;
    final bool isRead = lastMessage?.isRead ?? true;
    final String nameText = data.name ?? '';
    final String? imageUrl = data.participants.isNotEmpty ? data.participants[0].avatarUrl : null;
    final String senderId = lastMessage?.sender.id ?? '';
    final bool isMine = senderId == currentUserId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar with unread indicator
        Stack(
          clipBehavior: Clip.none,
          children: [
            if (!isMine && !isRead)
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

        // Name and message
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
                    timestamp != null ? formatVietnameseTimestamp(timestamp) : '',
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
                  color: isMine || isRead
                      ? AppColors.textSecondary
                      : Colors.white,
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
