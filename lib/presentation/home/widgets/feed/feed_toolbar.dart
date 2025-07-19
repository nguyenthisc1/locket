import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/take_button.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/feed_controller.dart';
import 'package:locket/presentation/home/pages/gallery_page.dart';
import 'package:locket/presentation/home/widgets/build_icon_button.dart';
import 'package:provider/provider.dart';

class FeedToolbar extends StatelessWidget {
  final void Function() handleScrollToTop;
  final void Function() handleGalleryToggle;
  final List<String> getImages;

  const FeedToolbar({
    super.key,
    required void Function() onScrollToTop,
    required void Function() onGalleryToggle,
    required List<String> images,
  }) : handleScrollToTop = onScrollToTop,
       handleGalleryToggle = onGalleryToggle,
       getImages = images;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BuildIconButton(
          onPressed:
              () => AppNavigator.fadePush(
                context,
                ChangeNotifierProvider.value(
                  value: context.read<FeedControllerState>(),
                  child: GalleryPage(images: getImages),
                ),
              ),
          icon: Icons.menu,
        ),
        GestureDetector(
          onTap: handleScrollToTop,
          child: TakeButton(size: AppDimensions.xxl),
        ),
        BuildIconButton(onPressed: () {}, icon: Icons.ios_share),
      ],
    );
  }
}
