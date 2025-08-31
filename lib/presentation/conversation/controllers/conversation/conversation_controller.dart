import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/domain/conversation/usecases/get_conversations_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:logger/logger.dart';

class ConversationController {
  final ConversationControllerState _state;
  final GetConversationsUsecase _getConversationsUsecase;
  final Logger _logger;

  ConversationController({
    required ConversationControllerState state,
    required GetConversationsUsecase getConversationsUsecase,
    Logger? logger,
  }) : _state = state,
       _getConversationsUsecase = getConversationsUsecase,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true));

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

          final conversations = response.data['conversations'] as List<ConversationEntity>;
          
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
}
