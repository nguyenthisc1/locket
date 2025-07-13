import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';
import '../../controllers/camera_controller.dart';
import 'camera_preview.dart';
import 'camera_bottom_controls.dart';

class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  late final CameraControllerState _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = CameraControllerState();
    _cameraController.initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (_cameraController.controller == null ||
        !_cameraController.controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      // App is in background
      _cameraController.controller?.dispose();
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
    return ListenableBuilder(
      listenable: _cameraController,
      builder: (context, child) {
        if (!_cameraController.isInitialized) {
          return _buildLoadingState();
        }

        return Column(
          children: [
            CameraPreviewWrapper(
              controller: _cameraController.controller!,
              isFlashOn: _cameraController.isFlashOn,
              currentZoomLevel: _cameraController.currentZoomLevel,
              onFlashToggle: _cameraController.toggleFlash,
              onZoomlevel: _cameraController.setZoomLevel,
              isPictureTaken: _cameraController.isPictureTaken,
              imageFile: _cameraController.imageFile,
            ),

            const SizedBox(height: AppDimensions.xxl),

            CameraBottomControls(
              onLibraryTap: _onLibraryTap,
              onTakePicture: _cameraController.takePicture,
              onResetPicture: _cameraController.resetPictureTakenState,
              onStartRecording: _cameraController.startRecording,
              onStopRecording: _cameraController.stopRecording,
              onSwitchCamera: _cameraController.switchCamera,
              isPictureTaken: _cameraController.isPictureTaken,
            ),
          ],
        );
      },
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
