import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FeedVideo extends StatefulWidget {
  final String videoUrl;
  final String? heroTag;
  final bool isFront;

  const FeedVideo({super.key, required this.videoUrl, this.heroTag, required this.isFront});

  @override
  State<FeedVideo> createState() => _FeedVideoState();
}

class _FeedVideoState extends State<FeedVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
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
    return widget.heroTag != null
        ? Hero(tag: widget.heroTag!, child: _buildVideoContent())
        : _buildVideoContent();
  }

  Widget _buildVideoContent() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Transform(
      alignment: Alignment.center,
       transform:  
             widget.isFront ? (Matrix4.identity()
                ..scale(-1.0, 1.65)
                ..scale(1.0, 1.3))
              : (Matrix4.identity()..scale(1.0, 1.65)),
      child: VideoPlayer(_controller),
    );

  }
}
