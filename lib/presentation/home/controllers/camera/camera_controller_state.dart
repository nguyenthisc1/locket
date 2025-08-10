import 'package:camera/camera.dart' as cam;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:locket/common/animations/fade_animation_controller.dart';

/// Pure state class for camera - only holds data, no business logic
class CameraControllerState extends ChangeNotifier implements TickerProvider {
  // Private fields
  List<cam.CameraDescription> _cameras = [];
  cam.CameraController? _controller;
  int _selectedCameraIndex = 1;
  bool _isFlashOn = false;
  double _currentZoomLevel = 1.0;
  cam.XFile? _imageFile;
  cam.XFile? _videoFile;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isPictureTaken = false;
  DateTime? _pictureTakenAt;
  String? _errorMessage;
  bool _isLoading = false;

  FadeAnimationController? _fadeController;

  // Getters
  List<cam.CameraDescription> get cameras => _cameras;
  cam.CameraController? get controller => _controller;
  int get selectedCameraIndex => _selectedCameraIndex;
  bool get isFlashOn => _isFlashOn;
  double get currentZoomLevel => _currentZoomLevel;
  cam.XFile? get imageFile => _imageFile;
  cam.XFile? get videoFile => _videoFile;
  bool get isRecording => _isRecording;
  bool get isInitialized => _isInitialized;
  bool get isPictureTaken => _isPictureTaken;
  DateTime? get pictureTakenAt => _pictureTakenAt;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Animation getter
  FadeAnimationController? get fadeController => _fadeController;

  // Helper getters
  bool get hasCamera => _controller != null && _isInitialized;
  bool get hasMultipleCameras => _cameras.length > 1;
  bool get isFrontCamera => _selectedCameraIndex == 1 && _cameras.length > 1;
  bool get isBackCamera => _selectedCameraIndex == 0;
  bool get hasFlashSupport => _cameras.isNotEmpty && 
      _cameras[_selectedCameraIndex].lensDirection == cam.CameraLensDirection.back;

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }

  // State mutation methods
  void setCameras(List<cam.CameraDescription> cameras) {
    _cameras = cameras;
    notifyListeners();
  }

  void setController(cam.CameraController? controller) {
    _controller = controller;
    notifyListeners();
  }

  void setSelectedCameraIndex(int index) {
    _selectedCameraIndex = index;
    notifyListeners();
  }

  void setFlashOn(bool isOn) {
    _isFlashOn = isOn;
    notifyListeners();
  }

  void setCurrentZoomLevel(double level) {
    _currentZoomLevel = level;
    notifyListeners();
  }

  void setImageFile(cam.XFile? file) {
    _imageFile = file;
    notifyListeners();
  }

  void setVideoFile(cam.XFile? file) {
    _videoFile = file;
    notifyListeners();
  }

  void setRecording(bool recording) {
    _isRecording = recording;
    notifyListeners();
  }

  void setInitialized(bool initialized) {
    _isInitialized = initialized;
    notifyListeners();
  }

  void setPictureTaken(bool taken, [DateTime? takenAt]) {
    _isPictureTaken = taken;
    _pictureTakenAt = takenAt;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setFadeController(FadeAnimationController? controller) {
    _fadeController = controller;
    notifyListeners();
  }

  void resetPictureTakenState() {
    print('Resetting picture taken state...');
    _imageFile = null;
    _videoFile = null;
    _isPictureTaken = false;
    _pictureTakenAt = null;
    print('State reset: isPictureTaken=$_isPictureTaken, imageFile=$_imageFile, videoFile=$_videoFile');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }
}
