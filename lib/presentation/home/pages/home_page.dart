import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/user/repositories/user_repository_impl.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';
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
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _homeController = HomeControllerState();
    _homeController.init();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userService = getIt<UserService>();
    
    // First try to load cached user data
    await userService.loadUserFromStorage();
    
    // If we have cached user data, set loading to false
    if (userService.isLoggedIn) {
      setState(() {
        _isLoadingProfile = false;
      });
    }
    
    // Then fetch fresh profile data from API (even if cached data exists)
    await _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final userRepository = getIt<UserRepositoryImpl>();
      final getProfileUsecase = GetProfileUsecase(userRepository);
      
      final result = await getProfileUsecase();
      
      result.fold(
        (failure) {
          print('Failed to fetch profile: ${failure.message}');
          final userService = getIt<UserService>();
          if (!userService.isLoggedIn) {
            AppNavigator.pushAndRemove(context, '/login');
          }
        },
        (response) {
          print('Profile fetched successfully');
        },
      );
    } catch (e) {
      print('Error fetching profile: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = getIt<UserService>();
    
    // Show loading spinner while fetching profile
    if (_isLoadingProfile && !userService.isLoggedIn) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _homeController,
      builder: (context, child) {
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
                  images: _homeController.gallery,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
