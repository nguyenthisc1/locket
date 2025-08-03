import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/data/user/services/user_api_service.dart';
import 'package:locket/domain/user/repositories/user_repository.dart';
import 'package:logger/logger.dart';

class UserRepositoryImpl extends UserRepository {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );
  final UserApiService _userApiService;

  UserRepositoryImpl(this._userApiService);

  @override
  Future<Either<Failure, BaseResponse>> getProfile() async {
    final result = await _userApiService.getProfile();

    return result.fold(
      (failure) {
        logger.e('Repository Get Profile failed: ${failure.toString()}');
        return Left(failure);
      },
      (result) {
        logger.d('Repository Get Profile successful for: ${result.data}');
        return Right(result);
      },
    );
  }
}
