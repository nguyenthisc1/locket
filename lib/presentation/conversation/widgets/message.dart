import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/common/wigets/photo_preview.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';

class Message extends StatelessWidget {
  final MessageEntity data;
  final LastMessageEntity? lastMessage;
  final List<ConversationParticipantEntity>? participants;

  const Message({
    super.key,
    required this.data,
    this.lastMessage,
    this.participants = const [],
  });

  void showImagePreview(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Close",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder:
          (context, _, _) => PhotoPreview(
            imageUrl: imageUrl,
            tag: imageUrl,
            onClose: () => Navigator.of(context).pop(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: AppDimensions.xs,
      children: [
        if (data.replyTo != null && data.replyInfo != null)
          _buildMessageReply(context, data)
        else
          data.attachments.isNotEmpty
              ? _buildMessageImage(context, data)
              : _messageText(context, data),

      ],
    );
  }

  Widget _messageText(BuildContext context, MessageEntity data) {
    return Align(
      alignment: data.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                decoration: BoxDecoration(
                  color:
                      data.isMe
                          ? AppColors.borderLight.safeOpacity(0.9)
                          : Colors.white.safeOpacity(0.2),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.md,
                  vertical: AppDimensions.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.text,
                      style: AppTypography.headlineLarge.copyWith(
                        color: data.isMe ? AppColors.dark : Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xs),
                  ],
                ),
              ),
            ),
          ),

          // if (data.isMe)
          //  _buildIsReadReceipts(context);
          if (data.reactions.isNotEmpty)
            _buildReaction(context, data.reactions, data.isMe),
        ],
      ),
    );
  }

  Widget _buildMessageImage(BuildContext context, MessageEntity data) {
    final String imageUrl =
        data.attachments.isNotEmpty ? (data.attachments[0]['url'] ?? '') : '';
    return GestureDetector(
      onTap: () => showImagePreview(context, imageUrl),
      child: Align(
        alignment: data.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              child: Image.network(
                imageUrl,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.35,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
              ),
            ),
            // SENDER NAME
            Positioned(
              top: AppDimensions.md,
              left: AppDimensions.md,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: AppDimensions.sm,
                      right: AppDimensions.md,
                      top: AppDimensions.sm,
                      bottom: AppDimensions.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.safeOpacity(0.5),
                    ),
                    child: Row(
                      children: [
                        UserImage(
                          imageUrl:
                              'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
                          size: AppDimensions.avatarXs,
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          // data.senderName, 
                          '',
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          data.timestamp,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // SENDER TEXT
            Positioned(
              bottom: AppDimensions.md,
              left: AppDimensions.md,
              right: AppDimensions.md,
              child: Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.sm,
                        horizontal: AppDimensions.md,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.safeOpacity(0.3),
                      ),
                      child: Text(
                        data.text,
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (data.reactions.isNotEmpty)
              _buildReaction(context, data.reactions, data.isMe),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageReply(BuildContext context, MessageEntity data) {
    final bool hasImage = data.attachments.isNotEmpty;
    final String? replyText = data.replyInfo?.text;
    final String replySenderName = data.replyInfo?.senderName ?? '';

    return Transform.translate(
      offset: Offset(0, -AppDimensions.md),
      child: Align(
        alignment: data.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              data.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: Offset(
                data.isMe ? -AppDimensions.lg : AppDimensions.lg,
                AppDimensions.lg,
              ),
              child: Column(
                crossAxisAlignment:
                    data.isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                        data.isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      Text(
                        'Đã trả lời $replySenderName',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  if (!hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.7,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  data.isMe
                                      ? AppColors.borderLight.safeOpacity(0.9)
                                      : Colors.white.safeOpacity(0.2),
                            ),
                            padding: EdgeInsets.only(
                              left: AppDimensions.md,
                              right: AppDimensions.md,
                              top: AppDimensions.md,
                              bottom: AppDimensions.xl,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  replyText ?? '',
                                  style: AppTypography.headlineLarge.copyWith(
                                    color:
                                        data.isMe
                                            ? AppColors.dark
                                            : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.xs),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusXl,
                      ),
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.network(
                          data.replyInfo?.attachments != null &&
                                  data.replyInfo!.attachments.isNotEmpty
                              ? data.replyInfo!.attachments[0]['url'] ?? ''
                              : '',
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: MediaQuery.of(context).size.height * 0.2,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                width: MediaQuery.of(context).size.width * 0.5,
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!hasImage)
              _messageText(context, data)
            else
              _buildMessageImage(context, data),
          ],
        ),
      ),
    );
  }

  Widget _buildReaction(BuildContext context, dynamic reactions, bool isMe) {
    return Positioned(
      bottom: -AppDimensions.md,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xs,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.borderLight : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              reactions is List
                  ? reactions.map<Widget>((reaction) {
                    final type = reaction['type']?.toString() ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(type, style: AppTypography.headlineMedium),
                    );
                  }).toList()
                  : [],
        ),
      ),
    );
  }

}
