import 'package:flutter/material.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConversationControllerState extends ChangeNotifier {
  bool _isLoadingConversations = false;
  bool _isRefreshingConversations = false;
  bool _isloadingMoreConversations = false;
  List<ConversationEntity> _listConversation = [];
  String? _errorMessage;
  bool _hasInitialized = false;
  int _unreadCountConversations = 0;

  bool get isLoadingConversations => _isLoadingConversations;
  bool get isRefreshingConversations => _isRefreshingConversations;
  bool get isloadingMoreConversations => _isloadingMoreConversations;
  List<ConversationEntity> get listConversation => _listConversation;
  String? get errorMessage => _errorMessage;
  bool get hasInitialized => _hasInitialized;
  int get unreadCountConversations => _unreadCountConversations;

  void setLoadingConversations(bool value) {
    if (_isLoadingConversations != value) {
      _isLoadingConversations = value;
      notifyListeners();
    }
  }

  void setRefreshingConversations(bool value) {
    if (_isRefreshingConversations != value) {
      _isRefreshingConversations = value;
      notifyListeners();
    }
  }

  void setConversations(List<ConversationEntity> conversations) {
    _listConversation = List.from(conversations);
    notifyListeners();
  }

  void setError(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyListeners();
    }
  }

  void setInitialized(bool value) {
    if (_hasInitialized != value) {
      _hasInitialized = value;
      notifyListeners();
    }
  }

  void setUnreadCountConversations(int value) {
    if (_unreadCountConversations != value) {
      _unreadCountConversations = value;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  void reset() {
    _listConversation.clear();
    _isLoadingConversations = false;
    _isRefreshingConversations = false;
    notifyListeners();
  }
}
