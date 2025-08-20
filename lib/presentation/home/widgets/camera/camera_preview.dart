import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:locket/presentation/home/widgets/camera/video_preview.dart';
import 'package:provider/provider.dart';

import 'camera_controls.dart';

class CameraPreviewWrapper extends StatefulWidget {
  const CameraPreviewWrapper({super.key});

  @override
  State<CameraPreviewWrapper> createState() => _CameraPreviewWrapperState();
}

class _CameraPreviewWrapperState extends State<CameraPreviewWrapper> {
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
    // Access state via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();
    final isFrontCamera =
        cameraState.controller?.description.lensDirection ==
        cam.CameraLensDirection.front;

    return SizedBox(
      key: const ValueKey('image_preview'),
      width: double.infinity,
      height: _previewHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
        child: Transform(
          alignment: Alignment.center,
          transform:
              (isFrontCamera == true
                    ? Matrix4.rotationY(math.pi)
                    : Matrix4.identity())
                ..scale(1.2, 1.2),
          child:
              cameraState.imageFile != null
                  ? Image.file(
                    File(cameraState.imageFile!.path),
                    fit: BoxFit.cover,
                  )
                  : cameraState.videoFile != null
                  ? VideoPreview(
                    file: File(cameraState.videoFile!.path),
                    flip: isFrontCamera == true,
                  )
                  : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    // Access state and controller via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();
    final cameraController = context.read<CameraController>();

    // Safety check: ensure controller exists and is not disposed
    if (cameraState.controller == null ||
        !cameraState.controller!.value.isInitialized) {
      return SizedBox(
        key: const ValueKey('camera_preview_loading'),
        width: double.infinity,
        height: _previewHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

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
              final zoom = (cameraState.currentZoomLevel * details.scale).clamp(
                1.0,
                3.0,
              );
              cameraController.setZoom(zoom);
            },
            child: FadeTransition(
              opacity:
                  cameraState.fadeController?.animation ??
                  kAlwaysCompleteAnimation,
              child: cam.CameraPreview(cameraState.controller!),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPreview() {
    // Access state via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();

    // More precise logic for showing image preview
    final showImage =
        cameraState.isPictureTaken &&
        (cameraState.imageFile != null || cameraState.videoFile != null);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppDimensions.durationFast),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder:
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child: showImage ? _buildImagePreview() : _buildCameraPreview(),
    );
  }

  Widget _buildCameraControls() {
    // Access state via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: AppDimensions.durationFast),
      transitionBuilder:
          (child, animation) =>
              FadeTransition(opacity: animation, child: child),
      child:
          !cameraState.isPictureTaken
              ? Padding(
                key: const ValueKey('camera_controls'),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.lg,
                  vertical: AppDimensions.md,
                ),
                child: const CameraControls(),
              )
              : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }

  Widget _buildMessageField() {
    // Access state via provider - no props needed!
    final cameraState = context.watch<CameraControllerState>();

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
          cameraState.isPictureTaken
              ? SizedBox.expand(
                key: const ValueKey('text_field'),
                child: MessageField(
                  isVisibleBackdrop: true,
                  onChanged: cameraState.setCaption,
                  padding: const EdgeInsets.only(
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
