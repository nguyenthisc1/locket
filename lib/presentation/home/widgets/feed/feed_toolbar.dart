import 'package:flutter/material.dart';
import 'package:locket/common/wigets/take_button.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/presentation/home/widgets/build_icon_button.dart';

class FeedToolbar extends StatelessWidget {
  final VoidCallback onScrollToTop;
  final VoidCallback onGalleryToggle;
  final List<FeedEntity> images;
  final VoidCallback onGalleryTap;

  const FeedToolbar({
    super.key,
    required this.onScrollToTop,
    required this.onGalleryToggle,
    required this.images,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BuildIconButton(onPressed: onGalleryTap, icon: Icons.menu),
        GestureDetector(
          onTap: onScrollToTop,
          child: TakeButton(size: AppDimensions.xxl),
        ),
        BuildIconButton(onPressed: () {}, icon: Icons.ios_share),
      ],
    );
  }
}
