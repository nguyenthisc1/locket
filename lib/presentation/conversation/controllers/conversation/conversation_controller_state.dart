import 'package:flutter/material.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConversationControllerState extends ChangeNotifier {
  // Loading and error state
  bool _isLoadingConversations = false;
  bool _isRefreshingConversations = false;
  bool _isloadingMoreConversations = false;
  String? _errorMessage;
  bool _hasInitialized = false;
  bool _isShowingCachedData = false;

  // Conversation data
  List<ConversationEntity> _listConversation = [];
  int _unreadCountConversations = 0;

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  DateTime? _lastCreatedAt;

  // Additional state
  bool _isConversationInputFocused = false;
  String? _pendingMessageText;
  String? _pendingAttachmentPath;
  bool _isSendingMessage = false;
  int _selectedConversationIndex = -1;
  bool _isConversationMuted = false;
  bool _isConversationArchived = false;

  // Getters
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isRefreshingConversations => _isRefreshingConversations;
  bool get isloadingMoreConversations => _isloadingMoreConversations;
  List<ConversationEntity> get listConversation => _listConversation;
  String? get errorMessage => _errorMessage;
  bool get hasInitialized => _hasInitialized;
  int get unreadCountConversations => _unreadCountConversations;
  bool get isShowingCachedData => _isShowingCachedData;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  DateTime? get lastCreatedAt => _lastCreatedAt;

  // Additional state getters
  bool get isConversationInputFocused => _isConversationInputFocused;
  String? get pendingMessageText => _pendingMessageText;
  String? get pendingAttachmentPath => _pendingAttachmentPath;
  bool get isSendingMessage => _isSendingMessage;
  int get selectedConversationIndex => _selectedConversationIndex;
  bool get isConversationMuted => _isConversationMuted;
  bool get isConversationArchived => _isConversationArchived;

  // Setters
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

  void setListConversations(
    List<ConversationEntity> conversations, {
    bool isFromCache = false,
  }) {
    _listConversation = List.from(conversations);
    _isShowingCachedData = isFromCache;
    notifyListeners();
  }

  void replaceConversation(String id, ConversationEntity newConversation) {
    final index = _listConversation.indexWhere((m) => m.id == id);
    if (index != -1) {
      _listConversation[index] = newConversation;
      notifyListeners();
    }
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

  void setLoadingMore(bool value) {
    if (_isLoadingMore != value) {
      _isLoadingMore = value;
      notifyListeners();
    }
  }

  void setHasMoreData(bool value) {
    if (_hasMoreData != value) {
      _hasMoreData = value;
      notifyListeners();
    }
  }

  void setLastCreatedAt(DateTime? value) {
    if (_lastCreatedAt != value) {
      _lastCreatedAt = value;
      notifyListeners();
    }
  }

  // Additional state setters
  void setConversationInputFocused(bool value) {
    if (_isConversationInputFocused != value) {
      _isConversationInputFocused = value;
      notifyListeners();
    }
  }

  void setPendingMessageText(String? value) {
    if (_pendingMessageText != value) {
      _pendingMessageText = value;
      notifyListeners();
    }
  }

  void setPendingAttachmentPath(String? value) {
    if (_pendingAttachmentPath != value) {
      _pendingAttachmentPath = value;
      notifyListeners();
    }
  }

  void setSendingMessage(bool value) {
    if (_isSendingMessage != value) {
      _isSendingMessage = value;
      notifyListeners();
    }
  }

  void setSelectedConversationIndex(int value) {
    if (_selectedConversationIndex != value) {
      _selectedConversationIndex = value;
      notifyListeners();
    }
  }

  void setConversationMuted(bool value) {
    if (_isConversationMuted != value) {
      _isConversationMuted = value;
      notifyListeners();
    }
  }

  void setConversationArchived(bool value) {
    if (_isConversationArchived != value) {
      _isConversationArchived = value;
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
    _isShowingCachedData = false;
    _isConversationInputFocused = false;
    _hasInitialized = false;
    _pendingMessageText = null;
    _pendingAttachmentPath = null;
    _isSendingMessage = false;
    _selectedConversationIndex = -1;
    _isConversationMuted = false;
    _isConversationArchived = false;
    notifyListeners();
  }
}
