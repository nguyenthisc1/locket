import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class MessageField extends StatelessWidget {
  const MessageField({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: TextField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Gửi tin nhắn...',
            filled: true,
            fillColor: Colors.white.safeOpacity(0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
