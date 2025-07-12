import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/controllers/home_controller.dart';
import 'package:locket/presentation/home/widgets/camera/index.dart';
import 'package:locket/presentation/home/widgets/feed/feed.dart';
import 'package:locket/presentation/home/widgets/friend_select.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/history_feed.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';

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
              return Feed(
                innerController: _homeController.innerController,
                outerController: _homeController.outerController,
                handleScrollFeedToTop:
                    () => _homeController.handleScrollPageViewOuter(0),
              );
            },
          ),
        );
      },
    );
  }
}
