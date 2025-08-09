import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/gallery/gallery_list.dart';
import 'package:locket/presentation/home/widgets/gallery/gallery_toolbar.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';
import 'package:provider/provider.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller from the Provider.value set in router
    final feedController = context.read<FeedController>();
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      appBar: BasicAppbar(
        hideBack: true,
        action: Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.md,
              right: AppDimensions.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const UserImage(),
                const FriendTopbar(),
                const MessButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.md,
            right: AppDimensions.md,
            bottom: AppDimensions.xxl,
          ),
          child: GalleryToolbar(feedController: feedController),
        ),
      ),
      body: GalleryList(),
    );
  }
}
