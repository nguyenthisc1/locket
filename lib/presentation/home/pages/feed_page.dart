import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/routes/router.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/presentation/home/widgets/feed/feed_list.dart';
import 'package:locket/presentation/home/widgets/feed/feed_toolbar.dart';
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
    final result = await context.push('/gallery');

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
    // Use Consumer to watch state changes for FeedControllerState
    return Consumer<FeedControllerState>(
      builder: (context, feedState, _) {
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
            child: FeedList(innerController: widget.innerController)
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    goRouterObserver.unsubscribe(this);
    super.dispose();
  }
}
