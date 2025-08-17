import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:locket/presentation/home/widgets/feed/feed_video.dart';

class FeedImage extends StatelessWidget {
  final String imageUrl;
  final String format;
  final bool isFront;

  const FeedImage({
    super.key,
    required this.imageUrl,
    required this.format,
    required this.isFront,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: Hero(
        tag: imageUrl,
        child: RatioClip(radiusRatio: 0.15, child: _buildMediaWidget()),
      ),
    );
  }

  Widget _buildMediaWidget() {
    Widget child;
    if (format == 'jpg') {
      child = Image.network(imageUrl, fit: BoxFit.cover);
    } else if (format == 'mp4') {
      child =   FeedVideo(videoUrl: imageUrl, isFront: isFront);
    } else {
      child = const Center(child: Text('Unsupported format'));
    }

    return Transform(
      alignment: Alignment.center,
      transform: isFront ? Matrix4.rotationY(math.pi) : Matrix4.identity(),
      child: child,
    );
  }
}
