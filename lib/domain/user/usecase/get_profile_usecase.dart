import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/models/base_response_model.dart';
import 'package:locket/domain/user/repositories/user_repository.dart';

class GetProfileUsecase {
  final UserRepository _userRepository;

  GetProfileUsecase(this._userRepository);

  Future<Either<Failure, BaseResponse>> call() async {
    return await _userRepository.getProfile();
  }
}
