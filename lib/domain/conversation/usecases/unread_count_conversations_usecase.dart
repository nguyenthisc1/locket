import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/conversation/repositories/conversation_repository.dart';
class UnreadCountConversationsUsecase {
     final ConversationRepository _conversationRepository;

     UnreadCountConversationsUsecase(this._conversationRepository);

     Future<Either<Failure, BaseResponse>> call() async {
      return await _conversationRepository.unreacdCountConversations();
     }
}