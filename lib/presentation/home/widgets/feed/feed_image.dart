import 'dart:io';
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
      child = _buildImageWidget();
    } else if (format == 'mp4') {
      child = FeedVideo(videoUrl: imageUrl, isFront: isFront);
    } else {
      child = const Center(child: Text('Unsupported format'));
    }

    return Transform(
      alignment: Alignment.center,
      transform:
          isFront ? Matrix4.rotationY(math.pi) : Matrix4.identity()
            ..scale(1.2, 1.2),
      child: child,
    );
  }

  Widget _buildImageWidget() {
    // Check if it's a local file path or network URL
    if (_isLocalFilePath(imageUrl)) {
      final filePath = _getActualFilePath(imageUrl);
      print('Loading local image: $filePath');
      
      // Validate that the file path is not empty
      if (filePath.isEmpty) {
        print('Error: Empty file path after processing imageUrl: $imageUrl');
        return const Center(
          child: Icon(Icons.error, color: Colors.red, size: 50),
        );
      }
      
      return Image.file(
        File(filePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading local image: $error');
          return const Center(
            child: Icon(Icons.error, color: Colors.red, size: 50),
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading network image: $error');
          return const Center(
            child: Icon(Icons.error, color: Colors.red, size: 50),
          );
        },
      );
    }
  }

  bool _isLocalFilePath(String path) {
    // Check if it's a local file path or has our local prefix
    // Accepts various local prefixes for compatibility
    return path.startsWith('local://') || // New format
        path.startsWith('local:///') ||
        path.startsWith('local:////') ||
        path.startsWith('/') ||
        path.startsWith('file://') ||
        path.contains('/var/mobile/') ||
        path.contains('/Documents/') ||
        !path.startsWith('http');
  }

  String _getActualFilePath(String path) {
    // Remove prefixes and handle malformed URIs
    String cleanPath = path;
    
    // Handle various local prefix formats
    if (cleanPath.startsWith('local:////')) {
      cleanPath = cleanPath.substring(10); // Remove 'local:////' prefix
    } else if (cleanPath.startsWith('local:///')) {
      cleanPath = cleanPath.substring(9); // Remove 'local:///' prefix
    } else if (cleanPath.startsWith('local://')) {
      cleanPath = cleanPath.substring(8); // Remove 'local://' prefix (new format)
    } else if (cleanPath.startsWith('file:///')) {
      cleanPath = cleanPath.substring(8); // Remove 'file:///' prefix
    } else if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.substring(7); // Remove 'file://' prefix
    }
    
    // Handle case where path starts with additional slashes
    while (cleanPath.startsWith('//')) {
      cleanPath = cleanPath.substring(1);
    }
    
    // Ensure we have an absolute path
    if (cleanPath.isNotEmpty && !cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    
    return cleanPath;
  }
}
