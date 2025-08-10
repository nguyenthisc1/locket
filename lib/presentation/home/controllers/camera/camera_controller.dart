// ignore_for_file: avoid_print

import 'package:camera/camera.dart' as cam;
import 'package:locket/common/animations/fade_animation_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';

/// Business logic class for camera operations - uses CameraControllerState
class CameraController {
  final CameraControllerState _state;

  CameraController(this._state);

  // Getter for state
  CameraControllerState get state => _state;

  void _logError(String code, String? message) {
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
    _state.setError('$code${message != null ? ': $message' : ''}');
  }

  /// Initialize camera system
  Future<void> initialize() async {
    _state.setLoading(true);
    _state.clearError();
    
    // Dispose previous fade controller if exists
    _state.fadeController?.dispose();
    _state.setFadeController(FadeAnimationController(vsync: _state));

    try {
      final cameras = await cam.availableCameras();
      _state.setCameras(cameras);
      
      if (cameras.isNotEmpty) {
        // Use index 0 by default for safety, fallback if index 1 doesn't exist
        final selectedIndex = cameras.length > 1 ? 1 : 0;
        _state.setSelectedCameraIndex(selectedIndex);
        _state.setFlashOn(false);
        await _initCameraController(cameras[selectedIndex]);
      }
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Camera initialization error', e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  /// Initialize camera controller for specific camera
  Future<void> _initCameraController(cam.CameraDescription cameraDescription) async {
    _state.controller?.dispose();
    
    final controller = cam.CameraController(
      cameraDescription,
      cam.ResolutionPreset.high,
      enableAudio: false,
    );
    
    _state.setController(controller);

    try {
      await controller.initialize();
      _state.setInitialized(true);

      // Apply flash mode again only if supported
      final hasFlash = cameraDescription.lensDirection == cam.CameraLensDirection.back;
      if (_state.isFlashOn && hasFlash) {
        await controller.setFlashMode(cam.FlashMode.always);
      } else {
        await controller.setFlashMode(cam.FlashMode.off);
      }

      _state.setCurrentZoomLevel(1.0);
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
      _state.setInitialized(false);
    } catch (e) {
      _logError('Camera controller error', e.toString());
      _state.setInitialized(false);
    }
  }

  /// Switch between front and back camera
  Future<void> switchCamera() async {
    if (!_state.hasMultipleCameras) return;

    _state.setLoading(true);
    try {
      final newIndex = _state.selectedCameraIndex == 0 ? 1 : 0;
      _state.setSelectedCameraIndex(newIndex);
      await _initCameraController(_state.cameras[newIndex]);
    } catch (e) {
      _logError('Switch camera error', e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  /// Toggle flash on/off
  Future<void> toggleFlash() async {
    if (!_state.hasCamera || !_state.hasFlashSupport) return;

    try {
      final newFlashState = !_state.isFlashOn;
      await _state.controller!.setFlashMode(
        newFlashState ? cam.FlashMode.always : cam.FlashMode.off,
      );
      _state.setFlashOn(newFlashState);
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Flash toggle error', e.toString());
    }
  }

  /// Set zoom level
  Future<void> setZoom(double zoomLevel) async {
    if (!_state.hasCamera) return;

    try {
      await _state.controller!.setZoomLevel(zoomLevel);
      _state.setCurrentZoomLevel(zoomLevel);
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Zoom error', e.toString());
    }
  }

  /// Take a picture
  Future<void> takePicture() async {
    if (!_state.hasCamera || _state.isRecording) return;

    try {
      // First trigger fade out animation
      _state.fadeController?.fadeOut();
      
      // Small delay to let animation start
      await Future.delayed(const Duration(milliseconds: 100));
      
      final image = await _state.controller!.takePicture();
      _state.setImageFile(image);
      _state.setPictureTaken(true, DateTime.now());
      
      print('Picture taken successfully: ${image.path}');
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Take picture error', e.toString());
    }
  }

  /// Start video recording
  Future<void> startVideoRecording() async {
    if (!_state.hasCamera || _state.isRecording) return;

    try {
      await _state.controller!.startVideoRecording();
      _state.setRecording(true);
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Start recording error', e.toString());
    }
  }

  /// Stop video recording
  Future<void> stopVideoRecording() async {
    if (!_state.hasCamera || !_state.isRecording) return;

    try {
      final video = await _state.controller!.stopVideoRecording();
      _state.setVideoFile(video);
      _state.setRecording(false);
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Stop recording error', e.toString());
    }
  }

  /// Handle camera permission
  Future<void> handleCameraPermission() async {
    // Implement permission logic here if needed
    try {
      await initialize();
    } catch (e) {
      _logError('Permission error', e.toString());
    }
  }

  /// Reset camera state
  void resetState() {
    print('Resetting camera state...');
    _state.resetPictureTakenState();
    _state.clearError();
    
    // Reset fade animation to show camera preview again
    _state.fadeController?.fadeIn();
    print('Camera state reset completed. isPictureTaken: ${_state.isPictureTaken}');
  }

  /// Dispose resources
  void dispose() {
    _state.controller?.dispose();
    _state.fadeController?.dispose();
  }
}
