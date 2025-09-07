import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller_state.dart';
import 'package:locket/presentation/home/pages/feed_page.dart';
import 'package:locket/presentation/home/widgets/camera/index.dart';
import 'package:locket/presentation/home/widgets/friend_select.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/history_feed.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _homeController;
  late final FeedController _feedController;
  late final ConversationController _conversationController;

  @override
  void initState() {
    super.initState();
    _homeController = getIt<HomeController>();
    _feedController = getIt<FeedController>();
    _conversationController = getIt<ConversationController>();

    // Initialize both controllers
    _homeController.init();

    // Fetch feeds when HomePage is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
      await _feedController.fetchInitialFeeds();
      await _conversationController.loadCachedConversations();
      await _conversationController.fetchUnreadCountConversation();
      }
    });
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeControllerState>(
      create: (_) => _homeController.state,
      child: Consumer<HomeControllerState>(
        builder: (context, homeState, _) {
          final userService = getIt<UserService>();

          if (homeState.isLoadingProfile && !userService.isLoggedIn) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (_homeController.shouldRedirectToLogin()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              AppNavigator.pushAndRemove(context, '/login');
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            appBar: BasicAppbar(
              hideBack: true,
              action: _buildAppBarActions(homeState),
            ),
            body: PageView(
              controller: _homeController.outerController,
              scrollDirection: Axis.vertical,
              children: [
                _CameraSection(
                  onHistoryFeedTap:
                      () => _homeController.handleScrollPageViewOuter(1),
                ),
                _FeedSection(
                  innerController: _homeController.innerController,
                  outerController: _homeController.outerController,
                  onScrollFeedToTop:
                      () => _homeController.handleScrollPageViewOuter(0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarActions(HomeControllerState homeState) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const UserImage(),
            homeState.enteredFeed ? const FriendSelect() : const FriendTopbar(),
            const MessButton(),
          ],
        ),
      ),
    );
  }
}

class _CameraSection extends StatelessWidget {
  final VoidCallback onHistoryFeedTap;

  const _CameraSection({required this.onHistoryFeedTap});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CameraControllerState>.value(
          value: getIt<CameraControllerState>(),
        ),
        Provider<CameraController>.value(value: getIt<CameraController>()),
      ],
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppDimensions.md,
              right: AppDimensions.md,
              top: AppDimensions.appBarHeight + AppDimensions.xl,
            ),
            child: const Camera(),
          ),
          Positioned(
            bottom: AppDimensions.xl,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: onHistoryFeedTap,
              child: const Center(child: HistoryFeed()),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedSection extends StatelessWidget {
  final PageController innerController;
  final PageController outerController;
  final VoidCallback onScrollFeedToTop;

  const _FeedSection({
    required this.innerController,
    required this.outerController,
    required this.onScrollFeedToTop,
  });

  @override
  Widget build(BuildContext context) {
    return FeedPage(
      innerController: innerController,
      outerController: outerController,
      handleScrollFeedToTop: onScrollFeedToTop,
    );
  }
}
