import 'package:dartz/dartz.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/mappers/user_mapper.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/data/auth/models/user_model.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:logger/logger.dart';

abstract class AuthApiService {
  Future<Either<Failure, UserEntity>> login({
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
  Future<Either<Failure, UserEntity>> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final body = {'email': identifier, 'password': password};
      final response = await dioClient.post(ApiUrl.login, data: body);

      if (response.statusCode == 200 && response.data != null) {
        // Parse tokens from response
        final tokenPair = AuthTokenPair.fromJson({
          'accessToken': response.data['accessToken'],
          'refreshToken': response.data['refreshToken'],
        });

        // Store tokens securely
        await dioClient.tokenStorage.write(tokenPair);

        final user = UserMapper.toEntity(
          UserModel.fromJson(response.data['user']),
        );

        return Right(user);
      }

      final errors = response.data['errors'];
      final message = response.data['message'];

      logger.e('❌ Login failed: $errors');

      return Left(AuthFailure(message: message));
    } catch (e) {
      logger.e('Failed login: ${e.toString()}');
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
