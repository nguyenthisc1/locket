import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/constants/request_defaults.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/conversation_mapper.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/conversation/models/converstation_model.dart';
import 'package:locket/domain/conversation/entities/conversation_detail_entity.dart';
import 'package:logger/logger.dart';

abstract class ConversationApiService {
  Future<Either<Failure, BaseResponse>> getConversations({int? limit, DateTime? lastCreatedAt});
  Future<Either<Failure, BaseResponse>> getConversation(String conversationId);
  Future<Either<Failure, BaseResponse>> unreadCountConversations();
  Future<Either<Failure, BaseResponse>> markConversationAsRead(String conversationId);
}

class ConversationApiServiceImpl extends ConversationApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  ConversationApiServiceImpl(this.dioClient);

  @override
  Future<Either<Failure, BaseResponse>> getConversations({int? limit, DateTime? lastCreatedAt}) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      queryParameters['limit'] = limit ?? RequestDefaults.conversationListLimit.toString();

      final response = await dioClient.get(
        ApiUrl.getUserConversations,
        queryParameters: queryParameters,
      );
      logger.d('response conversations: ${response.data}');

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final conversationsJson = response.data['data']['conversations'] as List<dynamic>;
        final conversationModels = conversationsJson
            .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final conversations = ConversationMapper.toEntityList(conversationModels);

        final data = {'conversations': conversations};
        logger.d('conversations $data');

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
        '❌ Get Conversation failed: $errors $message (Status: $statusCode)',
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
            message: 'Conversation not found',
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
      logger.e('❌ Get Conversation failed: ${e.toString()}');

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

  @override
  Future<Either<Failure, BaseResponse>> getConversation(String conversationId) async {
    try {
      final response = await dioClient.get(
        ApiUrl.getConversationById(conversationId)
      );
      logger.d('response conversation detail: ${response.data}');

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final conversation = ConversationDetailEntity.fromJson(
          response.data['data'],
        );

        final data = {'conversation': conversation};
        logger.d('conversation detail $data');

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
        '❌ Get conversation detail failed: $errors $message (Status: $statusCode)',
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
            message: 'conversation detail not found',
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
      logger.e('❌ Get conversation detail failed: ${e.toString()}');

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

  @override
  Future<Either<Failure, BaseResponse>> unreadCountConversations() async {
    try {
      final response = await dioClient.get(ApiUrl.unreadCountConversations);

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final unreadCount = response.data['data']['unreadCount'];

        final data = {'unreadCount': unreadCount};
        logger.d('unreadCount $data');

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
        '❌ Get Conversation failed: $errors $message (Status: $statusCode)',
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
            message: 'Conversation not found',
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
      logger.e('❌ Get Conversation failed: ${e.toString()}');

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

  @override
  Future<Either<Failure, BaseResponse>> markConversationAsRead(String conversationId) async {
    try {
      final response = await dioClient.post(ApiUrl.markConversationAsRead(conversationId));
      logger.d('response mark conversation read message: ${response.data}');

      if (response.statusCode == 201) {
        final baseResponse = BaseResponse<Map<String, dynamic>>(
          success: response.data['success'],
          message: response.data['message'],
          errors: response.data['errors'],
        );

        return Right(baseResponse);
      }

      // Handle specific status codes (since they're not treated as exceptions)
      final statusCode = response.statusCode;
      final message = response.data['message'] ?? 'Unknown error';
      final errors = response.data['errors'];

      logger.e('❌ read message failed: $errors $message (Status: $statusCode)');

      if (statusCode == 401) {
        return Left(
          UnauthorizedFailure(message: message, statusCode: statusCode),
        );
      } else if (statusCode == 403) {
        return Left(AuthFailure(message: message, statusCode: statusCode));
      } else if (statusCode == 404) {
        return Left(
          DataFailure(message: 'conversation not found', statusCode: statusCode),
        );
      } else if (statusCode == 422) {
        return Left(
          ValidationFailure(message: message, statusCode: statusCode),
        );
      } else {
        return Left(DataFailure(message: message, statusCode: statusCode));
      }
    } catch (e) {
      logger.e('❌ mark conversation as read failed: ${e.toString()}');

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
