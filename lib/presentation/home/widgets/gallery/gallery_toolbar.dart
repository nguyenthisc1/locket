import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/take_button.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/feed_controller.dart';
import 'package:provider/provider.dart';

class GalleryToolbar extends StatelessWidget {
  const GalleryToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    final feedController = context.read<FeedControllerState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.sm),
          child: GestureDetector(
            onTap: () {
              feedController.popImageIndex;
              AppNavigator.pop(context);
            },
            child: TakeButton(size: AppDimensions.xxl),
          ),
        ),
      ],
    );
  }
}
