import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/user_mapper.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/auth/models/user_model.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:logger/web.dart';

abstract class AuthApiService {
  Future<Either<Failure, UserEntity>> signup();
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  });
  Future<void> logout();

  Future<Either<Failure, String>> getToken();
}

class AuthApiServiceImpl extends AuthApiService {
  final DioClient dioClient = DioClient();
  final storage = const FlutterSecureStorage();

  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  Future<Either<Failure, String>> getToken() async {
    try {
      // Attempt to read the access token from secure storage
      final accessToken = await storage.read(key: 'accessToken');
      if (accessToken == null || accessToken.isEmpty) {
        logger.e('❌ No access token found in secure storage');
        return Left(AuthFailure(message: 'No access token found'));
      }
      logger.d('✅ Access token retrieved successfully');
      return Right(accessToken.toString());
    } catch (e) {
      logger.e('❌ Failed to get tokens: $e');
      return Left(AuthFailure(message: 'Failed to get token: $e'));
    }
  }

  /// Logs in a user using email/phone and password.
  /// Returns [UserEntity] and tokens on success, or [Failure] on error.
  @override
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      logger.d('🔑 Attempting login for: $identifier');

      // Prepare request body
      final Map<String, dynamic> body = {
        identifier.contains('@') ? 'email' : 'phoneNumber': identifier,
        'password': password,
      };

      // Send login request
      final response = await dioClient.post(ApiUrl.login, data: body);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Save tokens securely
        final accessToken = data['accessToken'] as String?;
        final refreshToken = data['refreshToken'] as String?;
        if (accessToken != null) {
          await storage.write(key: 'accessToken', value: accessToken);
        }
        if (refreshToken != null) {
          await storage.write(key: 'refreshToken', value: refreshToken);
        }

        // Parse user info
        final userMap = data['user'] as Map<String, dynamic>?;
        if (userMap == null) {
          logger.e('User data missing in response');
          return Left(AuthFailure(message: 'User data missing in response'));
        }

        // You may want to use a UserModel.fromMap if available
        final user = UserMapper.toEntity(UserModel.fromMap(userMap));

        logger.d('✅ Login successful for: ${user.email ?? user.phoneNumber}');
        return Right(user);
      } else if (response.statusCode == 400 && response.data != null) {
        final errors = response.data['errors'];
        final message =
            errors is List && errors.isNotEmpty
                ? errors.map((e) => e['msg']).join(', ')
                : 'Invalid credentials';
        logger.e('❌ Login failed: $message');
        return Left(AuthFailure(message: message));
      } else if (response.statusCode == 404) {
        logger.e('❌ User not found');
        return Left(AuthFailure(message: 'User not found.'));
      } else if (response.statusCode == 401) {
        logger.e('❌ Invalid credentials');
        return Left(AuthFailure(message: 'Invalid credentials.'));
      } else {
        logger.e('❌ Login failed: ${response.statusMessage}');
        return Left(
          AuthFailure(message: response.statusMessage ?? 'Login failed'),
        );
      }
    } catch (e) {
      logger.e('🔥 Login exception: $e');
      return Left(AuthFailure(message: 'Login failed: ${e.toString()}'));
    }
  }

  /// Logs out the current user by calling the logout API and clearing stored tokens.
  /// Handles errors and logs the process.
  @override
  Future<void> logout() async {
    try {
      logger.d('🚪 Attempting logout');

      // Attempt to call the backend logout endpoint
      final response = await dioClient.post(ApiUrl.logout);

      if (response.statusCode == 200) {
        logger.d('✅ Logout successful, clearing tokens');
      } else {
        logger.w('⚠️ Logout API responded with status: ${response.statusCode}');
      }

      // Always clear tokens locally, regardless of API response
      await storage.delete(key: 'accessToken');
      await storage.delete(key: 'refreshToken');
      logger.d('🧹 Tokens cleared from secure storage');
    } catch (e) {
      logger.e('🔥 Logout exception: $e');
      // Still attempt to clear tokens in case of error
      try {
        await storage.delete(key: 'accessToken');
        await storage.delete(key: 'refreshToken');
        logger.d('🧹 Tokens cleared from secure storage after exception');
      } catch (storageError) {
        logger.e('❌ Failed to clear tokens: $storageError');
      }
      // Rethrow or handle as needed; for now, just log
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signup() {
    // TODO: implement signup
    throw UnimplementedError();
  }
}
