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
import 'package:locket/domain/auth/usecase/login_usecase.dart';
import 'package:locket/domain/feed/repositories/feed_repository.dart';
import 'package:locket/domain/feed/usecases/get_feed_usecase.dart';
import 'package:locket/domain/feed/usecases/upload_feed_usecase.dart';
import 'package:locket/domain/user/repositories/user_repository.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller_state.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/presentation/home/controllers/home/home_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller_state.dart';
import 'package:locket/presentation/user/controllers/user/user_controller.dart';
import 'package:locket/presentation/user/controllers/user/user_controller_state.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Core services
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Token storage - Only register the interface
  getIt.registerLazySingleton<TokenStorage<AuthTokenPair>>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Auth
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthApiService>()),
  );

  // User
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserApiService>()),
  );
  getIt.registerLazySingleton<UserApiService>(
    () => UserApiServiceImpl(getIt<DioClient>()),
  );

  // Feed
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(getIt<FeedApiService>()),
  );
  getIt.registerLazySingleton<FeedApiService>(
    () => FeedApiServiceImpl(getIt<DioClient>()),
  );

  // Services
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<FeedCacheService>(() => FeedCacheService());
  getIt.registerLazySingleton<Middleware>(() => Middleware());

  // Auth use cases
  getIt.registerFactory<LoginUsecase>(
    () => LoginUsecase(getIt<AuthRepository>()),
  );

  // User use cases
  getIt.registerFactory<GetProfileUsecase>(
    () => GetProfileUsecase(getIt<UserRepository>()),
  );

  // Home controller dependencies
  getIt.registerLazySingleton<HomeControllerState>(() => HomeControllerState());

  getIt.registerLazySingleton<HomeController>(
    () => HomeController(
      state: getIt<HomeControllerState>(),
      getProfileUsecase: getIt<GetProfileUsecase>(),
      userService: getIt<UserService>(),
    ),
  );

  // Auth controller dependencies
  getIt.registerLazySingleton<AuthControllerState>(() => AuthControllerState());

  getIt.registerLazySingleton<AuthController>(
    () => AuthController(
      state: getIt<AuthControllerState>(),
      loginUsecase: getIt<LoginUsecase>(),
      userService: getIt<UserService>(),
    ),
  );

  // User controller dependencies
  getIt.registerLazySingleton<UserControllerState>(() => UserControllerState());

  getIt.registerLazySingleton<UserController>(
    () => UserController(
      state: getIt<UserControllerState>(),
      getProfileUsecase: getIt<GetProfileUsecase>(),
      userService: getIt<UserService>(),
    ),
  );

  // Camera controller dependencies
  getIt.registerLazySingleton<CameraControllerState>(
    () => CameraControllerState(),
  );

  getIt.registerLazySingleton<CameraController>(
    () => CameraController(getIt<CameraControllerState>()),
  );

  // Feed controller dependencies
  getIt.registerLazySingleton<FeedControllerState>(() => FeedControllerState());

  getIt.registerFactory<GetFeedUsecase>(
    () => GetFeedUsecase(getIt<FeedRepository>()),
  );

  getIt.registerFactory<UploadFeedUsecase>(
    () => UploadFeedUsecase(getIt<FeedRepository>()),
  );

  getIt.registerLazySingleton<FeedController>(
    () => FeedController(
      state: getIt<FeedControllerState>(),
      cacheService: getIt<FeedCacheService>(),
      getFeedUsecase: getIt<GetFeedUsecase>(),
      uploadFeedUsecase: getIt<UploadFeedUsecase>(),
    ),
  );
}
