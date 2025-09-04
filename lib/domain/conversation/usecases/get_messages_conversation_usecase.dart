import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/conversation/repositories/message_repository.dart';

class GetMessagesConversationUsecase {
  final MessageRepository _messageRepository;

  GetMessagesConversationUsecase(this._messageRepository);

  Future<Either<Failure, BaseResponse>> call({
    required String conversationId,
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    return await _messageRepository.getMessagesConversation(
      conversationId: conversationId,
      limit: limit,
      lastCreatedAt: lastCreatedAt,
    );
  }
}
