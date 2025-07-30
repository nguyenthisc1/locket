import 'package:dartz/dartz.dart';
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


}
