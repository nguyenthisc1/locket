import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';

class FeedImage extends StatelessWidget {
  final String image;

  const FeedImage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Hero(
        tag: image,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          child: Image.network(image, fit: BoxFit.cover,),
        ),
      ),
    );
  }
}
