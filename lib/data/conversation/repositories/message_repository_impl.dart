import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/data/conversation/services/message_api_service.dart';
import 'package:locket/domain/conversation/repositories/message_repository.dart';
import 'package:logger/logger.dart';

class MessageRepositoryImpl extends MessageRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final MessageApiService _messageApiService;

  MessageRepositoryImpl(this._messageApiService);

  @override
  Future<Either<Failure, BaseResponse>> getMessagesConversation({
    required String conversationId,
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    final result = await _messageApiService.getMessagesConversation(
      conversationId: conversationId,
      limit: limit,
      lastCreatedAt: lastCreatedAt,
    );

    return result.fold(
      (failure) {
        logger.e(
          'Repository Get Messages Conversation failed: ${failure.toString()}',
        );
        return Left(failure);
      },
      (result) {
        logger.d(
          'Repository Get Messages Conversation successful for: ${result.data}',
        );
        return Right(result);
      },
    );
  }

  @override
  Future<Either<Failure, BaseResponse>> sendMessage(
    Map<String, dynamic> payload,
  ) async {
    final result = await _messageApiService.sendMessage(payload);

    return result.fold(
      (failure) {
        logger.e(
          'Repository Send Message Conversation failed: ${failure.toString()}',
        );
        return Left(failure);
      },
      (result) {
        logger.d(
          'Repository Send Message Conversation successful for: ${result.data}',
        );
        return Right(result);
      },
    );
  }
}
