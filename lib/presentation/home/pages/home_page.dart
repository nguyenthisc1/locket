import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/widgets/camera/index.dart';
import 'package:locket/presentation/home/widgets/feed/feed.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';
import 'package:locket/presentation/home/widgets/user_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _outerController = PageController();
  final PageController _innerController = PageController();

  void _scrollFeedToTop() {
    if (_outerController.hasClients) {
      _outerController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
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
              // ignore: prefer_const_constructors
              spacing: AppDimensions.md,
              children: const [UserImage(), FriendTopbar(), MessButton()],
            ),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _outerController,
        scrollDirection: Axis.vertical,
        itemCount: 2,
        itemBuilder: (context, index) {
          // CAMERA REVIEW
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.md,
                right: AppDimensions.md,
                top: AppDimensions.appBarHeight + AppDimensions.xl,
              ),
              child: Camera(),
            );
          }

          // FEEDS
          return Feed(
            innerController: _innerController,
            outerController: _outerController,
            onScrollToTop: _scrollFeedToTop,
          );
        },
      ),
    );
  }
}
