import 'package:flutter/material.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConversationDetailControllerState extends ChangeNotifier {
  // Loading and error state
  bool _isLoadingMessages = false;
  bool _isRefreshingMessages = false;
  bool _isLoadingMoreMessages = false;
  String? _errorMessage;
  bool _hasInitialized = false;
  bool _isShowingCachedData = false;

  // Message data
  List<MessageEntity> _listMessages = [];
  String _conversationId = '';

  // Conversation data
  ConversationEntity? _conversation;

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  DateTime? _lastCreatedAt;

  // Message sending state
  bool _isSendingMessage = false;
  String? _pendingMessageText;
  String? _pendingAttachmentPath;

  // UI state
  final ScrollController scrollController = ScrollController();
  final Set<int> visibleTimestamps = {};
  
  // Background gradient state
  int _currentGradientIndex = 0;

  // Getters
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isRefreshingMessages => _isRefreshingMessages;
  bool get isLoadingMoreMessages => _isLoadingMoreMessages;
  List<MessageEntity> get listMessages => _listMessages;
  String get conversationId => _conversationId;
  ConversationEntity? get conversation => _conversation;
  String? get errorMessage => _errorMessage;
  bool get hasInitialized => _hasInitialized;
  bool get isShowingCachedData => _isShowingCachedData;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  DateTime? get lastCreatedAt => _lastCreatedAt;
  bool get isSendingMessage => _isSendingMessage;
  String? get pendingMessageText => _pendingMessageText;
  String? get pendingAttachmentPath => _pendingAttachmentPath;
  int get currentGradientIndex => _currentGradientIndex;

  // Setters
  void setConversationId(String value) {
    if (_conversationId != value) {
      _conversationId = value;
      notifyListeners();
    }
  }

  void setConversation(ConversationEntity? value) {
    if (_conversation != value) {
      _conversation = value;
      notifyListeners();
    }
  }

  void setLoadingMessages(bool value) {
    if (_isLoadingMessages != value) {
      _isLoadingMessages = value;
      notifyListeners();
    }
  }

  void setRefreshingMessages(bool value) {
    if (_isRefreshingMessages != value) {
      _isRefreshingMessages = value;
      notifyListeners();
    }
  }

  void setLoadingMoreMessages(bool value) {
    if (_isLoadingMoreMessages != value) {
      _isLoadingMoreMessages = value;
      notifyListeners();
    }
  }

  void setMessages(
    List<MessageEntity> messages, {
    bool isFromCache = false,
  }) {
    _listMessages = List.from(messages);
    _isShowingCachedData = isFromCache;
    notifyListeners();
  }

  void addMessage(MessageEntity message) {
    _listMessages = [..._listMessages, message];
    notifyListeners();
  }

  void updateMessage(MessageEntity updatedMessage) {
    final index = _listMessages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      _listMessages[index] = updatedMessage;
      notifyListeners();
    }
  }

  void removeMessage(String messageId) {
    _listMessages.removeWhere((m) => m.id == messageId);
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

  void setSendingMessage(bool value) {
    if (_isSendingMessage != value) {
      _isSendingMessage = value;
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

  void setCurrentGradientIndex(int value) {
    if (_currentGradientIndex != value) {
      _currentGradientIndex = value;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  bool shouldShowTimestamp(int index, List<MessageEntity> data) {
    if (index == 0) return true;
    final prev = data[index - 1];
    final curr = data[index];
    final diff = curr.createdAt.difference(prev.createdAt).inMinutes.abs();
    return diff > 20;
  }

  void toggleTimestampVisibility(int index) {
    if (visibleTimestamps.contains(index)) {
      visibleTimestamps.remove(index);
    } else {
      visibleTimestamps.add(index);
    }
    notifyListeners();
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void reset() {
    _listMessages.clear();
    _conversation = null;
    _isLoadingMessages = false;
    _isRefreshingMessages = false;
    _isLoadingMoreMessages = false;
    _isShowingCachedData = false;
    _hasInitialized = false;
    _isSendingMessage = false;
    _pendingMessageText = null;
    _pendingAttachmentPath = null;
    _hasMoreData = true;
    _lastCreatedAt = null;
    _errorMessage = null;
    visibleTimestamps.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
