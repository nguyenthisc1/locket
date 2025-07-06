import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe;
  final String timestamp;

  const Message({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color:
                  !isMe
                      ? Colors.white.safeOpacity(0.2)
                      : AppColors.borderLight.safeOpacity(0.9),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTypography.headlineLarge.copyWith(
                    color: !isMe ? Colors.white : AppColors.dark,
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
    );
  }
}
