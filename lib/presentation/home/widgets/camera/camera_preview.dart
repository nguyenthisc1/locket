import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:locket/common/animations/fade_animation_controller.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/widgets/camera/video_preview.dart';

import 'camera_controls.dart';

class CameraPreviewWrapper extends StatefulWidget {
  final cam.CameraController controller;
  final bool isFlashOn;
  final VoidCallback onFlashToggle;
  final double currentZoomLevel;
  final Future<void> Function(double) onZoomlevel;
  final cam.XFile? imageFile;
  final cam.XFile? videoFile;
  final bool isPictureTaken;
  final FadeAnimationController? fadeController;

  const CameraPreviewWrapper({
    super.key,
    required this.controller,
    required this.isFlashOn,
    required this.onFlashToggle,
    required this.currentZoomLevel,
    required this.onZoomlevel,
    required this.fadeController,
    this.imageFile,
    this.videoFile,
    this.isPictureTaken = false,
  });

  @override
  State<CameraPreviewWrapper> createState() => _CameraPreviewWrapperState();
}

class _CameraPreviewWrapperState extends State<CameraPreviewWrapper> {
  bool get _isFrontCamera =>
      widget.controller.description.lensDirection == cam.CameraLensDirection.front;

  double get _previewHeight => MediaQuery.of(context).size.height * 0.45;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildAnimatedPreview(),
        Positioned(child: _buildCameraControls()),
        Positioned.fill(left: 0, right: 0, child: _buildMessageField()),
      ],
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      key: const ValueKey('image_preview'),
      width: double.infinity,
      height: _previewHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: Transform(
          alignment: Alignment.center,
          transform:
              (_isFrontCamera ? Matrix4.rotationY(math.pi) : Matrix4.identity())
                ..scale(1.2, 1.2),
          child:
              widget.imageFile != null
                  ? Image.file(File(widget.imageFile!.path), fit: BoxFit.cover)
                  : widget.videoFile != null
                  ? VideoPreview(
                    file: File(widget.videoFile!.path),
                    flip: _isFrontCamera,
                  )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return SizedBox(
      key: const ValueKey('camera_preview'),
      width: double.infinity,
      height: _previewHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: Transform.scale(
          scaleX: 1.2,
          scaleY: 2,
          child: GestureDetector(
            onScaleUpdate: (details) {
              final zoom = (widget.currentZoomLevel * details.scale).clamp(
                1.0,
                3.0,
              );
              widget.onZoomlevel(zoom);
            },
            child: FadeTransition(
              opacity:
                  widget.fadeController?.animation ?? kAlwaysCompleteAnimation,
              child: cam.CameraPreview(widget.controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPreview() {
    // More precise logic for showing image preview
    final showImage = widget.isPictureTaken && 
        (widget.imageFile != null || widget.videoFile != null);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppDimensions.durationFast),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: showImage ? _buildImagePreview() : _buildCameraPreview(),
    );
  }

  Widget _buildCameraControls() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppDimensions.durationFast),
      transitionBuilder:
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child:
          !widget.isPictureTaken
              ? Padding(
                key: const ValueKey('camera_controls'),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.md,
                ),
                child: CameraControls(
                  isFlashOn: widget.isFlashOn,
                  currentZoomLevel: widget.currentZoomLevel,
                  onFlashToggle: widget.onFlashToggle,
                ),
              )
              : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }

  Widget _buildMessageField() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppDimensions.durationFast),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: child,
          ),
        );
      },
      child:
          widget.isPictureTaken
              ? SizedBox.expand(
                key: const ValueKey('text_field'),
                child: const MessageField(
                  isVisibleBackdrop: true,
                  padding: EdgeInsets.only(
                    left: AppDimensions.lg,
                    right: AppDimensions.lg,
                    bottom: AppDimensions.md,
                  ),
                ),
              )
              : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}
