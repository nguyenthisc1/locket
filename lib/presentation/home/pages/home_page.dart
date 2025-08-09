import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
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

  @override
  void initState() {
    super.initState();
    _homeController = getIt<HomeController>();
    _homeController.init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<HomeControllerState>(
      create: (context) => _homeController.state,
      child: Consumer<HomeControllerState>(
        builder: (context, homeState, child) {
          final userService = getIt<UserService>();

          // Show loading spinner while fetching profile
          if (homeState.isLoadingProfile && !userService.isLoggedIn) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // If profile fetch failed and no user data, redirect to login
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
                      homeState.enteredFeed
                          ? const FriendSelect()
                          : const FriendTopbar(),
                      const MessButton(),
                    ],
                  ),
                ),
              ),
            ),
            body: PageView.builder(
              controller: _homeController.outerController,
              scrollDirection: Axis.vertical,
              itemCount: 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Stack(
                    children: [
                      // CAMERA REVIEW
                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppDimensions.md,
                          right: AppDimensions.md,
                          top: AppDimensions.appBarHeight + AppDimensions.xl,
                        ),
                        child: Camera(),
                      ),

                      // HISTORY BUTTON
                      Positioned(
                        bottom: AppDimensions.xl,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => _homeController.handleScrollPageViewOuter(1),
                          child: Center(child: HistoryFeed()),
                        ),
                      ),
                    ],
                  );
                }

                // FEEDS
                return ChangeNotifierProvider<FeedControllerState>(
                  create: (context) {
                    final controller = getIt<FeedController>();
                    return controller.state;
                  },
                  child: FeedPage(
                    innerController: _homeController.innerController,
                    outerController: _homeController.outerController,
                    handleScrollFeedToTop: () => _homeController.handleScrollPageViewOuter(0),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }
}
