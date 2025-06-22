import 'package:flutter/material.dart';
import 'package:locket/core/configs/assets/app_images.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';

class Logo extends StatelessWidget {
  final double? size;

  const Logo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Image.asset(
        AppImages.logo,
        width: size ?? AppDimensions.avatarLg,
        height: size ?? AppDimensions.avatarLg,
        fit: BoxFit.contain,
      ),
    );
  }
}
