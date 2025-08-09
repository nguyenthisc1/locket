import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/take_button.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';

class GalleryToolbar extends StatelessWidget {
  final FeedController? feedController;
  
  const GalleryToolbar({
    super.key,
    this.feedController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: GestureDetector(
            onTap: () {
              final currentIndex = feedController?.state.popImageIndex;
              AppNavigator.pop(context, currentIndex);
            },
            child: TakeButton(size: AppDimensions.xxl),
          ),
        ),
      ],
    );
  }
}
