import 'package:flutter/material.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:locket/core/configs/assets/app_images.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';

class Logo extends StatelessWidget {
  final double? size;

  const Logo({super.key, this.size});

  @override
  Widget build(BuildContext context) {
    return RatioClip(
      radiusRatio: 0.9,
      child: Image.asset(
        AppImages.logo,
        width: size ?? AppDimensions.avatarLg,
        height: size ?? AppDimensions.avatarLg,
        fit: BoxFit.contain,
      ),
    );
  }
}
