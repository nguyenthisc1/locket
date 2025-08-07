import 'package:flutter/material.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/routes/router.dart'; // Import for goRouterObserver
import 'package:locket/presentation/home/controllers/feed_controller.dart';
import 'package:locket/presentation/home/widgets/feed/feed_caption.dart';
import 'package:locket/presentation/home/widgets/feed/feed_image.dart';
import 'package:locket/presentation/home/widgets/feed/feed_toolbar.dart';
import 'package:locket/presentation/home/widgets/feed/feed_user.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  final PageController innerController;
  final PageController outerController;
  final void Function() handleScrollFeedToTop;

  const FeedPage({
    super.key,
    required this.innerController,
    required this.outerController,
    required this.handleScrollFeedToTop,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with RouteAware {
  bool _isNavigatingFromGallery = false;

  @override
  void initState() {
    super.initState();

    // Initialize the feed controller after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FeedControllerState>().init();

        print(context.read<FeedControllerState>().popImageIndex);
      }
    });
  }

  @override
  void didPopNext() {
    final controller = context.read<FeedControllerState>();
    final index = controller.popImageIndex;

    if (index != null) {
      _isNavigatingFromGallery = true; // Set flag
      controller.setPopImageIndex(null);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.innerController.jumpToPage(index);

        // Reset flag after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _isNavigatingFromGallery = false;
          }
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use the GoRouter observer instead of the old routeObserver
    goRouterObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    goRouterObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedController = context.watch<FeedControllerState>();

    return Scaffold(
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppDimensions.md,
            right: AppDimensions.md,
            bottom: AppDimensions.xxl,
          ),
          child: FeedToolbar(
            onScrollToTop: widget.handleScrollFeedToTop,
            onGalleryToggle: feedController.toggleGalleryVisibility,
            images: feedController.listFeed,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Don't trigger outer scroll if we just navigated from gallery
          if (!_isNavigatingFromGallery &&
              widget.innerController.page == 0 &&
              notification is ScrollUpdateNotification &&
              notification.metrics.pixels <= 0 &&
              notification.scrollDelta! < -10) {
            widget.outerController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            return true;
          }
          return false;
        },
        child: AnimatedBuilder(
          animation: feedController,
          builder: (context, _) {
            // Show loading state
            if (feedController.isLoading && !feedController.hasInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show error state
            if (feedController.errorMessage != null &&
                feedController.listFeed.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedController.errorMessage!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => feedController.refreshFeed(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show empty state
            if (!feedController.isLoading && feedController.listFeed.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No feeds available',
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
                  itemCount: feedController.listFeed.length,
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
                                    Stack(
                                      children: [
                                        FeedImage(
                                          image:
                                              feedController
                                                  .listFeed[index]
                                                  .imageUrl,
                                        ),
                                        if (feedController
                                                .listFeed[index]
                                                .caption !=
                                            null)
                                          Positioned(
                                            bottom: AppDimensions.md,
                                            left: AppDimensions.md,
                                            right: AppDimensions.md,
                                            child: FeedCaption(
                                              caption:
                                                  feedController
                                                      .listFeed[index]
                                                      .caption,
                                            ),
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: AppDimensions.lg),
                                    FeedUser(
                                      avatarUrl:
                                          feedController
                                              .listFeed[index]
                                              .user
                                              .avatarUrl,
                                      username:
                                          feedController
                                              .listFeed[index]
                                              .user
                                              .username,
                                      createdAt:
                                          feedController
                                              .listFeed[index]
                                              .createdAt,
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
                        feedController.isKeyboardOpen
                            ? MediaQuery.of(context).viewInsets.bottom
                            : MediaQuery.of(context).viewInsets.bottom + 96,
                  ),
                  child: MessageField(
                    focusNode: feedController.messageFieldFocusNode,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
