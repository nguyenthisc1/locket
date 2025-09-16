import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/conversation/repositories/conversation_repository.dart';

class MarkConversationAsReadUsecase {
  final ConversationRepository _conversationRepository;

  MarkConversationAsReadUsecase(this._conversationRepository);

  Future<Either<Failure, BaseResponse>> call(String conversationId) async {
    return await _conversationRepository.markConversationAsRead(conversationId);
  }
}
