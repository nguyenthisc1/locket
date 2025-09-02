import 'package:locket/core/mappers/pagination_mapper.dart';
import 'package:locket/core/models/pagination_model.dart';
import 'package:locket/core/services/conversation_cache_service.dart';
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
  final Logger _logger;

  ConversationController({
    required ConversationControllerState state,
    required ConversationCacheService cacheService,
    required GetConversationsUsecase getConversationsUsecase,
    required GetConversationDetailUsecase getConversationDetailUsecase,
    required UnreadCountConversationsUsecase unreadCountConversationsUsecase,
    Logger? logger,
  }) : _state = state,
       _cacheService = cacheService,
       _getConversationsUsecase = getConversationsUsecase,
       _getConversationDetailUsecase = getConversationDetailUsecase,
       _unreadCountConversationsUsecase = unreadCountConversationsUsecase,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true));

  Future<void> init() async {
    // Only initialize once
    if (_state.hasInitialized) {
      return;
    }

    // Load cached data first (instant UI update)
    await _loadCachedConversations();

    // Then fetch fresh data in background
    await fetchConversations();
    _state.setInitialized(true);
  }

  /// Load cached conversations for instant UI display
  Future<void> _loadCachedConversations() async {
    try {
      final cachedConversations = await _cacheService.loadCachedConversations();

      if (cachedConversations.isNotEmpty) {
        _logger.d(
          '📦 Loaded ${cachedConversations.length} cached conversations',
        );
        _state.setConversations(cachedConversations, isFromCache: true);
      } else {
        _logger.d('📦 No cached conversations found');
      }
    } catch (e) {
      _logger.e('❌ Error loading cached conversations: $e');
      // Don't show error for cache loading failures
      // The fresh fetch will handle error display if needed
    }
  }

  Future<void> fetchConversations({int? limit, bool isRefresh = false}) async {
    if (isRefresh) {
      _state.setRefreshingConversations(true);
    } else {
      _state.setLoadingConversations(true);
    }
    _state.clearError();
    try {
      final result = await _getConversationsUsecase(limit);

      result.fold(
        (failure) {
          _logger.e('Failed to fetch Conversations: ${failure.message}');
          _state.setError(failure.message);

          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if (!isRefresh && _state.listConversation.isEmpty) {
            _state.setConversations([]);
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

          _state.setConversations(conversations, isFromCache: false);
          _cacheService.cacheConversations(_state.listConversation);
        },
      );
    } catch (e) {
      _logger.e('Error fetching Conversations: $e');
      _state.setError('An unexpected error occurred');

      if (!isRefresh && _state.listConversation.isEmpty) {
        _state.setConversations([]);
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

  /// Get cached conversations for instant display
  Future<void> loadCachedConversationsOnly() async {
    await _loadCachedConversations();
  }

  /// Check if we have cached conversations
  bool get hasCachedConversations => _cacheService.hasCachedData;

  /// Get cache info for debugging
  Map<String, dynamic> get cacheInfo => _cacheService.getCacheInfo();

  /// Clear conversation cache
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    _state.setConversations([]);
  }

  /// Dispose resources
  void dispose() {}
}
