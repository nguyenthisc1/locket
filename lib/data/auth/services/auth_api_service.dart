import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/user_mapper.dart';
import 'package:locket/core/mappers/user_profile_mapper.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/data/auth/models/user_model.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/user/entities/user_profile_entity.dart';
import 'package:logger/logger.dart';

abstract class AuthApiService {
  Future<Either<Failure, dynamic>> login({
    required String identifier,
    required String password,
  });

  Future<void> logout();

  // Future<Either<Failure, AuthTokenPair>> refreshToken({
  //   required String accessToken,
  //   required String refreshToken,
  // });
}

class AuthApiServiceImpl extends AuthApiService {
  final DioClient dioClient;
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  AuthApiServiceImpl(this.dioClient);

  @override
  Future<Either<Failure, BaseResponse<Map<String, dynamic>>>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final body = {'email': identifier, 'password': password};
      final response = await dioClient.post(ApiUrl.login, data: body);

      if (response.statusCode == 200 && response.data.isNotEmpty) {
        // Parse tokens from response
        final tokenPair = AuthTokenPair.fromJson({
          'accessToken': response.data['data']['accessToken'],
          'refreshToken': response.data['data']['refreshToken'],
        });

        // Store tokens securely
        await dioClient.tokenStorage.write(tokenPair);

        final user = UserMapper.toEntity(
          UserModel.fromJson(response.data['data']['user']),
        );

        final userService = getIt<UserService>();

        // Set the current user in UserService
        // Extract id, username, email, and phoneNumber from the user object
        userService.setUser(
          UserProfileMapper.fromEntity(
            UserProfileEntity(
              id: user.id,
              username: user.username,
              email: user.email,
              phoneNumber: user.phoneNumber,
              avatarUrl: null,
              isVerified: false,
              lastActiveAt: null,
              friends: const [],
              chatRooms: const [],
            ),
          ),
        );

        logger.d('current User ${userService.currentUser?.email}');
        // Build the data map for BaseResponse
        final data = {'user': user};

        final baseResponse = BaseResponse<Map<String, dynamic>>(
          success: response.data['success'],
          message: response.data['message'],
          data: data,
          errors: response.data['errors'],
        );

        return Right(baseResponse);
      }

      final errors = response.data['errors'];
      logger.e('❌ Login failed: $errors ${response.data['message']}');

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
      logger.e('❌ Login failed: ${e.toString()}');

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

  @override
  Future<void> logout() async {
    try {
      await dioClient.post(ApiUrl.logout);
      await dioClient.tokenStorage.delete();

      final check = await dioClient.tokenStorage.read();
      logger.d('check Token: $check');
    } catch (e) {
      logger.e('Failed login: ${e.toString()}');
    }
  }

  // @override
  // Future<Either<Failure, AuthTokenPair>> refreshToken({
  //   required String accessToken,
  //   required String refreshToken,
  // }) async {
  //   // Attempt to refresh the token when a 401 is encountered.
  //   if (refreshToken.isEmpty || accessToken.isEmpty) {
  //     // Defensive: If tokens are missing, trigger logout.
  //     throw RevokeTokenException();
  //   }

  //   try {
  //     final body = {'refreshToken': refreshToken, 'accessToken': accessToken};
  //     final response = await dioClient.post(ApiUrl.refreshToken, data: body);
  //     final newTokens = response.data;

  //     if (newTokens == null ||
  //         newTokens['accessToken'] == null ||
  //         newTokens['refreshToken'] == null) {
  //       throw RevokeTokenException();
  //     }

  //     final tokenPair = AuthTokenPair(
  //       accessToken: newTokens['accessToken'] as String,
  //       refreshToken: newTokens['refreshToken'] as String,
  //     );

  //     await dioClient.tokenStorage.write(tokenPair);

  //     return Right(tokenPair);
  //   } catch (e, stackTrace) {
  //     logger.e('❌ Failed refreshToken: $e\n$stackTrace');
  //     throw RevokeTokenException();
  //   }
  // }
}
