import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/di.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:provider/provider.dart';
import 'camera_preview.dart';
import 'camera_bottom_controls.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  late final CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = getIt<CameraController>();
    _cameraController.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_cameraController.state.controller == null ||
        !_cameraController.state.controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      // App is in background
      _cameraController.state.controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // App is in foreground
      _cameraController.initialize();
    }
  }

  void _onLibraryTap() {
    // TODO: Implement gallery access
  }

  @override
  void dispose() {
    _cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CameraControllerState>.value(
      value: _cameraController.state,
      child: Consumer<CameraControllerState>(
        builder: (context, cameraState, child) {
          if (!cameraState.isInitialized) {
            return _buildLoadingState();
          }

          return Column(
            children: [
              CameraPreviewWrapper(
                controller: cameraState.controller!,
                isFlashOn: cameraState.isFlashOn,
                currentZoomLevel: cameraState.currentZoomLevel,
                onFlashToggle: _cameraController.toggleFlash,
                onZoomlevel: _cameraController.setZoom,
                isPictureTaken: cameraState.isPictureTaken,
                imageFile: cameraState.imageFile,
                videoFile: cameraState.videoFile,
                fadeController: cameraState.fadeController,
              ),

              const SizedBox(height: AppDimensions.xxl),

              CameraBottomControls(
                onLibraryTap: _onLibraryTap,
                onTakePicture: _cameraController.takePicture,
                onResetPicture: _cameraController.resetState,
                onStartRecording: _cameraController.startVideoRecording,
                onStopRecording: _cameraController.stopVideoRecording,
                onSwitchCamera: _cameraController.switchCamera,
                onUploadMedia: _cameraController.quickUpload,
                isPictureTaken: cameraState.isPictureTaken,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
