import 'package:flutter/material.dart';
import 'package:locket/core/configs/assets/app_images.dart';

class UserImage extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  final BoxShape shape;
  final double? borderRadius;

  const UserImage({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.shape = BoxShape.circle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: borderRadius != null ? BoxShape.rectangle : shape,
        borderRadius:
            borderRadius != null ? BorderRadius.circular(borderRadius!) : null,
        image: DecorationImage(
          image:
              imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : AssetImage(AppImages.user),
          fit:     imageUrl != null && imageUrl!.isNotEmpty ? BoxFit.cover : BoxFit.fill,
        ),
        color: Colors.white,
      ),
    );
  }
}
