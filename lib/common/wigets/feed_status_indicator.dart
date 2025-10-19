import 'package:flutter/material.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';

/// Widget to display feed upload status indicators
class FeedStatusIndicator extends StatelessWidget {
  final FeedStatus status;
  final double size;
  final Color? color;

  const FeedStatusIndicator({
    Key? key,
    required this.status,
    this.size = 16.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case FeedStatus.draft:
        return _buildDraftIndicator();
      case FeedStatus.uploading:
        return _buildUploadingIndicator();
      case FeedStatus.uploaded:
        return _buildUploadedIndicator();
      case FeedStatus.failed:
        return _buildFailedIndicator();
    }
  }

  Widget _buildDraftIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade400,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.edit_outlined, size: size * 0.6, color: Colors.white),
    );
  }

  Widget _buildUploadingIndicator() {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }

  Widget _buildUploadedIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      child: Icon(Icons.check, size: size * 0.6, color: Colors.white),
    );
  }

  Widget _buildFailedIndicator() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      child: Icon(Icons.error_outline, size: size * 0.6, color: Colors.white),
    );
  }
}

/// Helper widget to show status text
class FeedStatusText extends StatelessWidget {
  final FeedStatus status;

  const FeedStatusText({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (status) {
      case FeedStatus.draft:
        text = 'Draft';
        color = Colors.grey;
        break;
      case FeedStatus.uploading:
        text = 'Uploading...';
        color = Colors.blue;
        break;
      case FeedStatus.uploaded:
        text = 'Uploaded';
        color = Colors.green;
        break;
      case FeedStatus.failed:
        text = 'Upload Failed';
        color = Colors.red;
        break;
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}

/// Combined status indicator with text
class FeedStatusDisplay extends StatelessWidget {
  final FeedStatus status;
  final double iconSize;
  final bool showText;

  const FeedStatusDisplay({
    super.key,
    required this.status,
    this.iconSize = 16.0,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showText) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FeedStatusIndicator(status: status, size: iconSize),
          const SizedBox(width: 6),
          FeedStatusText(status: status),
        ],
      );
    } else {
      return FeedStatusIndicator(status: status, size: iconSize);
    }
  }
}
