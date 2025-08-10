import 'package:flutter/material.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:locket/presentation/home/widgets/feed/feed_video.dart';

class FeedImage extends StatelessWidget {
  final String imageUrl;
  final String format;

  const FeedImage({
    super.key,
    required this.imageUrl,
    required this.format,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Hero(
        tag: imageUrl,
        child: RatioClip(
          radiusRatio: 0.15,
          child: _buildMediaWidget(),
        ),
      ),
    );
  }

  Widget _buildMediaWidget() {
    if (format == 'jpg') {
      return Image.network(imageUrl, fit: BoxFit.cover);
    } else if (format == 'mp4') {
      return FeedVideo(videoUrl: imageUrl);
    } else {
      return const Center(child: Text('Unsupported format'));
    }
  }
}
