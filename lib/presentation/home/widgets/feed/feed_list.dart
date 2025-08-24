import 'package:flutter/material.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/presentation/home/widgets/feed/feed_caption.dart';
import 'package:locket/presentation/home/widgets/feed/feed_image.dart';
import 'package:locket/presentation/home/widgets/feed/feed_user.dart';
import 'package:provider/provider.dart';

class FeedList extends StatefulWidget {
  final PageController innerController;
  const FeedList({super.key, required this.innerController});

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  @override
  void initState() {
    super.initState();
    widget.innerController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    widget.innerController.removeListener(_onScroll);
  }

  void _onScroll() {
    final feedController = context.read<FeedController>();
    final feedState = context.read<FeedControllerState>();

    // Check if we're near the end and need to load more
    if (widget.innerController.hasClients) {
      final maxScrollExtent = widget.innerController.position.maxScrollExtent;
      final currentPosition = widget.innerController.position.pixels;

      final triggerOffset = maxScrollExtent * 0.8;

      if (currentPosition >= triggerOffset &&
          feedState.hasMoreData &&
          !feedState.isLoadingMore) {
        feedController.loadMoreFeeds();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedController = context.read<FeedController>();
    final feedState = context.watch<FeedControllerState>();

    // Show loading state
    if (feedState.isLoading && !feedState.hasInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error state
    if (feedState.errorMessage != null && feedState.listFeed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              feedState.errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => feedController.refreshFeed(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Show empty state
    if (!feedState.isLoading && feedState.listFeed.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có ảnh nào được đăng',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        PageView.builder(
          controller: widget.innerController,
          scrollDirection: Axis.vertical,
          itemCount: feedState.listFeed.length,
          itemBuilder: (context, index) {
            final feed = feedState.listFeed[index];

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
                            Stack(
                              children: [
                                FeedImage(
                                  imageUrl: feed.imageUrl,
                                  format: feed.format,
                                  isFront: feed.isFrontCamera,
                                ),
                                if (feed.caption != '')
                                  Positioned(
                                    bottom: AppDimensions.md,
                                    left: AppDimensions.md,
                                    right: AppDimensions.md,
                                    child: FeedCaption(caption: feed.caption),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppDimensions.lg),
                            FeedUser(
                              avatarUrl: feed.user.avatarUrl,
                              username: feed.user.username,
                              createdAt: feed.createdAt,
                            ),
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
        AnimatedPadding(
          duration: const Duration(milliseconds: 0),
          curve: Curves.linear,
          padding: EdgeInsets.only(
            bottom:
                feedState.isKeyboardOpen
                    ? MediaQuery.of(context).viewInsets.bottom
                    : MediaQuery.of(context).viewInsets.bottom + 96,
          ),
          child: MessageField(focusNode: feedController.messageFieldFocusNode),
        ),
      ],
    );
  }
}
