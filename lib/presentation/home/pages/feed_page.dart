import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/routes/router.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/presentation/home/widgets/feed/feed_caption.dart';
import 'package:locket/presentation/home/widgets/feed/feed_image.dart';
import 'package:locket/presentation/home/widgets/feed/feed_toolbar.dart';
import 'package:locket/presentation/home/widgets/feed/feed_user.dart';
import 'package:locket/presentation/home/widgets/feed/feed_video.dart';
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
  late final FeedController _feedController;
  bool _isNavigatingFromGallery = false;

  @override
  void initState() {
    super.initState();

    // Get controller from GetIt - it should have the same state instance as Provider
    _feedController = getIt<FeedController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _feedController.init();
      }
    });
  }

  @override
  void didPopNext() {
    final feedState = context.read<FeedControllerState>();
    final index = feedState.popImageIndex;

    if (index != null) {
      _isNavigatingFromGallery = true;
      _feedController.setPopImageIndex(null);

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
    goRouterObserver.subscribe(this, ModalRoute.of(context)!);
  }

  Future<void> _navigateToGallery() async {
    final result = await context.push(
      '/gallery',
      extra: {'controller': _feedController},
    );

    if (result != null && result is int) {
      widget.innerController.animateToPage(
        result,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use Provider to watch state changes
    final feedState = context.watch<FeedControllerState>();

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
            onGalleryToggle: _feedController.toggleGalleryVisibility,
            images: feedState.listFeed,
            onGalleryTap: _navigateToGallery,
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
          animation: feedState,
          builder: (context, _) {
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
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedState.errorMessage!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _feedController.refreshFeed(),
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
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
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
                                          imageUrl:
                                              feedState
                                                  .listFeed[index]
                                                  .imageUrl,
                                          format:
                                              feedState.listFeed[index].format,
                                        ),

                                        if (feedState.listFeed[index].caption !=
                                            null)
                                          Positioned(
                                            bottom: AppDimensions.md,
                                            left: AppDimensions.md,
                                            right: AppDimensions.md,
                                            child: FeedCaption(
                                              caption:
                                                  feedState
                                                      .listFeed[index]
                                                      .caption,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: AppDimensions.lg),
                                    FeedUser(
                                      avatarUrl:
                                          feedState
                                              .listFeed[index]
                                              .user
                                              .avatarUrl,
                                      username:
                                          feedState
                                              .listFeed[index]
                                              .user
                                              .username,
                                      createdAt:
                                          feedState.listFeed[index].createdAt,
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
                  child: MessageField(
                    focusNode: _feedController.messageFieldFocusNode,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    goRouterObserver.unsubscribe(this);
    super.dispose();
  }
}
