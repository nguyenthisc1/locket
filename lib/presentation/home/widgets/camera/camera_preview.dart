import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

  const CameraPreviewWrapper({
    super.key,
    required this.controller,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.currentZoomLevel,
    required this.onZoomlevel,
    this.imageFile,
    this.isPictureTaken = false,
  });

  @override
  State<CameraPreviewWrapper> createState() => _CameraPreviewWrapperState();
}

class _CameraPreviewWrapperState extends State<CameraPreviewWrapper> {
  late double _currentZoomLevel;
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();
    _currentZoomLevel = widget.currentZoomLevel;
  }

  Future<void> _handleZoom(double zoom) async {
    setState(() {
      _currentZoomLevel = zoom;
    });
    await widget.onZoomlevel(zoom);
  }

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
                            // Add scale to match the preview scale
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
                        onScaleStart: (details) {
                          _baseScale = _currentZoomLevel;
                        },
                        onScaleUpdate: (details) {
                          double zoom = (_baseScale * details.scale).clamp(
                            1.0,
                            3.0,
                          );
                          _handleZoom(zoom);
                        },
                        child: CameraPreview(widget.controller),
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
                currentZoomLevel: _currentZoomLevel,
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
