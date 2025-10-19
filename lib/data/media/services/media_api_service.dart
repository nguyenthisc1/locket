import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/media_feed_mapper.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/media/models/media_feed.dart';
import 'package:logger/logger.dart';

abstract class MediaApiService {
  Future<Either<Failure, BaseResponse>> uploadFeed(
    Map<String, dynamic> payload,
  );
}

class MediaApiServiceImpl extends MediaApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  MediaApiServiceImpl(this.dioClient);

  @override
  Future<Either<Failure, BaseResponse<dynamic>>> uploadFeed(
    Map<String, dynamic> payload,
  ) async {
    try {
      final formData = FormData.fromMap({
        'mediaType': payload['mediaType'],
        'isFrontCamera': payload['isFrontCamera'] ?? true,
        'mediaData': await MultipartFile.fromFile(
          payload['filePath'],
          filename: payload['fileName'],
        ),
      });

      final response = await dioClient.post(
        ApiUrl.uploadFeed,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      final mediaJson = response.data['data'];
      final mediaModel = MediaFeedModel.fromJson(mediaJson);
      final mediaEntity = MediaFeedMapper.toEntity(mediaModel);

      final data = {'media': mediaEntity};
      logger.d('media $data');

      // Handle different status codes since validateStatus < 500 treats them as successful
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data.isNotEmpty) {
        final baseResponse = BaseResponse<dynamic>(
          success: response.data['success'],
          message: response.data['message'],
          data: data,
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
