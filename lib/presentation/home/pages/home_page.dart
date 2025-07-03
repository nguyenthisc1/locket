import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/widgets/camera/index.dart';
import 'package:locket/presentation/home/widgets/feed/feed.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/history_feed.dart';
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

  int _currentOuterPage = 0;
  bool _enteredFeed = false;

  @override
  void initState() {
    super.initState();
    _outerController.addListener(_outerPageListener);
  }

  void _outerPageListener() {
    final int newPage =
        _outerController.hasClients ? _outerController.page?.round() ?? 0 : 0;

    if (newPage != _currentOuterPage) {
      if (_currentOuterPage == 0 && newPage == 1) {
        setState(() {
          _enteredFeed = true;
        });
      }

      if (_currentOuterPage == 1 && newPage == 0) {
        setState(() {
          _enteredFeed = false;
        });
      }

      _currentOuterPage = newPage;
    }
  }

  void _handleScrollPageViewOuter(int page) {
    if (_outerController.hasClients) {
      _outerController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _outerController.removeListener(_outerPageListener);
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
              children: [
                const UserImage(),
                FriendTopbar(isEnteredFeed: _enteredFeed),
                const MessButton(),
              ],
            ),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _outerController,
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
                    onTap: () => _handleScrollPageViewOuter(1),
                    child: Center(child: HistoryFeed()),
                  ),
                ),
              ],
            );
          }

          // FEEDS
          return Feed(
            innerController: _innerController,
            outerController: _outerController,
            handleScrollFeedToTop: () => _handleScrollPageViewOuter(0),
          );
        },
      ),
    );
  }
}
