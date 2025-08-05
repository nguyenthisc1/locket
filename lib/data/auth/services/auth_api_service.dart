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

      // Handle specific status codes (since they're not treated as exceptions)
      final statusCode = response.statusCode;
      final message = response.data['message'] ?? 'Unknown error';
      final errors = response.data['errors'];
      
      logger.e('❌ Login failed: $errors $message (Status: $statusCode)');

      if (statusCode == 401) {
        return Left(UnauthorizedFailure(
          message: message,
          statusCode: statusCode,
        ));
      } else if (statusCode == 422) {
        return Left(ValidationFailure(
          message: message,
          statusCode: statusCode,
        ));
      } else if (statusCode == 429) {
        return Left(LoginFailure(
          message: 'Too many login attempts. Please try again later.',
          statusCode: statusCode,
        ));
      } else {
        return Left(LoginFailure(
          message: message,
          statusCode: statusCode,
        ));
      }
    } catch (e) {
      logger.e('❌ Login failed: ${e.toString()}');

      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Lỗi kết nối server';
        
        // DioException will only occur for network issues or server errors (5xx)
        if (statusCode != null && statusCode >= 500) {
          return Left(ServerFailure(
            message: message,
            statusCode: statusCode,
          ));
        } else {
          return Left(NetworkFailure(
            message: message,
            statusCode: statusCode,
          ));
        }
      }

      return Left(LoginFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final response = await dioClient.post(ApiUrl.logout);
      
      // Handle different status codes for logout
      if (response.statusCode == 200) {
        await dioClient.tokenStorage.delete();

        // Clear user data from UserService
        final userService = getIt<UserService>();
        await userService.clearUser();

        final check = await dioClient.tokenStorage.read();
        logger.d('check Token: $check');
        
        return const Right(null);
      }

      // Handle non-200 status codes
      final statusCode = response.statusCode;
      final message = response.data['message'] ?? 'Logout failed';
      
      logger.e('❌ Logout failed: $message (Status: $statusCode)');
      
      return Left(LogoutFailure(
        message: message,
        statusCode: statusCode,
      ));
    } catch (e) {
      logger.e('Failed logout: ${e.toString()}');
      
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Lỗi đăng xuất';
        
        // Even if logout API fails, clear local data
        try {
          await dioClient.tokenStorage.delete();
          final userService = getIt<UserService>();
          await userService.clearUser();
        } catch (clearError) {
          logger.e('Failed to clear local data: $clearError');
        }
        
        if (statusCode != null && statusCode >= 500) {
          return Left(ServerFailure(
            message: message,
            statusCode: statusCode,
          ));
        } else {
          return Left(NetworkFailure(
            message: message,
            statusCode: statusCode,
          ));
        }
      }
      
      // Even if there's an error, try to clear local data
      try {
        await dioClient.tokenStorage.delete();
        final userService = getIt<UserService>();
        await userService.clearUser();
      } catch (clearError) {
        logger.e('Failed to clear local data: $clearError');
      }
      
      return Left(LogoutFailure(message: e.toString()));
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
