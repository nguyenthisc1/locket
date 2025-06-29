import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'camera_controls.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final bool isFlashOn;
  final double currentZoomLevel;
  final VoidCallback onFlashToggle;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    required this.isFlashOn,
    required this.currentZoomLevel,
    required this.onFlashToggle,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.45,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            child: Transform.scale(
              scaleY: 2,
              scaleX: 1.1,
              child: CameraPreview(controller),
            ),
          ),
        ),
        Positioned(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.md,
            ),
            child: CameraControls(
              isFlashOn: isFlashOn,
              currentZoomLevel: currentZoomLevel,
              onFlashToggle: onFlashToggle,
              onZoomIn: onZoomIn,
              onZoomOut: onZoomOut,
            ),
          ),
        ),
      ],
    );
  }
}
