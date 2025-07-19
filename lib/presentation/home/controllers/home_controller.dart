import 'package:flutter/material.dart';

class HomeControllerState extends ChangeNotifier {
  final PageController outerController = PageController();
  final PageController innerController = PageController();

  static List<String> get _galleryImages =>
      List.generate(50, (i) => 'https://picsum.photos/seed/$i/300/300');

  int _currentOuterPage = 0;
  bool _enteredFeed = false;

  // Getters
  int get currentOuterPage => _currentOuterPage;
  bool get enteredFeed => _enteredFeed;
  List<String> get gallery => _galleryImages;

  void init() {
    outerController.addListener(_outerPageListener);
  }

  void _outerPageListener() {
    final int newPage =
        outerController.hasClients ? outerController.page?.round() ?? 0 : 0;

    if (newPage != _currentOuterPage) {
      if (_currentOuterPage == 0 && newPage == 1) {
        _enteredFeed = true;
        notifyListeners();
      }

      if (_currentOuterPage == 1 && newPage == 0) {
        _enteredFeed = false;
        notifyListeners();
      }

      _currentOuterPage = newPage;
    }
  }

  void handleScrollPageViewOuter(int page) {
    if (outerController.hasClients) {
      outerController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    outerController.removeListener(_outerPageListener);
    outerController.dispose();
    innerController.dispose();
    super.dispose();
  }
}
