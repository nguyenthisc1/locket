import 'package:flutter/material.dart';

class FeedControllerState extends ChangeNotifier {
  final FocusNode messageFieldFocusNode = FocusNode();
  bool _isVisibleGallery = true;
  bool _isKeyboardOpen = false;
  int _popImageIndex = 0;

  bool get isVisibleGallery => _isVisibleGallery;

  bool get isKeyboardOpen => _isKeyboardOpen;

  int get popImageIndex => _popImageIndex;

  FeedControllerState() {
    messageFieldFocusNode.addListener(_handleKeyboardFocus);
  }

  void _handleKeyboardFocus() {
    final isOpen = messageFieldFocusNode.hasFocus;
    if (isOpen != _isKeyboardOpen) {
      _isKeyboardOpen = isOpen;
      notifyListeners();
    }
  }

  void toggleGalleryVisibility() {
    _isVisibleGallery = !_isVisibleGallery;
    notifyListeners();
  }

  set setPopImageIndex(int? value) {
    if (value != null && value != _popImageIndex) {
      _popImageIndex = value;
      // print(_popImageIndex);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageFieldFocusNode.removeListener(_handleKeyboardFocus);
    messageFieldFocusNode.dispose();
    super.dispose();
  }
}
