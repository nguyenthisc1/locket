import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/presentation/home/widgets/camera/index.dart';
import 'package:locket/presentation/home/widgets/feed/feed.dart';
import 'package:locket/presentation/home/widgets/friend_toolbar.dart';
import 'package:locket/presentation/home/widgets/friend_topbar.dart';
import 'package:locket/presentation/home/widgets/mess_button.dart';
import 'package:locket/presentation/home/widgets/user_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int _pageCount = 5;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const BasicAppbar(
        hideBack: true,
        action: Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: AppDimensions.md,
              right: AppDimensions.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: AppDimensions.md,
              children: [UserImage(), FriendTopbar(), MessButton()],
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: _pageCount,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
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
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: AppDimensions.md,
                      right: AppDimensions.md,
                      top: AppDimensions.appBarHeight + AppDimensions.xl,
                    ),
                    child: Feed(),
                  );
                },
              ),
            ),
            // Show FriendToolbar if _currentPage < 0
            if (_currentPage < 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.md,
                    right: AppDimensions.md,
                    bottom: AppDimensions.xl,
                  ),
                  child: FriendToolbar(),
                ),
              ),
            // Always show count indicator
            Positioned(
              top: AppDimensions.appBarHeight + AppDimensions.md,
              right: AppDimensions.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentPage + 1}/$_pageCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Show FriendToolbar at bottom if _currentPage >= 0 (default behavior)
            if (_currentPage > 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.md,
                    right: AppDimensions.md,
                    bottom: AppDimensions.xl,
                  ),
                  child: FriendToolbar(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
