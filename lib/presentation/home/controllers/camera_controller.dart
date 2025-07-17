// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:locket/common/animations/fade_animation_controller.dart';

class CameraControllerState extends ChangeNotifier implements TickerProvider {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isFlashOn = false;
  double _currentZoomLevel = 1.0;
  XFile? _imageFile;
  XFile? _videoFile;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isPictureTaken = false;
  DateTime? _pictureTakenAt;

  FadeAnimationController? _fadeController;

  // Getters
  List<CameraDescription> get cameras => _cameras;
  CameraController? get controller => _controller;
  int get selectedCameraIndex => _selectedCameraIndex;
  bool get isFlashOn => _isFlashOn;
  double get currentZoomLevel => _currentZoomLevel;
  XFile? get imageFile => _imageFile;
  XFile? get videoFile => _videoFile;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  bool get isPictureTaken => _isPictureTaken;
  DateTime? get pictureTakenAt => _pictureTakenAt;

  // Animation getter
  FadeAnimationController? get fadeController => _fadeController;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  void resetPictureTakenState() {
    _imageFile = null;
    _videoFile = null;
    _isPictureTaken = false;
    _pictureTakenAt = null;
    notifyListeners();
  }

  Future<void> initialize() async {
    // Dispose previous fade controller if exists
    _fadeController?.dispose();
    _fadeController = FadeAnimationController(vsync: this);

    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Use index 0 by default for safety, fallback if index 1 doesn't exist
        _selectedCameraIndex = _cameras.length > 1 ? 1 : 0;
        _isFlashOn = false;
        await _initCameraController(_cameras[_selectedCameraIndex]);
      }
    } on CameraException catch (e) {
      _logError(e.code, e.description);
    } catch (e) {
      _logError('Camera initialization error', e.toString());
    }
  }

  Future<void> _initCameraController(
    CameraDescription cameraDescription,
  ) async {
    _controller?.dispose();
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();

      _isInitialized = true;

      // Apply flash mode again only if supported
      final hasFlash =
          cameraDescription.lensDirection == CameraLensDirection.back;
      if (_isFlashOn && hasFlash) {
        await _controller!.setFlashMode(FlashMode.always);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
        _isFlashOn = false;
      }

      notifyListeners();
    } catch (e) {
      _logError('Camera controller initialization error', e.toString());
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    // Fade out animation (opacity 1 → 0)
    _fadeController?.fadeOut();

    // Wait for fade out to complete before switching camera
    await Future.delayed(const Duration(milliseconds: 300));

    // Switch camera logic
    final lensDirection = _cameras[_selectedCameraIndex].lensDirection;
    CameraLensDirection newDirection =
        lensDirection == CameraLensDirection.front
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    final newIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == newDirection,
    );

    if (newIndex != -1) {
      _selectedCameraIndex = newIndex;
      _currentZoomLevel =
          1.0; // Reset zoom level to default when switching camera
      await _initCameraController(_cameras[_selectedCameraIndex]);
      notifyListeners(); // Notify listeners about zoom level reset
    }

    // Fade in animation (opacity 0 → 1)
    _fadeController?.fadeIn();
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      HapticFeedback.mediumImpact();

      notifyListeners();

      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.always);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
      }
    } on CameraException catch (e) {
      _logError('Flash toggle error', e.description);
    }
  }

  Future<void> setZoomLevel(double zoomLevel) async {
    if (_controller == null) return;

    final clampedZoomLevel = zoomLevel.clamp(1.0, 3.0);
    if (_currentZoomLevel != clampedZoomLevel) {
      _currentZoomLevel = clampedZoomLevel;
      notifyListeners();
      await _controller!.setZoomLevel(clampedZoomLevel);
    }
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      HapticFeedback.mediumImpact();
      _imageFile = image;
      _isPictureTaken = true;
      _pictureTakenAt = DateTime.now();
      print('Image path: ${_imageFile?.path}');
      print('Image name: ${_imageFile?.name}');
      print('Picture taken at: $_pictureTakenAt');
      notifyListeners();
    } on CameraException catch (e) {
      _logError(e.code, e.description);
    }
  }

  Future<void> startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      await _controller!.startVideoRecording();
      _isRecording = true;
      notifyListeners();
    } on CameraException catch (e) {
      _logError(e.code, e.description);
    }
  }

  Future<void> stopRecording() async {
    if (_controller == null) return;

    try {
      final XFile video = await _controller!.stopVideoRecording();
      _videoFile = video;
      _isPictureTaken = true;
      _pictureTakenAt = DateTime.now();
      _isRecording = false;
      print('video path: ${_videoFile?.path}');
      print('video name: ${_videoFile?.name}');
      print('Picture taken at: $_pictureTakenAt');
      notifyListeners();
      // Handle the recorded video file
    } on CameraException catch (e) {
      _logError(e.code, e.description);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }
}
