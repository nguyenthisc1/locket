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
  Future<Either<Failure, BaseResponse>> getFeed(Map<String, dynamic> query);
}

class FeedApiServiceImpl extends FeedApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  FeedApiServiceImpl(this.dioClient);
  @override
  Future<Either<Failure, BaseResponse>> getFeed(
    Map<String, dynamic> query,
  ) async {
    try {
      final response = await dioClient.get(
        ApiUrl.getPhotos,
        queryParameters: query,
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final feedModels =
            (response.data['data']['photos'] as List<dynamic>)
                .map((json) => FeedMapper.toModel(FeedModel.fromJson(json)))
                .toList();

        final feeds = FeedMapper.toEntityList(feedModels);

        final data = {'feeds': feeds};

        final baseResponse = BaseResponse<Map<String, dynamic>>(
          success: response.data['success'],
          message: response.data['message'],
          data: data,
          errors: response.data['errors'],
        );

        return Right(baseResponse);
      }

      final errors = response.data['errors'];
      logger.e('❌ Get Feed failed: $errors ${response.data['message']}');

      final baseResponse = BaseResponse<Map<String, dynamic>>(
        success: false,
        message: response.data['message'],
        data: null,
        errors: errors,
      );

      return Left(
        AuthFailure(message: baseResponse.message ?? 'Unknown error'),
      );
    } catch (e) {
      logger.e('❌ Get Feed failed: ${e.toString()}');

      if (e is DioException) {
        return Left(
          AuthFailure(
            message: e.response?.data['message'] ?? 'Lỗi kết nối server',
          ),
        );
      }

      return Left(AuthFailure(message: e.toString()));
    }
  }
}
