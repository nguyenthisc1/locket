import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final File file;
  final bool flip;
  const VideoPreview({super.key, required this.file, this.flip = false});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Transform(
      alignment: Alignment.center,
      transform:
          widget.flip
              ? (Matrix4.identity()
                ..scale(-1.0, 1.0)
                ..scale(1.0, 1.65))
              : (Matrix4.identity()..scale(1.0, 1.65)),
      child: VideoPlayer(_controller),
    );
  }
}
