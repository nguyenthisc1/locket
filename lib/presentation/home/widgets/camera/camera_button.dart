import 'dart:async';

import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/common/wigets/take_button.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:provider/provider.dart';

class CameraButton extends StatefulWidget {
  const CameraButton({super.key});

  @override
  State<CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  bool _isLongPress = false;
  int _longPressCount = 0;
  static const int _maxLongPress = 5;
  static const Duration _maxLongPressDuration = Duration(seconds: 5);
  Timer? _longPressTimer;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: _maxLongPressDuration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // onRecordComplete - handled automatically
        _progressController.reset();
        _handleLongPressEnd(force: true);
      }
    });
  }

  void _handleLongPressStart() {
    if (_longPressCount >= _maxLongPress) {
      _handleLongPressEnd(force: true);
      return;
    }
    
    // Access controller via provider - no props needed!
    final cameraController = Provider.of<CameraController>(context, listen: false);
    cameraController.startVideoRecording();
    
    _progressController.forward(from: 0);
    setState(() {
      _isLongPress = true;
      _longPressCount++;
    });

    _longPressTimer?.cancel();
    _longPressTimer = Timer(_maxLongPressDuration, () {
      if (_isLongPress) {
        _handleLongPressEnd(force: true);
      }
    });
  }

  void _handleLongPressEnd({bool force = false}) {
    if (!_isLongPress && !force) return;
    
    // Access controller via provider - no props needed!
    final cameraController = Provider.of<CameraController>(context, listen: false);
    cameraController.stopVideoRecording();
    
    _progressController.reset();
    _longPressTimer?.cancel();
    setState(() {
      _isLongPress = false;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double baseSize = AppDimensions.xxl;
    final double press = _isLongPress ? baseSize * 1.5 : baseSize * 2;

    return Consumer<CameraController>(
      builder: (context, cameraController, child) {
        return GestureDetector(
          onTap: cameraController.takePicture,
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
      },
    );
  }
}
