import 'package:flutter/material.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/widgets/feed/feed_image.dart';
import 'package:locket/presentation/home/widgets/feed/feed_user.dart';
import 'package:locket/presentation/home/widgets/friend_toolbar.dart';

class Feed extends StatelessWidget {
  final PageController innerController;
  final PageController outerController;
  final void Function() handleScrollFeedToTop;

  const Feed({
    super.key,
    required this.innerController,
    required this.outerController,
    required this.handleScrollFeedToTop,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          bottom: AppDimensions.xxl,
        ),
        child: FriendToolbar(onScrollToTop: handleScrollFeedToTop),
      ),
      body: NotificationListener<ScrollNotification>(
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                FeedImage(),
                                const SizedBox(height: AppDimensions.lg),
                                FeedUser(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            Positioned.fill(
              bottom: 0,
              left: 0,
              right: 0,
              child: MessageField(),
            ),
          ],
        ),
      ),
    );
  }
}
