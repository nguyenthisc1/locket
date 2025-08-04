import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/user_profile_mapper.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/data/user/models/user_profile_model.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/user/entities/user_profile_entity.dart';
import 'package:logger/logger.dart';

abstract class UserApiService {
  Future<Either<Failure, BaseResponse>> getProfile();
}

class UserApiServiceImpl extends UserApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  UserApiServiceImpl(this.dioClient);

  final tokenStorage = getIt<TokenStorage<AuthTokenPair>>();

  @override
  Future<Either<Failure, BaseResponse>> getProfile() async {
    try {
      final tokenPair = await tokenStorage.read();

      if (tokenPair == null || tokenPair.accessToken.isEmpty) {
        return Left(AuthFailure(message: 'No access token found'));
      }

      final response = await dioClient.get(
        ApiUrl.getProfile,
        options: Options(
          headers: {'Authorization': 'Bearer ${tokenPair.accessToken}'},
        ),
      );

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final userProfile = UserProfileMapper.toEntity(
          UserProfileModel.fromJson(response.data['data']['user']),
        );

        logger.d('User Profile $userProfile ');

        final userService = getIt<UserService>();

        userService.setUser(
          UserProfileMapper.fromEntity(
            UserProfileEntity(
              id: userProfile.id,
              username: userProfile.username,
              email: userProfile.email,
              phoneNumber: userProfile.phoneNumber,
              avatarUrl: userProfile.avatarUrl,
              lastActiveAt: userProfile.lastActiveAt,
              friends: userProfile.friends,
              chatRooms: userProfile.chatRooms,
            ),
          ),
        );

        logger.d('User service ${userService.currentUser?.id}');

        final baseResponse = BaseResponse<Map<String, dynamic>>(
          success: response.data['success'],
          message: response.data['message'],
          data: {'user': userProfile},
          errors: response.data['errors'],
        );

        return Right(baseResponse);
      }

      final errors = response.data['errors'];
      logger.e('❌ Get Profile failed: $errors ${response.data['message']}');

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
      logger.e('❌ Get Profile failed: ${e.toString()}');

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
