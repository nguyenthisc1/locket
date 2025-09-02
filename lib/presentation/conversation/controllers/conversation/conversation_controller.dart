import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/domain/conversation/usecases/get_conversation_detail_usecase.dart';
import 'package:locket/domain/conversation/usecases/get_conversations_usecase.dart';
import 'package:locket/domain/conversation/usecases/unread_count_conversations_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:logger/logger.dart';

class ConversationController {
  final ConversationControllerState _state;
  final GetConversationsUsecase _getConversationsUsecase;
  final GetConversationDetailUsecase _getConversationDetailUsecase;
  final UnreadCountConversationsUsecase _unreadCountConversationsUsecase;
  final Logger _logger;

  ConversationController({
    required ConversationControllerState state,
    required GetConversationsUsecase getConversationsUsecase,
    required GetConversationDetailUsecase getConversationDetailUsecase,
    required UnreadCountConversationsUsecase unreadCountConversationsUsecase,
    Logger? logger,
  }) : _state = state,
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
    // await _loadCachedFeeds();
    await fetchConversations();
    _state.setInitialized(true);
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

          _state.setConversations(conversations);
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
  Future<void> refreshConversations([String? query, DateTime? lastCreatedAt]) async {
    await fetchConversations(
      isRefresh: true,
    );
  }

  Future<void> fetchUnreadCountConversation() async {
     try {
      final result = await _unreadCountConversationsUsecase();

      result.fold(
        (failure) {
          _logger.e('Failed to fetch Unread Count Conversations: ${failure.message}');
          _state.setError(failure.message);

          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if ( _state.unreadCountConversations < 0) {
            _state.setUnreadCountConversations(0);
          }
        },
        (response) {
          _logger.d('Feed Unread Count Conversations successfully');
          _state.clearError();

          final unreadCount =
              response.data['unreadCount'] as int;

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

  /// Dispose resources
  void dispose() {}
}
