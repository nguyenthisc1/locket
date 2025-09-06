import 'package:locket/domain/conversation/repositories/conversation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';

class GetConversationDetailUsecase {
     final ConversationRepository _conversationRepository;

     GetConversationDetailUsecase(this._conversationRepository);

     Future<Either<Failure, BaseResponse>> call(String conversationId) async {
      return await _conversationRepository.getConversation(conversationId);
     }
}