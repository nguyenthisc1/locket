import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/constants/request_defaults.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/message_mapper.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/conversation/models/message_model.dart';
import 'package:logger/logger.dart';

abstract class MessageApiService {
  Future<Either<Failure, BaseResponse>> getMessagesConversation({
    required String conversationId,
    int? limit,
    DateTime? lastCreatedAt,
  });
}

class MessageApiServiceImpl extends MessageApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  MessageApiServiceImpl(this.dioClient);

  @override
  Future<Either<Failure, BaseResponse>> getMessagesConversation({
    required String conversationId,
    int? limit,
    DateTime? lastCreatedAt,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      queryParameters['limit'] = limit ?? RequestDefaults.messageListLimit.toString();

      final response = await dioClient.get(
        ApiUrl.getConversationMessages(conversationId),
        queryParameters: queryParameters,
      );
      logger.d('response messages conversation: ${response.data}');

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final messagesJson = response.data['data']['messages'] as List<dynamic>;
        final messageModels =
            messagesJson.map((json) => MessageModel.fromJson(json)).toList();
        final messages = MessageMapper.toEntityList(messageModels);

        final data = {'messages': messages};
        logger.d('messages $data');

        final baseResponse = BaseResponse<Map<String, dynamic>>(
          success: response.data['success'],
          message: response.data['message'],
          data: data,
          errors: response.data['errors'],
        );

        return Right(baseResponse);
      }
      // Handle specific status codes (since they're not treated as exceptions)
      final statusCode = response.statusCode;
      final message = response.data['message'] ?? 'Unknown error';
      final errors = response.data['errors'];

      logger.e(
        '❌ Get messages conversation failed: $errors $message (Status: $statusCode)',
      );

      if (statusCode == 401) {
        return Left(
          UnauthorizedFailure(message: message, statusCode: statusCode),
        );
      } else if (statusCode == 403) {
        return Left(AuthFailure(message: message, statusCode: statusCode));
      } else if (statusCode == 404) {
        return Left(
          DataFailure(
            message: 'messages conversation not found',
            statusCode: statusCode,
          ),
        );
      } else if (statusCode == 422) {
        return Left(
          ValidationFailure(message: message, statusCode: statusCode),
        );
      } else {
        return Left(DataFailure(message: message, statusCode: statusCode));
      }
    } catch (e) {
      logger.e('❌ Get messages conversation failed: ${e.toString()}');

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Lỗi kết nối server';

        // DioException will only occur for network issues or server errors (5xx)
        if (statusCode != null && statusCode >= 500) {
          return Left(ServerFailure(message: message, statusCode: statusCode));
        } else {
          return Left(NetworkFailure(message: message, statusCode: statusCode));
        }
      }

      return Left(DataFailure(message: e.toString()));
    }
  }
}
