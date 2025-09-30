import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedVideo extends StatefulWidget {
  final String videoUrl;
  final String? heroTag;
  final bool isFront;
  final bool autoplay;

  const FeedVideo({
    super.key,
    this.heroTag,
    required this.videoUrl,
    required this.isFront,
    this.autoplay = true,
  });

  @override
  State<FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends State<FeedVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  void _initializeVideoController() {
    // Check if it's a local file or network URL
    String videoPath = widget.videoUrl;

    if (_isLocalFilePath(widget.videoUrl)) {
      videoPath = _getActualFilePath(widget.videoUrl);
      print('Loading local video: $videoPath');
      
      // Validate that the file path is not empty
      if (videoPath.isEmpty) {
        print('Error: Empty video path after processing videoUrl: ${widget.videoUrl}');
        setState(() {
          _hasError = true;
        });
        return;
      }
      
      _controller = VideoPlayerController.file(File(videoPath));
    } else {
      print('Loading network video: $videoPath');
      _controller = VideoPlayerController.network(videoPath);
    }

    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
            });
            _controller.setLooping(true);
            if (widget.autoplay) {
              _controller.play();
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _hasError = true;
            });
          }
          print('Video player error: $error');
        });
  }

  bool _isLocalFilePath(String path) {
    // Check if it's a local file path or has local prefix
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.heroTag != null
        ? Hero(tag: widget.heroTag!, child: _buildVideoContent())
        : _buildVideoContent();
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error, color: Colors.red, size: 50),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Transform(
      alignment: Alignment.center,
      transform:
          widget.isFront
              ? (Matrix4.identity()
                ..scale(-1.0, 1.5)
                ..scale(1.0, 1.1))
              : (Matrix4.identity()..scale(1.0, 1.65)),
      child: VideoPlayer(_controller),
    );
  }
}
