import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/common/wigets/take_button.dart';

class CameraButton extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onRecordStart;
  final VoidCallback onRecordEnd;
  final VoidCallback onRecordComplete;

  const CameraButton({
    super.key,
    required this.onTap,
    required this.onRecordStart,
    required this.onRecordEnd,
    required this.onRecordComplete,
  });

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  bool _isLongPress = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRecordComplete();
        _progressController.reset();
      }
    });
  }

  void _handleLongPressStart() {
    widget.onRecordStart();
    _progressController.forward(from: 0);
    setState(() {
      _isLongPress = true;
    });
  }

  void _handleLongPressEnd() {
    widget.onRecordEnd();
    _progressController.reset();
    setState(() {
      _isLongPress = false;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = AppDimensions.xxl;
    final double press = _isLongPress ? baseSize * 1.5 : baseSize * 2;

    return GestureDetector(
      onTap: widget.onTap,
      onLongPressStart: (_) => _handleLongPressStart(),
      onLongPressEnd: (_) => _handleLongPressEnd(),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, _) {
          return TakeButton(
            size: press,
            progress: _progressController,
            isSizeSync: false,
          );
        },
      ),
    );
  }
}
