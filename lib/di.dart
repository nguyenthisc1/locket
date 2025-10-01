import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:get_it/get_it.dart';
import 'package:locket/core/network/dio_client.dart';
import 'package:locket/core/routes/middleware.dart';
import 'package:locket/core/services/conversation_cache_service.dart';
import 'package:locket/core/services/conversation_detail_cache_service.dart';
import 'package:locket/core/services/feed_cache_service.dart';
import 'package:locket/core/services/message_cache_service.dart';
import 'package:locket/core/services/socket_service.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/data/auth/repositories/auth_repository_impl.dart';
import 'package:locket/data/auth/repositories/token_store_impl.dart';
import 'package:locket/data/auth/services/auth_api_service.dart';
import 'package:locket/data/conversation/repositories/conversation_repository_impl.dart';
import 'package:locket/data/conversation/repositories/message_repository_impl.dart';
import 'package:locket/data/conversation/services/conversation_api_service.dart';
import 'package:locket/data/conversation/services/message_api_service.dart';
import 'package:locket/data/feed/respositories/feed_repository_impl.dart';
import 'package:locket/data/feed/services/feed_api_service.dart';
import 'package:locket/data/user/repositories/user_repository_impl.dart';
import 'package:locket/data/user/services/user_api_service.dart';
import 'package:locket/domain/auth/repositories/auth_repository.dart';
import 'package:locket/domain/auth/usecase/login_usecase.dart';
import 'package:locket/domain/conversation/repositories/conversation_repository.dart';
import 'package:locket/domain/conversation/repositories/message_repository.dart';
import 'package:locket/domain/conversation/usecases/get_conversations_usecase.dart';
import 'package:locket/domain/conversation/usecases/get_messages_conversation_usecase.dart';
import 'package:locket/domain/conversation/usecases/mark_conversation_as_read_usecase.dart';
import 'package:locket/domain/conversation/usecases/send_message_usecase.dart';
import 'package:locket/domain/conversation/usecases/unread_count_conversations_usecase.dart';
import 'package:locket/domain/feed/repositories/feed_repository.dart';
import 'package:locket/domain/feed/usecases/get_feed_usecase.dart';
import 'package:locket/domain/feed/usecases/upload_feed_usecase.dart';
import 'package:locket/domain/user/repositories/user_repository.dart';
import 'package:locket/domain/user/usecase/get_profile_usecase.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller_state.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller.dart';
import 'package:locket/presentation/home/controllers/camera/camera_controller_state.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/presentation/home/controllers/home/home_controller.dart';
import 'package:locket/presentation/home/controllers/home/home_controller_state.dart';
import 'package:locket/presentation/user/controllers/user/user_controller.dart';
import 'package:locket/presentation/user/controllers/user/user_controller_state.dart';
import 'package:locket/domain/conversation/usecases/get_conversation_detail_usecase.dart';


final getIt = GetIt.instance;

