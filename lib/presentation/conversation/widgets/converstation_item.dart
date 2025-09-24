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
    final String nameText = data.name;
    final String? imageUrl =
        data.participants.isNotEmpty ? data.participants[0].avatarUrl : null;
    final String senderId = lastMessage?.senderId ?? '';
    final bool isMine = senderId == currentUserId;

    // Filter out current user from participants
    final isReadReceipts =
        data.participants.where((participant) {
          return participant.id != currentUserId &&
              participant.lastReadMessageId == lastMessage?.messageId;
        }).toList();

    final int displayCount =
        isReadReceipts.length > 3 ? 3 : isReadReceipts.length;

    Widget _buildAvatarWithIndicator() {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          if (!isMine)
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
      );
    }

    Widget _buildNameAndMessage() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nameText,
            style: AppTypography.headlineLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppDimensions.sm),
          Row(
            children: [
              Flexible(
                child: Text(
                  lastMessageText,
                  style: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color:
                        isMine 
                            ? AppColors.textSecondary
                            : Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Container(
                width: AppDimensions.xs,
                height: AppDimensions.xs,
                decoration: const BoxDecoration(
                  color: AppColors.textSecondary,
                  shape: BoxShape.circle,
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
                maxLines: 1,
              ),
            ],
          ),
        ],
      );
    }

    Widget _buildParticipantsAvatars() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            displayCount,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: UserImage(
                size: AppDimensions.avatarXs,
                imageUrl: isReadReceipts[index].avatarUrl,
              ),
            ),
          ),
          if (isReadReceipts.length > 3)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Text(
                '...',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatarWithIndicator(),
        const SizedBox(width: AppDimensions.md),
        Expanded(child: _buildNameAndMessage()),
        const SizedBox(width: AppDimensions.md),
        _buildParticipantsAvatars(),
      ],
    );
  }
}
