import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/conversation/repositories/message_repository.dart';

class SendMessageUsecase {
  final MessageRepository _messageRepository;

  SendMessageUsecase(this._messageRepository);

  Future<Either<Failure, BaseResponse>> call(
    Map<String, dynamic> payload,
  ) async {
    return await _messageRepository.sendMessage(payload);
  }
}