void setupDependencies() {
  // Core services
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // Token storage - Only register the interface
  getIt.registerLazySingleton<TokenStorage<AuthTokenPair>>(
    () => TokenStorageImpl(getIt<FlutterSecureStorage>()),
  );

  // Services
  getIt.registerLazySingleton<UserService>(() => UserService());
  getIt.registerLazySingleton<FeedCacheService>(() => FeedCacheService());
  getIt.registerLazySingleton<ConversationCacheService>(() => ConversationCacheService());
  getIt.registerLazySingleton<ConversationDetailCacheService>(() => ConversationDetailCacheService());
  getIt.registerLazySingleton<MessageCacheService>(() => MessageCacheService());
  getIt.registerLazySingleton<SocketService>(() => SocketService());
  getIt.registerLazySingleton<Middleware>(() => Middleware());

  // API Services
  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiServiceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<UserApiService>(
    () => UserApiServiceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<FeedApiService>(
    () => FeedApiServiceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<ConversationApiService>(
    () => ConversationApiServiceImpl(getIt<DioClient>()),
  );
  getIt.registerLazySingleton<MessageApiService>(
    () => MessageApiServiceImpl(getIt<DioClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthApiService>()),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserApiService>()),
  );
  getIt.registerLazySingleton<FeedRepository>(
    () => FeedRepositoryImpl(getIt<FeedApiService>()),
  );
  getIt.registerLazySingleton<ConversationRepository>(
    () => ConversationRepositoryImpl(getIt<ConversationApiService>()),
  );
  getIt.registerLazySingleton<MessageRepository>(
    () => MessageRepositoryImpl(getIt<MessageApiService>()),
  );

  // Use Cases
  // Auth use cases
  getIt.registerFactory<LoginUsecase>(
    () => LoginUsecase(getIt<AuthRepository>()),
  );
  // User use cases
  getIt.registerFactory<GetProfileUsecase>(
    () => GetProfileUsecase(getIt<UserRepository>()),
  );
  // Conversation use cases
  getIt.registerFactory<GetConversationsUsecase>(
    () => GetConversationsUsecase(getIt<ConversationRepository>()),
  );
   getIt.registerFactory<GetConversationDetailUsecase>(
    () => GetConversationDetailUsecase(getIt<ConversationRepository>()),
  );
  getIt.registerFactory<UnreadCountConversationsUsecase>(
    () => UnreadCountConversationsUsecase(getIt<ConversationRepository>()),
  );
   getIt.registerFactory<MarkConversationAsReadUsecase>(
    () => MarkConversationAsReadUsecase(getIt<ConversationRepository>()),
  );

  // Message use cases
  getIt.registerFactory<GetMessagesConversationUsecase>(
    () => GetMessagesConversationUsecase(getIt<MessageRepository>()),
  );
  getIt.registerFactory<SendMessageUsecase>(
    () => SendMessageUsecase(getIt<MessageRepository>()),
  );

  // Feed use cases
  getIt.registerFactory<GetFeedsUsecase>(
    () => GetFeedsUsecase(getIt<FeedRepository>()),
  );
  getIt.registerFactory<UploadFeedUsecase>(
    () => UploadFeedUsecase(getIt<FeedRepository>()),
  );

  // Controller States
  getIt.registerLazySingleton<HomeControllerState>(() => HomeControllerState());
  getIt.registerLazySingleton<ConversationControllerState>(() => ConversationControllerState());
  // ConversationDetailControllerState NOT registered in DI - created locally to avoid shared state
  getIt.registerLazySingleton<AuthControllerState>(() => AuthControllerState());
  getIt.registerLazySingleton<UserControllerState>(() => UserControllerState());
  getIt.registerLazySingleton<CameraControllerState>(() => CameraControllerState());
  getIt.registerLazySingleton<FeedControllerState>(() => FeedControllerState());

  // Controllers
  // Home controller dependencies
  getIt.registerFactory<HomeController>(
    () => HomeController(
      state: getIt<HomeControllerState>(),
      getProfileUsecase: getIt<GetProfileUsecase>(),
      userService: getIt<UserService>(),
    ),
  );
  // Conversation controller dependencies
  getIt.registerLazySingleton<ConversationController>(
    () => ConversationController(
      state: getIt<ConversationControllerState>(),
      cacheService: getIt<ConversationCacheService>(),
      getConversationsUsecase: getIt<GetConversationsUsecase>(),
      getConversationDetailUsecase: getIt<GetConversationDetailUsecase>(),
      unreadCountConversationsUsecase: getIt<UnreadCountConversationsUsecase>(),
      socketService: getIt<SocketService>(),
    ),
  );

  // ConversationDetailController NOT registered in DI - created locally to avoid shared state between conversations

  // Auth controller dependencies
  getIt.registerLazySingleton<AuthController>(
    () => AuthController(
      state: getIt<AuthControllerState>(),
      loginUsecase: getIt<LoginUsecase>(),
      userService: getIt<UserService>(),
      socketService: getIt<SocketService>(),
    ),
  );
  // User controller dependencies
  getIt.registerLazySingleton<UserController>(
    () => UserController(
      state: getIt<UserControllerState>(),
      getProfileUsecase: getIt<GetProfileUsecase>(),
      userService: getIt<UserService>(),
    ),
  );
  // Camera controller dependencies
  getIt.registerLazySingleton<CameraController>(
    () => CameraController(getIt<CameraControllerState>()),
  );
  // Feed controller dependencies
  getIt.registerLazySingleton<FeedController>(
    () => FeedController(
      state: getIt<FeedControllerState>(),
      cacheService: getIt<FeedCacheService>(),
      getFeedsUsecase: getIt<GetFeedsUsecase>(),
      uploadFeedUsecase: getIt<UploadFeedUsecase>(),
    ),
  );
}
