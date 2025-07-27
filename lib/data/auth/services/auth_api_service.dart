import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/user_mapper.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/auth/models/auth_token_model.dart';
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
  Future<Either<Failure, String>> refreshToken();
  Future<Either<Failure, bool>> isTokenExpired();

  // Current user management
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user);
  Future<Either<Failure, void>> deleteAccount(String userId);
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
      final tokens = await TokenManager.loadTokens();
      if (tokens == null) {
        logger.e('❌ No tokens found in secure storage');
        return Left(AuthFailure(message: 'No tokens found'));
      }

      if (tokens.isExpired) {
        logger.d('🔄 Token expired, attempting refresh');
        return await refreshToken();
      }

      logger.d('✅ Access token retrieved successfully');
      return Right(tokens.accessToken);
    } catch (e) {
      logger.e('❌ Failed to get token: $e');
      return Left(AuthFailure(message: 'Failed to get token: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> refreshToken() async {
    try {
      logger.d('🔄 Attempting to refresh token');

      final tokens = await TokenManager.loadTokens();
      if (tokens == null) {
        logger.e('❌ No tokens found in secure storage');
        return Left(AuthFailure(message: 'No tokens found'));
      }

      // Prepare request body
      final Map<String, dynamic> body = {'refreshToken': tokens.refreshToken};

      // Send refresh token request
      final response = await dioClient.post(ApiUrl.refreshToken, data: body);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Create new token model
        final newTokens = AuthTokenModel(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String? ?? tokens.refreshToken,
        );

        // Save new tokens securely
        await TokenManager.saveTokens(newTokens);
        logger.d('✅ Token refresh successful');

        return Right(newTokens.accessToken);
      } else if (response.statusCode == 401) {
        logger.e('❌ Refresh token expired or invalid');
        // Clear tokens on refresh failure
        await TokenManager.clearTokens();
        return Left(AuthFailure(message: 'Refresh token expired or invalid'));
      } else {
        logger.e('❌ Token refresh failed: ${response.statusMessage}');
        return Left(
          AuthFailure(
            message: response.statusMessage ?? 'Token refresh failed',
          ),
        );
      }
    } catch (e) {
      logger.e('🔥 Token refresh exception: $e');
      return Left(
        AuthFailure(message: 'Token refresh failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isTokenExpired() async {
    try {
      final tokens = await TokenManager.loadTokens();
      if (tokens == null) {
        return Right(true); // No tokens means "expired"
      }

      final isExpired = tokens.isExpired;
      logger.d('🔍 Token expiration check: ${isExpired ? 'expired' : 'valid'}');
      return Right(isExpired);
    } catch (e) {
      logger.e('🔥 Token expiration check exception: $e');
      return Right(true); // Assume expired on error
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      logger.d('👤 Fetching current user');

      final response = await dioClient.get(ApiUrl.getProfile);

      if (response.statusCode == 200 && response.data != null) {
        final userMap = response.data as Map<String, dynamic>;
        final user = UserMapper.toEntity(UserModel.fromMap(userMap));

        logger.d('✅ Current user fetched: ${user.username}');
        return Right(user);
      } else if (response.statusCode == 401) {
        logger.e('❌ Unauthorized - user not authenticated');
        return Left(AuthFailure(message: 'User not authenticated'));
      } else {
        logger.e('❌ Failed to fetch current user: ${response.statusMessage}');
        return Left(
          AuthFailure(
            message: response.statusMessage ?? 'Failed to fetch current user',
          ),
        );
      }
    } catch (e) {
      logger.e('🔥 Get current user exception: $e');
      return Left(
        AuthFailure(message: 'Failed to fetch current user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user) async {
    try {
      logger.d('📝 Updating user profile for: ${user.username}');

      final userData = {
        'username': user.username,
        'email': user.email,
        'phoneNumber': user.phoneNumber,
        'avatarUrl': user.avatarUrl,
      };

      final response = await dioClient.put(
        ApiUrl.updateProfile,
        data: userData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final userMap = response.data as Map<String, dynamic>;
        final updatedUser = UserMapper.toEntity(UserModel.fromMap(userMap));

        logger.d('✅ User profile updated successfully');
        return Right(updatedUser);
      } else {
        logger.e('❌ Failed to update user profile: ${response.statusMessage}');
        return Left(
          AuthFailure(
            message: response.statusMessage ?? 'Failed to update user profile',
          ),
        );
      }
    } catch (e) {
      logger.e('🔥 Update user profile exception: $e');
      return Left(
        AuthFailure(message: 'Failed to update user profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount(userId) async {
    try {
      logger.d('🗑️ Deleting user account');

      final response = await dioClient.delete(ApiUrl.deleteAccount(userId));

      if (response.statusCode == 200) {
        // Clear tokens after successful account deletion
        await TokenManager.clearTokens();
        logger.d('✅ Account deleted successfully');
        return const Right(null);
      } else {
        logger.e('❌ Failed to delete account: ${response.statusMessage}');
        return Left(
          AuthFailure(
            message: response.statusMessage ?? 'Failed to delete account',
          ),
        );
      }
    } catch (e) {
      logger.e('🔥 Delete account exception: $e');
      return Left(
        AuthFailure(message: 'Failed to delete account: ${e.toString()}'),
      );
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

        // Create and save tokens using TokenManager
        final tokens = AuthTokenModel(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );

        await TokenManager.saveTokens(tokens);
        logger.d('✅ Tokens saved successfully');

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
      await TokenManager.clearTokens();
      logger.d('🧹 Tokens cleared from secure storage');
    } catch (e) {
      logger.e('🔥 Logout exception: $e');
      // Still attempt to clear tokens in case of error
      try {
        await TokenManager.clearTokens();
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
