import 'package:fresh_dio/fresh_dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/core/services/auth_middleware_service.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/data/auth/repositories/token_store_impl.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/data/image/respositories/image_repository_impl.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:locket/domain/image/repositories/image_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // AUTH MIDDLEWARE SERVICE
  getIt.registerLazySingleton<AuthMiddlewareService>(
    () => AuthMiddlewareService(),
  );

  // Register FlutterSecureStorage as a singleton
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Register DioClient as a singleton
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // AUTH DIO CLIENT
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(getIt<DioClient>()),
  );

  // AUTH REPOSITORIES
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthApiService>()),
  );

  // IMAGE REPOSITORIES
  getIt.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl());

  // TOKEN REPOSITORIES
  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TokenStorageImpl>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );
}
