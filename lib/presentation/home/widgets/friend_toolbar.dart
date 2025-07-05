import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/widgets/build_icon_button.dart';
import 'package:locket/presentation/home/widgets/take_button.dart';

class FriendToolbar extends StatelessWidget {
  final void Function() onScrollToTop;

  const FriendToolbar({super.key, required this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Gửi tin nhắn...',
                filled: true,
                fillColor: AppColors.dark.safeOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BuildIconButton(onPressed: () {}, icon: Icons.menu),
            GestureDetector(
              onTap: onScrollToTop,
              child: TakeButton(size: AppDimensions.xxl),
            ),
            BuildIconButton(onPressed: () {}, icon: Icons.ios_share),
          ],
        ),
      ],
    );
  }
}
