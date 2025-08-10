import 'package:flutter/material.dart';
import 'package:locket/common/wigets/ratio_clip.dart';
import 'package:video_player/video_player.dart';

class FeedVideo extends StatefulWidget {
  final String videoUrl;
  final String? heroTag;

  const FeedVideo({super.key, required this.videoUrl, this.heroTag});

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
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      child: widget.heroTag != null
          ? Hero(
              tag: widget.heroTag!,
              child: _buildVideoContent(),
            )
          : _buildVideoContent(),
    );
  }

  Widget _buildVideoContent() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return RatioClip(
      radiusRatio: 0.15,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_controller.value.isPlaying)
            IconButton(
              icon: const Icon(Icons.play_arrow, size: 48, color: Colors.white),
              onPressed: () {
                setState(() {
                  _controller.play();
                });
              },
            ),
        ],
      ),
    );
  }
}