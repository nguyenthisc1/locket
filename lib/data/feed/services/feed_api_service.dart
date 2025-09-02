import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/feed_mapper.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/feed/models/feed_model.dart';
import 'package:logger/logger.dart';

abstract class FeedApiService {
  Future<Either<Failure, BaseResponse>> getFeeds({
    String? query,
    DateTime? lastCreatedAt,
    int? limit,
  });
  Future<Either<Failure, BaseResponse>> uploadFeed(
    Map<String, dynamic> payload,
  );
}

class FeedApiServiceImpl extends FeedApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  FeedApiServiceImpl(this.dioClient);

  @override
  Future<Either<Failure, BaseResponse>> getFeeds({
    String? query,
    DateTime? lastCreatedAt,
    int? limit,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {};
      if (query != null && query.isNotEmpty) {
        queryParameters['query'] = query;
      }
      if (lastCreatedAt != null) {
        queryParameters['lastCreatedAt'] = lastCreatedAt.toIso8601String();
      }
      queryParameters['limit'] = limit ?? '10';

      final response = await dioClient.get(
        ApiUrl.getPhotos,
        queryParameters: queryParameters,
      );
      logger.d('response feed: ${response.data}');

      // Handle different status codes since validateStatus < 500 treats them as successful
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final feedsJson = response.data['data']['feeds'] as List<dynamic>;
        final feedModels = feedsJson
            .map((json) => FeedModel.fromJson(json as Map<String, dynamic>))
            .toList();
        final feeds = FeedMapper.toEntityList(feedModels);

        final data = {'feeds': feeds};
        logger.d('feeds $data');

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

      logger.e('❌ Get Feed failed: $errors $message (Status: $statusCode)');

      if (statusCode == 401) {
        return Left(
          UnauthorizedFailure(message: message, statusCode: statusCode),
        );
      } else if (statusCode == 403) {
        return Left(AuthFailure(message: message, statusCode: statusCode));
      } else if (statusCode == 404) {
        return Left(
          FeedFailure(message: 'Feed not found', statusCode: statusCode),
        );
      } else if (statusCode == 422) {
        return Left(
          ValidationFailure(message: message, statusCode: statusCode),
        );
      } else {
        return Left(FeedFailure(message: message, statusCode: statusCode));
      }
    } catch (e) {
      logger.e('❌ Get Feed failed: ${e.toString()}');

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

      return Left(FeedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BaseResponse<dynamic>>> uploadFeed(
    Map<String, dynamic> payload,
  ) async {
    logger.d('FormData: $payload');

    try {
      final formData = FormData.fromMap({
        'caption': payload['caption'],
        'shareWith': payload['shareWith'],
        'mediaType': payload['mediaType'],
        'isFrontCamera': payload['isFrontCamera'] ?? true,
        'mediaData': await MultipartFile.fromFile(
          payload['filePath'],
          filename: payload['fileName'],
        ),
        // if (payload['mediaType'] == 'video')
        //   'mediaData': await MultipartFile.fromFile(payload['filePath'], filename: payload['fileName']),
      });

      final response = await dioClient.post(
        ApiUrl.uploadPhoto,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      // Handle different status codes since validateStatus < 500 treats them as successful
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data.isNotEmpty) {
        final baseResponse = BaseResponse<dynamic>(
          success: response.data['success'],
          message: response.data['message'],
          data: response.data['data'],
          errors: response.data['errors'],
        );
        return Right(baseResponse);
      }

      final statusCode = response.statusCode;
      final message = response.data['message'] ?? 'Unknown error';
      final errors = response.data['errors'];

      logger.e('❌ Upload Feed failed: $errors $message (Status: $statusCode)');

      if (statusCode == 403) {
        return Left(AuthFailure(message: message, statusCode: statusCode));
      } else if (statusCode == 422) {
        return Left(
          ValidationFailure(message: message, statusCode: statusCode),
        );
      } else {
        return Left(FeedFailure(message: message, statusCode: statusCode));
      }
    } catch (e) {
      logger.e('❌ Upload Feed failed: ${e.toString()}');
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
      return Left(FeedFailure(message: e.toString()));
    }
  }
}
