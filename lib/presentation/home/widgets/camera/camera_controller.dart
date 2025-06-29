import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraControllerState extends ChangeNotifier {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isFlashOn = false;
  double _currentZoomLevel = 1.0;
  XFile? _imageFile;
  bool _isRecording = false;
  bool _isInitialized = false;

  // Getters
  List<CameraDescription> get cameras => _cameras;
  CameraController? get controller => _controller;
  int get selectedCameraIndex => _selectedCameraIndex;
  bool get isFlashOn => _isFlashOn;
  double get currentZoomLevel => _currentZoomLevel;
  XFile? get imageFile => _imageFile;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIndex = 1;
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
      notifyListeners();
    } catch (e) {
      _logError('Camera controller initialization error', e.toString());
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

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
      await _initCameraController(_cameras[_selectedCameraIndex]);
    }
  }

  Future<void> toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      _isFlashOn = !_isFlashOn;
      notifyListeners();

      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.torch);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
      }
    } on CameraException catch (e) {
      _logError('Flash toggle error', e.description);
    }
  }

  Future<void> zoomIn() async {
    if (_controller == null) return;

    final newZoomLevel = _currentZoomLevel + 0.5;
    if (newZoomLevel <= 8.0) {
      _currentZoomLevel = newZoomLevel;
      notifyListeners();
      await _controller!.setZoomLevel(newZoomLevel);
    }
  }

  Future<void> zoomOut() async {
    if (_controller == null) return;

    final newZoomLevel = _currentZoomLevel - 0.5;
    if (newZoomLevel >= 1.0) {
      _currentZoomLevel = newZoomLevel;
      notifyListeners();
      await _controller!.setZoomLevel(newZoomLevel);
    }
  }

  Future<void> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      _imageFile = image;
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
      _isRecording = false;
      notifyListeners();
      // Handle the recorded video file
    } on CameraException catch (e) {
      _logError(e.code, e.description);
    }
  }

  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
