import 'package:flutter/material.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';

class FeedImage extends StatelessWidget {
  final String imageUrl;

  const FeedImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Hero(
        tag: imageUrl,
        child: RatioClip(
          // borderRadius: BorderRadius.circular(36),
          radiusRatio: 0.15,
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
