import 'package:locket/domain/conversation/repositories/conversation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';

class GetConversationsUsecase {
     final ConversationRepository _conversationRepository;

     GetConversationsUsecase(this._conversationRepository);

     Future<Either<Failure, BaseResponse>> call(int? limit) async {
      return await _conversationRepository.getConversations(limit);
     }
}