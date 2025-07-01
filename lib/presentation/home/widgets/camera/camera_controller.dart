import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CameraControllerState extends ChangeNotifier implements TickerProvider {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isFlashOn = false;
  double _currentZoomLevel = 1.0;
  XFile? _imageFile;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isPictureTaken = false;
  DateTime? _pictureTakenAt;

  // Animation Controllers
  late final AnimationController _flashModeControlRowAnimationController;
  late final CurvedAnimation _flashModeControlRowAnimation;
  late final AnimationController _exposureModeControlRowAnimationController;
  late final CurvedAnimation _exposureModeControlRowAnimation;
  late final AnimationController _focusModeControlRowAnimationController;
  late final CurvedAnimation _focusModeControlRowAnimation;

  // Getters
  List<CameraDescription> get cameras => _cameras;
  CameraController? get controller => _controller;
  int get selectedCameraIndex => _selectedCameraIndex;
  bool get isFlashOn => _isFlashOn;
  double get currentZoomLevel => _currentZoomLevel;
  XFile? get imageFile => _imageFile;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  bool get isPictureTaken => _isPictureTaken;
  DateTime? get pictureTakenAt => _pictureTakenAt;

  // Animation getters
  AnimationController get flashModeControlRowAnimationController =>
      _flashModeControlRowAnimationController;
  CurvedAnimation get flashModeControlRowAnimation =>
      _flashModeControlRowAnimation;
  AnimationController get exposureModeControlRowAnimationController =>
      _exposureModeControlRowAnimationController;
  CurvedAnimation get exposureModeControlRowAnimation =>
      _exposureModeControlRowAnimation;
  AnimationController get focusModeControlRowAnimationController =>
      _focusModeControlRowAnimationController;
  CurvedAnimation get focusModeControlRowAnimation =>
      _focusModeControlRowAnimation;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  void _logError(String code, String? message) {
    // ignore: avoid_print
    print('Error: $code${message == null ? '' : '\nError Message: $message'}');
  }

  Future<void> initialize() async {
    // Initialize animation controllers
    _flashModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashModeControlRowAnimation = CurvedAnimation(
      parent: _flashModeControlRowAnimationController,
      curve: Curves.easeInOut,
    );

    _exposureModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _exposureModeControlRowAnimation = CurvedAnimation(
      parent: _exposureModeControlRowAnimationController,
      curve: Curves.easeInOut,
    );

    _focusModeControlRowAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusModeControlRowAnimation = CurvedAnimation(
      parent: _focusModeControlRowAnimationController,
      curve: Curves.easeInOut,
    );

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

  void resetPictureTakenState() {
    _imageFile = null;
    _isPictureTaken = false;
    _pictureTakenAt = null;
    notifyListeners();
  }

  void clearImageFile() {
    _imageFile = null;
    notifyListeners();
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
    _flashModeControlRowAnimationController.dispose();
    _exposureModeControlRowAnimationController.dispose();
    _focusModeControlRowAnimationController.dispose();
    super.dispose();
  }
}
