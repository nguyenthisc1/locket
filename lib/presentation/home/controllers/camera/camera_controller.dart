// ignore_for_file: avoid_print
import 'package:camera/camera.dart' as cam;
import 'package:locket/common/animations/fade_animation_controller.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
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

    if (_state.fadeController == null || _state.fadeController!.isDisposed) {
      _state.setFadeController(FadeAnimationController(vsync: _state));
    }

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
  Future<void> _initCameraController(
    cam.CameraDescription cameraDescription,
  ) async {
    // Safely dispose existing controller
    final existingController = _state.controller;
    if (existingController != null) {
      try {
        existingController.dispose();
      } catch (e) {
        print('Warning: Error disposing camera controller: $e');
      }
    }

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
      final hasFlash =
          cameraDescription.lensDirection == cam.CameraLensDirection.back;
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
      // First trigger fade out animation (if not disposed)
      if (_state.fadeController != null && !_state.fadeController!.isDisposed) {
        _state.fadeController!.fadeOut();

        // Small delay to let animation start
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final image = await _state.controller!.takePicture();
      _state.setImageFile(image);
      _state.setPictureTaken(true, DateTime.now());

      // Create draft feed via feed controller
      final isFrontCamera =
          _state.controller?.description.lensDirection ==
          cam.CameraLensDirection.front;
      _state.feedController.createDraftFeed(
        image.path,
        MediaType.image,
        image.name,
        isFrontCamera,
      );

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
      // Start camera recording
      await _state.controller!.startVideoRecording();

      // Set recording state with timestamp
      final now = DateTime.now();
      _state.setRecording(true);
      _state.setRecordingStartedAt(now);
      _state.clearError();

      print('Video recording started at: $now');
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
      _state.setRecording(false);
      _state.setRecordingStartedAt(null);
    } catch (e) {
      _logError('Start recording error', e.toString());
      _state.setRecording(false);
      _state.setRecordingStartedAt(null);
    }
  }

  /// Stop video recording
  Future<void> stopVideoRecording() async {
    if (!_state.hasCamera || !_state.isRecording) return;

    try {
      // Calculate recording duration
      final recordingDuration = _state.getCurrentRecordingDuration();
      final endTime = DateTime.now();

      // Stop camera recording
      final video = await _state.controller!.stopVideoRecording();

      // Update state with video file and duration
      _state.setVideoFile(video);
      _state.setRecording(false);
      _state.setRecordingDuration(recordingDuration);
      _state.setPictureTaken(true, endTime); // Mark as media captured

      // Create draft feed via feed controller
      final isFrontCamera =
          _state.controller?.description.lensDirection ==
          cam.CameraLensDirection.front;
      _state.feedController.createDraftFeed(
        video.path,
        MediaType.video,
        video.name,
        isFrontCamera,
      );

      print('Video recording stopped at: $endTime');
      print('Recording duration: ${_state.getFormattedRecordingDuration()}');
      print('Video saved: ${video.path}');
    } on cam.CameraException catch (e) {
      _logError(e.code, e.description);
      _state.setRecording(false);
    } catch (e) {
      _logError('Stop recording error', e.toString());
      _state.setRecording(false);
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
    _state.resetRecordingState();
    _state.clearError();

    // Reset fade animation to show camera preview again (if not disposed)
    if (_state.fadeController != null && !_state.fadeController!.isDisposed) {
      _state.fadeController!.fadeIn();
    }
    print(
      'Camera state reset completed. isPictureTaken: ${_state.isPictureTaken}',
    );
  }

  /// Cancel current draft (removes draft feed from list)
  void cancelDraft() {
    print('Canceling current draft...');

    // Remove draft feed from list if it exists
    _state.feedController.resetUploadState();

    // Reset camera state
    resetState();

    print('Draft canceled successfully');
  }

  /// Upload captured media (photo or video)
  Future<void> uploadMedia() async {
    if (!_state.isPictureTaken) {
      _logError('Upload error', 'No media captured to upload');
      return;
    }

    final mediaFile = _state.imageFile ?? _state.videoFile;
    if (mediaFile == null) {
      _logError('Upload error', 'No media file found');
      return;
    }

    try {
      // Determine media type
      final isVideo = _state.videoFile != null;
      final mediaType = isVideo ? 'video' : 'image';
      final fileName = mediaFile.name;
      final isFrontCamera =
          _state.controller?.description.lensDirection ==
          cam.CameraLensDirection.front;

      print('Uploading $mediaType: $fileName');

      // Upload via feed controller
      await _state.feedController.uploadMedia(
        mediaFile.path,
        fileName,
        mediaType,
        isFrontCamera,
      );

      // Reset state after successful upload (the feed controller handles the delay)
      Future.delayed(const Duration(seconds: 2), () {
        resetState();
      });
    } catch (e) {
      _logError('Upload exception', e.toString());
    }
  }

  /// Get current recording status for UI
  String getRecordingStatus() {
    if (!_state.isRecording) return 'Not recording';
    return 'Recording: ${_state.getFormattedRecordingDuration()}';
  }

  /// Check if recording has started
  bool get isRecordingStarted =>
      _state.isRecording && _state.recordingStartedAt != null;

  /// Check if recording duration exceeds limit (optional safety check)
  bool isRecordingOverLimit({Duration limit = const Duration(minutes: 5)}) {
    if (!_state.isRecording) return false;
    final duration = _state.getCurrentRecordingDuration();
    return duration != null && duration > limit;
  }

  /// Get recording progress as percentage (0.0 to 1.0) based on max duration
  double getRecordingProgress({
    Duration maxDuration = const Duration(minutes: 5),
  }) {
    final currentDuration = _state.getCurrentRecordingDuration();
    if (currentDuration == null) return 0.0;

    final progress =
        currentDuration.inMilliseconds / maxDuration.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  /// Force stop recording if needed (safety method)
  Future<void> forceStopRecording() async {
    if (_state.isRecording) {
      print('Force stopping recording...');
      await stopVideoRecording();
    }
  }

  /// Dispose resources
  void dispose() {
    // Force stop any ongoing recording before disposal
    if (_state.isRecording) {
      print('Warning: Disposing while recording is active, force stopping...');
      // Note: Can't await here in dispose, but try to stop
      _state.controller?.stopVideoRecording().catchError((e) {
        print('Error force stopping recording during dispose: $e');
        // Return a dummy XFile since we can't properly handle this in dispose
        return cam.XFile('');
      });
    }

    // Safely dispose camera controller
    if (_state.controller != null) {
      try {
        _state.controller!.dispose();
      } catch (e) {
        print('Warning: Error disposing camera controller: $e');
      }
    }
    // Note: Don't dispose fade controller here as it's managed by the state
    // and will be disposed in CameraControllerState.dispose()
  }
}
