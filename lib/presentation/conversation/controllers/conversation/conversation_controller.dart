import 'dart:async';

import 'package:locket/core/mappers/pagination_mapper.dart';
import 'package:locket/core/models/pagination_model.dart';
import 'package:locket/core/services/conversation_cache_service.dart';
import 'package:locket/core/services/socket_service.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/domain/conversation/usecases/get_conversation_detail_usecase.dart';
import 'package:locket/domain/conversation/usecases/get_conversations_usecase.dart';
import 'package:locket/domain/conversation/usecases/unread_count_conversations_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:logger/logger.dart';

class ConversationController {
  final ConversationControllerState _state;
  final ConversationCacheService _cacheService;
  final GetConversationsUsecase _getConversationsUsecase;
  final GetConversationDetailUsecase _getConversationDetailUsecase;
  final UnreadCountConversationsUsecase _unreadCountConversationsUsecase;
  final SocketService _socketService;
  final Logger _logger;

  StreamSubscription<ConversationEntity>? _conversationUpdateSubscription;

  ConversationController({
    required ConversationControllerState state,
    required ConversationCacheService cacheService,
    required GetConversationsUsecase getConversationsUsecase,
    required GetConversationDetailUsecase getConversationDetailUsecase,
    required UnreadCountConversationsUsecase unreadCountConversationsUsecase,
    required SocketService socketService,
    Logger? logger,
  }) : _state = state,
       _cacheService = cacheService,
       _getConversationsUsecase = getConversationsUsecase,
       _getConversationDetailUsecase = getConversationDetailUsecase,
       _unreadCountConversationsUsecase = unreadCountConversationsUsecase,
       _socketService = socketService,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true)) {
    _setupSocketListeners();
  }

  // -------------------- Getters --------------------

  /// Check if we have cached conversations
  bool get hasCachedConversations => _cacheService.hasCachedData;

  /// Get cache info for debugging
  Map<String, dynamic> get cacheInfo => _cacheService.getCacheInfo();

  // -------------------- Initialization --------------------

  Future<void> init() async {
    // Only initialize once
    if (_state.hasInitialized) {
      return;
    }

    // Then fetch fresh data in background
    await fetchConversations();
    _state.setInitialized(true);
  }

  // -------------------- Fetching & Manipulation --------------------

  Future<void> fetchConversations({
    int? limit,
    DateTime? lastCreatedAt,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _state.setRefreshingConversations(true);
    } else {
      _state.setLoadingConversations(true);
    }
    _state.clearError();
    try {
      final result = await _getConversationsUsecase(
        limit: limit,
        lastCreatedAt: lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to fetch Conversations: ${failure.message}');
          _state.setError(failure.message);

          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if (!isRefresh && _state.listConversation.isEmpty) {
            _state.setListConversations([]);
          }
        },
        (response) {
          _logger.d('Feed Conversations successfully');
          _state.clearError();

          final conversations =
              response.data['conversations'] as List<ConversationEntity>;
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
            if (conversations.isNotEmpty) {
              _state.setLastCreatedAt(conversations.last.createdAt);
              _state.setHasMoreData(conversations.length == limit);
            } else {
              _state.setHasMoreData(false);
            }
          }

          _state.setListConversations(conversations, isFromCache: false);
          _cacheService.cacheConversations(_state.listConversation);
        },
      );
    } catch (e) {
      _logger.e('Error fetching Conversations: $e');
      _state.setError('An unexpected error occurred');

      if (!isRefresh && _state.listConversation.isEmpty) {
        _state.setListConversations([]);
      }
    } finally {
      _state.setLoadingConversations(false);
      _state.setRefreshingConversations(false);
    }
  }

  /// Refresh feed data (pull-to-refresh)
  Future<void> refreshConversations([
    String? query,
    DateTime? lastCreatedAt,
  ]) async {
    await fetchConversations(isRefresh: true);
  }

  /// Load more feeds for infinite scroll
  Future<void> loadMoreConversations() async {
    if (_state.isLoadingMore || !_state.hasMoreData) {
      return; // Already loading or no more data
    }

    _state.setLoadingMore(true);
    _state.clearError();

    try {
      final result = await _getConversationsUsecase.call(
        lastCreatedAt: _state.lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load more conversations: ${failure.message}');
          _state.setError(failure.message);
        },
        (response) {
          _logger.d('More conversations loaded successfully');
          _state.clearError();

          final newConversations =
              response.data['conversations'] as List<ConversationEntity>;
          final paginationData = response.data['pagination'];
          _logger.d('new Loadmore feed $newConversations');

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
            if (newConversations.isEmpty) {
              _state.setHasMoreData(false);
            } else if (newConversations.isNotEmpty) {
              _state.setLastCreatedAt(newConversations.last.createdAt);
            }
          }

          // Append new feeds while preserving drafts and avoiding duplicates
          if (newConversations.isNotEmpty) {
            // Fix: Merge newConversations into the existing list, preserving drafts and avoiding duplicates
            final existing = _state.listConversation;
            final existingIds = existing.map((c) => c.id).toSet();
            final merged = [
              ...existing,
              ...newConversations.where((c) => !existingIds.contains(c.id)),
            ];
            _state.setListConversations(merged);
          }

          // Cache only server feeds (not drafts)
          _cacheService.cacheConversations(_state.listConversation);
        },
      );
    } catch (e) {
      _logger.e('Error loading more conversations: $e');
      _state.setError('Failed to load more conversations');
    } finally {
      _state.setLoadingMore(false);
    }
  }

  Future<void> fetchUnreadCountConversation() async {
    try {
      final result = await _unreadCountConversationsUsecase();

      result.fold(
        (failure) {
          _logger.e(
            'Failed to fetch Unread Count Conversations: ${failure.message}',
          );
          _state.setError(failure.message);

          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if (_state.unreadCountConversations < 0) {
            _state.setUnreadCountConversations(0);
          }
        },
        (response) {
          _logger.d('Feed Unread Count Conversations successfully');
          _state.clearError();

          final unreadCount = response.data['unreadCount'] as int;

          _state.setUnreadCountConversations(unreadCount);
        },
      );
    } catch (e) {
      _logger.e('Error fetching Unread Count Conversations: $e');
      _state.setError('An unexpected error occurred');

      if (_state.unreadCountConversations < 0) {
        _state.setUnreadCountConversations(0);
      }
    }
  }
  // -------------------- Caching --------------------

  /// Load cached conversations for instant UI display
  Future<void> loadCachedConversations() async {
    try {
      final cachedConversations = await _cacheService.loadCachedConversations();

      if (cachedConversations.isNotEmpty) {
        _logger.d(
          '📦 Loaded ${cachedConversations.length} cached conversations',
        );
        _state.setListConversations(cachedConversations, isFromCache: true);
      } else {
        _logger.d('📦 No cached conversations found');
      }
    } catch (e) {
      _logger.e('❌ Error loading cached conversations: $e');
      // Don't show error for cache loading failures
      // The fresh fetch will handle error display if needed
    }
  }

  /// Clear conversation cache
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    _state.setListConversations([]);
  }

  // -------------------- Socket & Real-time --------------------
  void _setupSocketListeners() {
    // Listen for conversation updates
    _conversationUpdateSubscription = _socketService.conversationUpdateStream.listen(
      (conversationUpdate) {
        _logger.d('💬 Received conversation update: ${conversationUpdate.id}');

        // Find the index of the conversation to update
        final index = _state.listConversation.indexWhere(
          (c) => c.id == conversationUpdate.id,
        );

        if (index != -1) {
          // Get the current conversation from state
          final currentConversation = _state.listConversation[index];
          
          // Replace the conversation with updated data, preserving original data
          final updatedConversation = currentConversation.copyWith(
            lastMessage: conversationUpdate.lastMessage,
            updatedAt: conversationUpdate.updatedAt ?? currentConversation.updatedAt,
          );

          _state.replaceConversation(conversationUpdate.id, updatedConversation);
          _logger.d('🔄 Conversation ${conversationUpdate.id} updated with new last message');
          
          // Cache the updated conversations
          _cacheService.cacheConversations(_state.listConversation);
        } else {
          _logger.d(
            '➕ Conversation ${conversationUpdate.id} not found in current list, skipping update',
          );
        }
      },
      onError: (error) {
        _logger.e('❌ Error in conversation update stream: $error');
      },
    );
  }

  // -------------------- Cleanup --------------------

  /// Dispose resources
  void dispose() {
    _conversationUpdateSubscription?.cancel();
  }
}
