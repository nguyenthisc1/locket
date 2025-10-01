import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller_state.dart';
import 'package:locket/presentation/home/widgets/friend_select.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/home/camera_section.dart';
import 'package:locket/presentation/home/widgets/home/feed_section.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';
import 'package:locket/presentation/home/widgets/user_info.dart';
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

    // // Initialize both controllers
    _homeController.init();

    // Fetch when HomePage is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        await _conversationController.init();
        // Add a small delay to ensure auth and token setup is complete
        await Future.delayed(const Duration(milliseconds: 200));

        await _feedController.fetchInitialFeeds();
        _conversationController.countUnreadConversations();
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
    return ChangeNotifierProvider<HomeControllerState>.value(
      value: _homeController.state,
      child: Consumer<HomeControllerState>(
        builder: (context, homeState, _) {
          if (homeState.isLoadingProfile) {
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
                CameraSection(
                  onHistoryFeedTap:
                      () => _homeController.handleScrollPageViewOuter(1),
                ),
                FeedSection(
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
            UserInfo(),
            homeState.enteredFeed ? const FriendSelect() : const FriendTopbar(),
            const MessButton(),
          ],
        ),
      ),
    );
  }
}
