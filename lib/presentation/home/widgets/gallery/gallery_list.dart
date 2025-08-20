import 'package:flutter/material.dart';
import 'package:locket/common/helper/navigation/app_navigation.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:provider/provider.dart';
import 'package:locket/presentation/home/widgets/feed/feed_video.dart';

class GalleryList extends StatelessWidget {
  const GalleryList({super.key});

  @override
  Widget build(BuildContext context) {
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
          final feed = feedController.state.listFeed[index];
          final imageUrl = feed.imageUrl;
          final mediaType = feed.mediaType;

          Widget buildImage() {
            return Image.network(
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
            );
          }

          Widget buildVideo() {
            return FeedVideo(
              videoUrl: imageUrl,
              isFront: feed.isFrontCamera,
              autoplay: false,
            );
          }

          Widget mediaWidget;
          if (mediaType == MediaType.video) {
            mediaWidget = buildVideo();
          } else {
            mediaWidget = buildImage();
          }

          return GestureDetector(
            onTap: () {
              feedController.setPopImageIndex(index);
              AppNavigator.pop(context, index);
            },
            child: Hero(
              tag: imageUrl,
              child: RatioClip(radiusRatio: 0.15, child: mediaWidget),
            ),
          );
        },
      ),
    );
  }
}
