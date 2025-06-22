import 'package:dartz/dartz.dart';
import 'package:locket/core/error/failures.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  Stream<Either<Failure, UserEntity?>> call() {
    return repository.authStateChanges;
  }
}
