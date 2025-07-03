import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/widgets/feed/feed_image.dart';
import 'package:locket/presentation/home/widgets/feed/feed_user.dart';
import 'package:locket/presentation/home/widgets/friend_toolbar.dart';

class Feed extends StatelessWidget {
  final PageController innerController;
  final PageController outerController;
  final void Function() onScrollToTop;

  const Feed({
    super.key,
    required this.innerController,
    required this.outerController,
    required this.onScrollToTop,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (innerController.page == 0 &&
            notification is ScrollUpdateNotification &&
            notification.metrics.pixels <= 0 &&
            notification.scrollDelta! < -10) {
          // Đã ở đầu feed, và user kéo lên
          outerController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return true;
        }
        return false;
      },
      child: Stack(
        children: [
          PageView.builder(
            controller: innerController,
            scrollDirection: Axis.vertical,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: AppDimensions.md,
                  right: AppDimensions.md,
                  bottom: AppDimensions.xl,
                  top: AppDimensions.appBarHeight + AppDimensions.xl,
                ),
                child: Column(
                  children: [
                    FeedImage(),
                    const SizedBox(height: AppDimensions.lg),
                    FeedUser(),
                  ],
                ),
              );
            },
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.md,
                right: AppDimensions.md,
                bottom: AppDimensions.xl,
              ),
              child: FriendToolbar(onScrollToTop: onScrollToTop),
            ),
          ),
        ],
      ),
    );
  }
}
