import 'package:get_it/get_it.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Register DioClient as a singleton
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Register AuthApiService as a singleton, injecting DioClient
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(getIt<DioClient>()),
  );

  // Register other services/repositories as needed
}