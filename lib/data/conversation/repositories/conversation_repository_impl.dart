import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/data/conversation/services/conversation_api_service.dart';
import 'package:locket/domain/conversation/repositories/conversation_repository.dart';
import 'package:logger/logger.dart';

class ConversationRepositoryImpl extends ConversationRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final ConversationApiService _conversationApiService;

  ConversationRepositoryImpl(this._conversationApiService);

  @override
  Future<Either<Failure, BaseResponse>> getConversations(
  {int? limit, DateTime? lastCreatedAt}
  ) async {
    final result = await _conversationApiService.getConversations(limit: limit, lastCreatedAt: lastCreatedAt);

    return result.fold(
      (failure) {
        logger.e('Repository Get Conversations failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Repository Get Conversations successful for: ${result.data}');
        return Right(result);
      },
    );
  }
  
  @override
  Future<Either<Failure, BaseResponse>> unreacdCountConversations() async {
     final result = await _conversationApiService.unreadCountConversations();

    return result.fold(
      (failure) {
        logger.e('Repository Get Unread count failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Repository Get Unread count successful for: ${result.data}');
        return Right(result);
      },
    );
  }
  
  @override
  Future<Either<Failure, BaseResponse>> getConversation({
    required String conversationId,
    int? limit
  }) async {
   final result = await _conversationApiService.getConversation(conversationId: conversationId, limit: limit);

    return result.fold(
      (failure) {
        logger.e('Repository Get Conversation detail failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Repository Get Conversation detail successful for: ${result.data}');
        return Right(result);
      },
    );
  }
}
