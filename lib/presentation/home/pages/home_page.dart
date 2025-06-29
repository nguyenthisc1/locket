import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/widgets/camera/camera.dart';
import 'package:locket/presentation/home/widgets/friend_bar.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';
import 'package:locket/presentation/home/widgets/user_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BasicAppbar(
        hideBack: true,
        action: Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.md,
              right: AppDimensions.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: AppDimensions.md,
              children: [UserImage(), FriendBar(), MessButton()],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          bottom: AppDimensions.appBarHeight,
        ),
        child: Column(children: [SizedBox(height: AppDimensions.lg), Camera()]),
      ),
    );
  }
}
