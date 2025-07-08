import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';

class Message extends StatelessWidget {
  final MessageEntity data;

  const Message({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.replyTo != null && data.replyInfo != null) {
      return _messageReply(context, data);
    }
    return data.attachments.isNotEmpty
        ? _messageImage(context, data)
        : _messageText(context, data);
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
                      !data.isMe
                          ? Colors.white.safeOpacity(0.2)
                          : AppColors.borderLight.safeOpacity(0.9),
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
                        color: !data.isMe ? Colors.white : AppColors.dark,
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

          if (data.reactions.isNotEmpty) _reaction(context, data.reactions),
        ],
      ),
    );
  }

  Widget _messageImage(BuildContext context, MessageEntity data) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          child: Image.network(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.4,
            data.attachments.isNotEmpty ? data.attachments[0]['url'] ?? '' : '',
            fit: BoxFit.cover,
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
                decoration: BoxDecoration(color: Colors.black.safeOpacity(0.5)),
                child: Row(
                  children: [
                    UserImage(
                      imageUrl:
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
                      size: AppDimensions.avatarXs,
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Text(
                      data.senderName,
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

        if (data.reactions.isNotEmpty) _reaction(context, data.reactions),
      ],
    );
  }

  Widget _messageReply(BuildContext context, MessageEntity data) {
    return Align(
      alignment: data.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        children: [
          // Row(children: [

          //   ],
          // ),
          Transform.translate(
            offset: Offset(
              data.isMe ? -AppDimensions.md : AppDimensions.md,
              AppDimensions.lg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    color:
                        !data.isMe
                            ? Colors.white.safeOpacity(0.2)
                            : AppColors.borderLight.safeOpacity(0.9),
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
                        data.replyInfo?['text'] ?? '',
                        style: AppTypography.headlineLarge.copyWith(
                          color: !data.isMe ? Colors.white : AppColors.dark,
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
          Stack(
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
                          !data.isMe
                              ? Colors.white.safeOpacity(0.2)
                              : AppColors.borderLight.safeOpacity(0.9),
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
                            color: !data.isMe ? Colors.white : AppColors.dark,
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

              if (data.reactions.isNotEmpty) _reaction(context, data.reactions),
            ],
          ),
        ],
      ),
    );
  }

  Widget _reaction(BuildContext context, dynamic reactions) {
    return Positioned(
      bottom: -AppDimensions.md,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.xs,
          vertical: AppDimensions.xs,
        ),
        decoration: BoxDecoration(
          color: !data.isMe ? Colors.white : AppColors.borderLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:
              reactions.map<Widget>((reaction) {
                final type = reaction['type']?.toString() ?? '';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(type, style: AppTypography.headlineMedium),
                );
              }).toList(),
        ),
      ),
    );
  }
}
