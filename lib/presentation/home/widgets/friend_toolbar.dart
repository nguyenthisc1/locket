import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/widgets/build_icon_button.dart';
import 'package:locket/common/wigets/take_button.dart';

class FriendToolbar extends StatelessWidget {
  final void Function() onScrollToTop;

  const FriendToolbar({super.key, required this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BuildIconButton(onPressed: () {}, icon: Icons.menu),
        GestureDetector(
          onTap: onScrollToTop,
          child: TakeButton(size: AppDimensions.xxl),
        ),
        BuildIconButton(onPressed: () {}, icon: Icons.ios_share),
      ],
    );
  }
}
