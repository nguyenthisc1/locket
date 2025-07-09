import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';

class ConversationDetailControllerState extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();

  // Track which message indices have their timestamp visible
  final Set<int> visibleTimestamps = {};

  final List<LinearGradient> _backgroundGradients = [
    LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4E342E), Color(0xFF004D40)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF3E2723), Color(0xFF1C1C1C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF000000)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF37474F), Color(0xFF212121)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF1B1B1B)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ];

  LinearGradient _currentBackgroundGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get currentBackgroundGradient => _currentBackgroundGradient;

  double _lastScrollPosition = 0;

  ConversationDetailControllerState() {
    scrollController.addListener(_onScroll);

    // Always scroll to end on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events and triggers background gradient changes
  /// when the scroll delta exceeds a threshold.
  void _onScroll() {
    final currentPosition = scrollController.position.pixels;
    final scrollDelta = (currentPosition - _lastScrollPosition).abs();

    // Change background gradient when scrolling more than 800 pixels
    if (scrollDelta > 800) {
      _changeBackgroundGradient();
      _lastScrollPosition = currentPosition;
    }
  }

  /// Randomly selects a new background gradient, ensuring it is different
  /// from the current one, and notifies listeners.
  void _changeBackgroundGradient() {
    final random = Random();
    LinearGradient newGradient;
    do {
      newGradient =
          _backgroundGradients[random.nextInt(_backgroundGradients.length)];
    } while (newGradient == _currentBackgroundGradient &&
        _backgroundGradients.length > 1);

    _currentBackgroundGradient = newGradient;
    notifyListeners();
  }

  bool shouldShowTimestamp(int index, List<MessageEntity> data) {
    if (index == 0) return true;
    final prev = data[index - 1];
    final curr = data[index];
    final diff = curr.createdAt.difference(prev.createdAt).inMinutes.abs();
    return diff > 20;
  }
}
