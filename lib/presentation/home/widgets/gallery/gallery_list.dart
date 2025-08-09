import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:provider/provider.dart';

class GalleryList extends StatelessWidget {
  const GalleryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the controller from the route extra data
    final feedController = context.read<FeedController>();

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.md,
        right: AppDimensions.md,
        top: AppDimensions.appBarHeight,
      ),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: AppDimensions.appBarHeight),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: feedController.state.listFeed.length,
        itemBuilder: (_, index) {
          final imageUrl = feedController.state.listFeed[index].imageUrl;
          return GestureDetector(
            onTap: () {
              feedController.setPopImageIndex(index);
              AppNavigator.pop(context, index);
            },
            child: Hero(
              tag: imageUrl,
              child: RatioClip(
                radiusRatio: 0.15,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder:
                      (context, error, stackTrace) => const ColoredBox(
                        color: Colors.grey,
                        child: Center(child: Icon(Icons.broken_image)),
                      ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
