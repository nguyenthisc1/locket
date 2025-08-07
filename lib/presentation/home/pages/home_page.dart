import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/feed_controller.dart';
import 'package:locket/presentation/home/controllers/home_controller.dart';
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
  late final HomeControllerState _homeController;

  @override
  void initState() {
    super.initState();
    _homeController = HomeControllerState();
    _homeController.init();
  }

  /// Method to manually refresh user profile (e.g., for pull-to-refresh)
  /// You can call this method when implementing pull-to-refresh functionality
  // ignore: unused_element
  Future<void> _refreshProfile() async {
    await _homeController.refreshProfile();
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _homeController,
      builder: (context, child) {
        final userService = getIt<UserService>();
        
        // Show loading spinner while fetching profile
        if (_homeController.isLoadingProfile && !userService.isLoggedIn) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If profile fetch failed and no user data, redirect to login
        if (!_homeController.isLoadingProfile && 
            _homeController.hasProfileFetched && 
            !userService.isLoggedIn) {
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
                    _homeController.enteredFeed
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
                        onTap:
                            () => _homeController.handleScrollPageViewOuter(1),
                        child: Center(child: HistoryFeed()),
                      ),
                    ),
                  ],
                );
              }

              // FEEDS
              return ChangeNotifierProvider(
                create: (context) => FeedControllerState(),
                child: FeedPage(
                  innerController: _homeController.innerController,
                  outerController: _homeController.outerController,
                  handleScrollFeedToTop:
                      () => _homeController.handleScrollPageViewOuter(0),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
