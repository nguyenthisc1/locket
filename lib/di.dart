import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:get_it/get_it.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/core/routes/middleware.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/data/auth/repositories/token_store_impl.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/data/image/respositories/image_repository_impl.dart';
import 'package:locket/domain/image/repositories/image_repository.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // MIDDLEWARE
  getIt.registerLazySingleton<Middleware>(() => Middleware());

  // FLUTTER SECURE STORAGE
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  //  DIOCLIENT
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // // AUTH DIO CLIENT
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(getIt<DioClient>()),
  );

  // AUTH REPOSITORIES
  // getIt.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(getIt<AuthApiService>()),
  // );

  getIt.registerLazySingleton<AuthRepositoryImpl>(() => AuthRepositoryImpl(getIt<AuthApiService>()));

  // USER
  getIt.registerLazySingleton<UserService>(() => UserService());

  // TOKEN REPOSITORIES
  getIt.registerLazySingleton<TokenStorage<AuthTokenPair>>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TokenStorageImpl>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  // IMAGE REPOSITORIES
  getIt.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl());
}
