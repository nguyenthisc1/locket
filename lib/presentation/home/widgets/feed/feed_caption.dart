import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';

class FeedCaption extends StatelessWidget {
  final String? caption;

  const FeedCaption({super.key, this.caption});

  @override
  Widget build(BuildContext context) {
      return Align(
        alignment: Alignment.center,
     child: SizedBox(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.md,
              ),
              decoration: BoxDecoration(color: Colors.black.safeOpacity(0.3)),
              child: Text(
                caption ?? '',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
