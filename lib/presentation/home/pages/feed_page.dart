import 'package:flutter/material.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/main.dart';
import 'package:locket/presentation/home/controllers/feed_controller.dart';
import 'package:locket/presentation/home/widgets/feed/feed_image.dart';
import 'package:locket/presentation/home/widgets/feed/feed_toolbar.dart';
import 'package:locket/presentation/home/widgets/feed/feed_user.dart';
import 'package:provider/provider.dart';

class FeedPage extends StatefulWidget {
  final PageController innerController;
  final PageController outerController;
  final void Function() handleScrollFeedToTop;
  final List<String> images;

  const FeedPage({
    super.key,
    required this.innerController,
    required this.outerController,
    required this.handleScrollFeedToTop,
    required this.images,
  });

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> with RouteAware {
  late final FeedControllerState _feedController;

  @override
  void initState() {
    super.initState();

    _feedController = FeedControllerState();

    _feedController.init();
  }

  @override
  void didPopNext() {
    widget.innerController.jumpToPage(
      context.read<FeedControllerState>().popImageIndex,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
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
            images: widget.images,
          ),
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (widget.innerController.page == 0 &&
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
            return Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: [
                PageView.builder(
                  controller: widget.innerController,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.images.length,
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
                                    FeedImage(image: widget.images[index]),
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

                AnimatedPadding(
                  duration: Duration(milliseconds: 0),
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
