import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/presentation/home/controllers/feed_controller.dart';
import 'package:provider/provider.dart';

class GalleryList extends StatelessWidget {
  const GalleryList({super.key});

  @override
  Widget build(BuildContext context) {
    final feedController = context.read<FeedControllerState>();

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
        itemCount: feedController.listFeed.length,
        itemBuilder: (_, index) {
          final imageUrl = feedController.listFeed[index].imageUrl;
          return GestureDetector(
            onTap:
                () => {
                  feedController.setPopImageIndex(index),
                  AppNavigator.pop(context, index),
                },
            child: Hero(
              tag: imageUrl,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl * 0.8),
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
