import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';

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
        image:
            imageUrl != null
                ? DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                )
                : null,
        // ignore: deprecated_member_use
        color: imageUrl == null ? Colors.white.safeOpacity(0.2) : null,
      ),
      child:
          imageUrl == null
              ? Icon(Icons.person, size: 24, color: Colors.white70)
              : null,
    );
  }
}
