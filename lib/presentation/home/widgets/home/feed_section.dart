import 'package:flutter/material.dart';
import 'package:locket/presentation/home/pages/feed_page.dart';

class FeedSection extends StatelessWidget {
  final PageController innerController;
  final PageController outerController;
  final VoidCallback onScrollFeedToTop;

  const FeedSection({
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
