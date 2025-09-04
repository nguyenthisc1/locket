import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locket/core/mappers/pagination_mapper.dart';
import 'package:locket/core/models/pagination_model.dart';
import 'package:locket/core/services/message_cache_service.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:locket/domain/conversation/usecases/get_messages_conversation_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/converstion_detail_controller_state.dart';
import 'package:logger/logger.dart';

class ConversationDetailController {
  final ConversationDetailControllerState _state;
  final MessageCacheService _cacheService;
  final GetMessagesConversationUsecase _getMessagesUsecase;
  final Logger _logger;

  // Background gradient functionality
  final List<LinearGradient> _backgroundGradients = [
    const LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF4E342E), Color(0xFF004D40)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF3E2723), Color(0xFF1C1C1C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    const LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF000000)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    const LinearGradient(
      colors: [Color(0xFF37474F), Color(0xFF212121)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    const LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF1B1B1B)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ];

  LinearGradient _currentBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get currentBackgroundGradient => _currentBackgroundGradient;

  double _lastScrollPosition = 0;

  ConversationDetailController({
    required ConversationDetailControllerState state,
    required MessageCacheService cacheService,
    required GetMessagesConversationUsecase getMessagesUsecase,
    Logger? logger,
  }) : _state = state,
       _cacheService = cacheService,
       _getMessagesUsecase = getMessagesUsecase,
       _logger = logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true)) {
    
    _state.scrollController.addListener(_onScroll);
  }

  Future<void> init(String conversationId) async {
    _state.setConversationId(conversationId);
    
    // Only initialize once per conversation
    if (_state.hasInitialized && _state.conversationId == conversationId) {
      return;
    }

    // Reset state for new conversation
    if (_state.conversationId != conversationId) {
      _state.reset();
      _state.setConversationId(conversationId);
    }

    // Load cached data first (instant UI update)
    await _loadCachedMessages();

    // Then fetch fresh data in background
    await fetchMessages();
    _state.setInitialized(true);

    // Scroll to bottom after loading messages
    _scrollToBottomDelayed();
  }

  /// Load cached messages for instant UI display
  Future<void> _loadCachedMessages() async {
    try {
      final cachedMessages = await _cacheService.loadCachedMessages(_state.conversationId);

      if (cachedMessages.isNotEmpty) {
        _logger.d(
          '📦 Loaded ${cachedMessages.length} cached messages for conversation ${_state.conversationId}',
        );
        _state.setMessages(cachedMessages, isFromCache: true);
      } else {
        _logger.d('📦 No cached messages found for conversation ${_state.conversationId}');
      }
    } catch (e) {
      _logger.e('❌ Error loading cached messages: $e');
      // Don't show error for cache loading failures
      // The fresh fetch will handle error display if needed
    }
  }

  Future<void> fetchMessages({
    int? limit,
    DateTime? lastCreatedAt,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _state.setRefreshingMessages(true);
    } else {
      _state.setLoadingMessages(true);
    }
    _state.clearError();

    try {
      final result = await _getMessagesUsecase(
        conversationId: _state.conversationId,
        limit: limit,
        lastCreatedAt: lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to fetch messages: ${failure.message}');
          _state.setError(failure.message);

          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if (!isRefresh && _state.listMessages.isEmpty) {
            _state.setMessages([]);
          }
        },
        (response) {
          _logger.d('Fetched messages successfully');
          _state.clearError();

          final messages = response.data['messages'] as List<MessageEntity>;
          final paginationData = response.data['pagination'];

          // Parse pagination data if available
          if (paginationData != null) {
            final paginationModel = PaginationModel.fromJson(paginationData);
            final pagination = PaginationMapper.toEntity(paginationModel);
            _logger.d(
              'Pagination info: hasNextPage=${pagination.hasNextPage}, nextCursor=${pagination.nextCursor}',
            );

            // Update pagination state with server response
            _state.setHasMoreData(pagination.hasNextPage);
            if (pagination.nextCursor != null) {
              _state.setLastCreatedAt(pagination.nextCursor);
            }
          } else {
            // Fallback to old logic if no pagination data
            if (messages.isNotEmpty) {
              _state.setLastCreatedAt(messages.last.createdAt);
              _state.setHasMoreData(messages.length == limit);
            } else {
              _state.setHasMoreData(false);
            }
          }

          _state.setMessages(messages, isFromCache: false);
          _cacheService.cacheMessages(_state.conversationId, _state.listMessages);
        },
      );
    } catch (e) {
      _logger.e('Error fetching messages: $e');
      _state.setError('An unexpected error occurred');

      if (!isRefresh && _state.listMessages.isEmpty) {
        _state.setMessages([]);
      }
    } finally {
      _state.setLoadingMessages(false);
      _state.setRefreshingMessages(false);
    }
  }

  /// Refresh messages (pull-to-refresh)
  Future<void> refreshMessages() async {
    await fetchMessages(isRefresh: true);
  }

  /// Load more messages for infinite scroll
  Future<void> loadMoreMessages() async {
    if (_state.isLoadingMore || !_state.hasMoreData) {
      return; // Already loading or no more data
    }

    _state.setLoadingMore(true);
    _state.clearError();

    try {
      final result = await _getMessagesUsecase.call(
        conversationId: _state.conversationId,
        lastCreatedAt: _state.lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load more messages: ${failure.message}');
          _state.setError(failure.message);
        },
        (response) {
          _logger.d('More messages loaded successfully');
          _state.clearError();

          final newMessages = response.data['messages'] as List<MessageEntity>;
          final paginationData = response.data['pagination'];
          _logger.d('New load more messages $newMessages');

          // Parse pagination data if available
          if (paginationData != null) {
            final paginationModel = PaginationModel.fromJson(paginationData);
            final pagination = PaginationMapper.toEntity(paginationModel);
            _logger.d(
              'Load more pagination: hasNextPage=${pagination.hasNextPage}, nextCursor=${pagination.nextCursor}',
            );

            // Update pagination state with server response
            _state.setHasMoreData(pagination.hasNextPage);
            if (pagination.nextCursor != null) {
              _state.setLastCreatedAt(pagination.nextCursor);
            }
          } else {
            // Fallback to old logic if no pagination data
            if (newMessages.isEmpty) {
              _state.setHasMoreData(false);
            } else if (newMessages.isNotEmpty) {
              _state.setLastCreatedAt(newMessages.last.createdAt);
            }
          }

          // Prepend new messages while avoiding duplicates
          if (newMessages.isNotEmpty) {
            final existing = _state.listMessages;
            final existingIds = existing.map((m) => m.id).toSet();
            final merged = [
              ...newMessages.where((m) => !existingIds.contains(m.id)),
              ...existing,
            ];
            _state.setMessages(merged);
          }

          // Cache messages
          _cacheService.cacheMessages(_state.conversationId, _state.listMessages);
        },
      );
    } catch (e) {
      _logger.e('Error loading more messages: $e');
      _state.setError('Failed to load more messages');
    } finally {
      _state.setLoadingMore(false);
    }
  }

  /// Add new message (e.g., when sending a message)
  Future<void> addMessage(MessageEntity message) async {
    _state.addMessage(message);
    await _cacheService.addMessageToCache(_state.conversationId, message);
    _scrollToBottomDelayed();
  }

  /// Update existing message (e.g., when message status changes)
  Future<void> updateMessage(MessageEntity updatedMessage) async {
    _state.updateMessage(updatedMessage);
    await _cacheService.updateMessageInCache(_state.conversationId, updatedMessage);
  }

  /// Remove message (e.g., when message is deleted)
  Future<void> removeMessage(String messageId) async {
    _state.removeMessage(messageId);
    await _cacheService.removeMessageFromCache(_state.conversationId, messageId);
  }

  /// Handles scroll events and triggers background gradient changes
  void _onScroll() {
    final currentPosition = _state.scrollController.position.pixels;
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
    int newIndex;
    do {
      newIndex = random.nextInt(_backgroundGradients.length);
    } while (newIndex == _state.currentGradientIndex && _backgroundGradients.length > 1);

    _currentBackgroundGradient = _backgroundGradients[newIndex];
    _state.setCurrentGradientIndex(newIndex);
  }

  void _scrollToBottomDelayed() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _state.scrollToBottom();
    });
  }

  /// Get cached messages for instant display
  Future<void> loadCachedMessagesOnly() async {
    await _loadCachedMessages();
  }

  /// Check if we have cached messages
  bool get hasCachedMessages => _cacheService.hasCachedData(_state.conversationId);

  /// Get cache info for debugging
  Map<String, dynamic> get cacheInfo => _cacheService.getCacheInfo(_state.conversationId);

  /// Clear message cache for this conversation
  Future<void> clearCache() async {
    await _cacheService.clearCache(_state.conversationId);
    _state.setMessages([]);
  }

  /// Dispose resources
  void dispose() {
    _state.scrollController.removeListener(_onScroll);
  }
}
