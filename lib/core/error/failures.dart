import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

// Auth-related failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class LoginFailure extends Failure {
  const LoginFailure({required super.message, super.statusCode});
}

class LogoutFailure extends Failure {
  const LogoutFailure({required super.message, super.statusCode});
}

class TokenFailure extends Failure {
  const TokenFailure({required super.message, super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({required super.message, super.statusCode});
}

// User-related failures
class UserFailure extends Failure {
  const UserFailure({required super.message, super.statusCode});
}

class ProfileFailure extends Failure {
  const ProfileFailure({required super.message, super.statusCode});
}

// Feed-related failures
class FeedFailure extends Failure {
  const FeedFailure({required super.message, super.statusCode});
}

// Data-related failures
class DataFailure extends Failure {
  const DataFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode});
}

// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

class ServerFailure extends Failure {
  const ServerFailure( {required super.message, super.statusCode});
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required super.message, super.statusCode});
}

// Storage-related failures
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

class StorageFailure extends Failure {
  const StorageFailure({required super.message, super.statusCode});
}
