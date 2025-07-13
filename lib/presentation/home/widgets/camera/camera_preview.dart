import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:locket/common/animations/fade_animation_controller.dart';
import 'package:locket/core/configs/theme/index.dart';

import 'camera_controls.dart';

class CameraPreviewWrapper extends StatefulWidget {
  final CameraController controller;
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final double currentZoomLevel;
  final Future<void> Function(double) onZoomlevel;
  final XFile? imageFile;
  final bool isPictureTaken;
  final FadeAnimationController? fadeController;

  const CameraPreviewWrapper({
    super.key,
    required this.controller,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.currentZoomLevel,
    required this.onZoomlevel,
    this.imageFile,
    this.isPictureTaken = false,
    required this.fadeController,
  });

  @override
  State<CameraPreviewWrapper> createState() => _CameraPreviewWrapperState();
}

class _CameraPreviewWrapperState extends State<CameraPreviewWrapper> {
  @override
  Widget build(BuildContext context) {
    final bool isFrontCamera =
        widget.controller.description.lensDirection ==
        CameraLensDirection.front;

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.45,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            child:
                widget.imageFile != null
                    ? Transform(
                      alignment: Alignment.center,
                      transform:
                          (isFrontCamera
                                ? Matrix4.rotationY(math.pi)
                                : Matrix4.identity())
                            ..scale(1.2, 1.2),
                      child: Image.file(
                        File(widget.imageFile!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                    : Transform.scale(
                      scaleX: 1.2,
                      scaleY: 2,
                      child: GestureDetector(
                        onScaleUpdate: (details) {
                          double zoom = (widget.currentZoomLevel *
                                  details.scale)
                              .clamp(1.0, 3.0);
                          widget.onZoomlevel(zoom);
                        },
                        child: FadeTransition(
                          opacity: widget.fadeController!.animation,
                          child: CameraPreview(widget.controller),
                        ),
                      ),
                    ),
          ),
        ),
        if (!widget.isPictureTaken)
          Positioned(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              child: CameraControls(
                isFlashOn: widget.isFlashOn,
                currentZoomLevel: widget.currentZoomLevel,
                onFlashToggle: widget.onFlashToggle,
              ),
            ),
          ),
        // if (widget.isPictureTaken)
        //   Positioned(
        //     bottom: 0,
        //     child: TextField(
        //       decoration: InputDecoration(label: Text('Message')),
        //     ),
        //   ),
      ],
    );
  }
}
