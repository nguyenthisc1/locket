import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';

abstract class ConversationRepository {
  Future<Either<Failure, BaseResponse>> getConversations({int? limit, DateTime? lastCreatedAt});
  Future<Either<Failure, BaseResponse>> getConversation({required String conversationId, int? limit});
  Future<Either<Failure, BaseResponse>> unreacdCountConversations();
}