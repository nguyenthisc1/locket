import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';

abstract class MessageRepository {
  Future<Either<Failure, BaseResponse>> getMessagesConversation({
    required String conversationId,
    int? limit,
    DateTime? lastCreatedAt,
  });

  Future<Either<Failure, BaseResponse>> sendMessage(
    Map<String, dynamic> payload,
  );
}
