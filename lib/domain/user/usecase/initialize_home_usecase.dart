import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';

class InitializeHomeUsecase {
  final GetProfileUsecase _getProfileUsecase;
  final UserService _userService;

  InitializeHomeUsecase(this._getProfileUsecase, this._userService);

  Future<Either<Failure, bool>> call() async {
    try {
      // Load cached user first
      await _userService.loadUserFromStorage();

      // If no cached user, return failure
      if (!_userService.isLoggedIn) {
        // Try to fetch fresh profile
        final result = await _getProfileUsecase.call();
        return result.fold(
          (failure) => Left(failure),
          (success) => const Right(true),
        );
      }

      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to initialize home: $e'));
    }
  }
}
