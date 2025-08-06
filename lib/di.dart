import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:get_it/get_it.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/core/routes/middleware.dart';
import 'package:locket/core/services/feed_cache_service.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/data/auth/repositories/token_store_impl.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/data/feed/respositories/feed_repository_impl.dart';
import 'package:locket/data/feed/services/feed_api_service.dart';
import 'package:locket/data/user/repositories/user_repository_impl.dart';
import 'package:locket/data/user/services/user_api_service.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';

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

  // // AUTH
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthApiService>()),
  );

  getIt.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(getIt<AuthApiService>()),
  );

  // USER
  getIt.registerLazySingleton<UserService>(() => UserService());

  getIt.registerLazySingleton<UserApiService>(
    () => UserApiServiceImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<UserRepositoryImpl>(
    () => UserRepositoryImpl(getIt<UserApiService>()),
  );

  // TOKEN
  getIt.registerLazySingleton<TokenStorage<AuthTokenPair>>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<TokenStorageImpl>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  // FEED
  getIt.registerLazySingleton<FeedApiService>(
    () => FeedApiServiceImpl(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<FeedRepositoryImpl>(
    () => FeedRepositoryImpl(getIt<FeedApiService>()),
  );

  getIt.registerLazySingleton<FeedCacheService>(() => FeedCacheService());

}
