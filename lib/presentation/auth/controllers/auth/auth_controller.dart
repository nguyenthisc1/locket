import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/services/socket_service.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/auth/usecase/login_usecase.dart';
import 'package:locket/presentation/auth/controllers/auth/auth_controller_state.dart';
import 'package:logger/logger.dart';

/// Business logic controller for authentication
class AuthController {
  final AuthControllerState _state;
  final LoginUsecase _loginUsecase;
  final UserService _userService;
  final SocketService _socketService;
  final Logger _logger;

  AuthController({
    required AuthControllerState state,
    required LoginUsecase loginUsecase,
    required UserService userService,
    required SocketService socketService,
    Logger? logger,
  }) : _state = state,
       _loginUsecase = loginUsecase,
       _userService = userService,
       _socketService = socketService,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true));

  // Getters for external access
  AuthControllerState get state => _state;

  /// Initialize auth state (check if user is already logged in)
  Future<void> init() async {
    try {
      _logger.d('Auth init started');
      final tokenStorage = getIt<TokenStorage<AuthTokenPair>>();
      final tokenPair = await tokenStorage.read();

      _logger.d(
        'Token read from storage: ${tokenPair != null ? 'Found' : 'Not found'}',
      );
      if (tokenPair != null) {
        _logger.d('Access token length: ${tokenPair.accessToken.length}');
        _logger.d('Refresh token length: ${tokenPair.refreshToken.length}');
      }

      await _userService.loadUserFromStorage();
      _logger.d(
        'User service loaded. Is logged in: ${_userService.isLoggedIn}',
      );

      // If accessToken is null, clear all user data and tokens
      if (tokenPair?.accessToken == null) {
        await _userService.clearUser();
        await tokenStorage.delete();
        _state.reset();
        _logger.d('Access token is null. Cleared user, tokens, and state.');
        return;
      }

      if (_userService.isLoggedIn) {
        // Convert UserProfileModel to UserEntity if needed
        _state.setLoggedIn(true);
        _logger.d('User already logged in: ${_userService.currentUser?.email}');

        // Initialize Socket.IO connection
        await _initializeSocketConnection();
      } else {
        _logger.d(
          'Token exists but user is not logged in - potential sync issue',
        );
      }
    } catch (e) {
      _logger.e('Error initializing auth: $e');
    }
  }

  /// Handle user login
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _state.setLoading(true);
    _state.clearError();

    try {
      final result = await _loginUsecase.call(
        identifier: identifier,
        password: password,
      );

      return result.fold(
        (failure) async {
          _logger.e('Login failed: ${failure.message}');
          _state.setError(failure.message);
          return false;
        },
        (response) async {
          _logger.d('Login successful');
          _state.setLoggedIn(true);
          _state.clearError();

          // Give a small delay to ensure token storage is complete
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify token was stored after login
          await _verifyTokenAfterLogin();

          return true;
        },
      );
    } catch (e) {
      _logger.e('Login error: $e');
      _state.setError('An unexpected error occurred');
      return false;
    } finally {
      _state.setLoading(false);
    }
  }

  /// Handle user logout
  Future<void> logout() async {
    try {
      final tokenStorage = getIt<TokenStorage<AuthTokenPair>>();

      // Disconnect Socket.IO connection
      await _socketService.disconnect();
      await tokenStorage.delete();
      await _userService.clearUser();
      _state.reset();
      _logger.d('User logged out successfully');
    } catch (e) {
      _logger.e('Logout error: $e');
      _state.setError('Failed to logout');
    }
  }

  /// Initialize Socket.IO connection
  Future<void> _initializeSocketConnection() async {
    try {
      final currentUser = _userService.currentUser;
      final tokenStorage = getIt<TokenStorage<AuthTokenPair>>();
      final tokenPair = await tokenStorage.read();

      if (currentUser != null && tokenPair?.accessToken != null) {
        await _socketService.initialize(
          serverUrl: ApiUrl.socketUrl,
          userId: currentUser.id,
          authToken: tokenPair!.accessToken,
        );

        // Give socket a moment to auto-connect, then check status
        await Future.delayed(const Duration(milliseconds: 500));

        // Check connection status and manually connect if needed
        _socketService.checkConnectionStatus();

        if (!_socketService.isConnected) {
          _logger.w(
            '🔄 Socket not connected after initialization, attempting manual connection...',
          );
          await _socketService.connect();

          // Wait a bit more and check again
          await Future.delayed(const Duration(milliseconds: 1000));
          _socketService.checkConnectionStatus();
        }

        _logger.d(
          '🔌 Socket.IO connection initialized for user: ${currentUser.email}',
        );
      }
    } catch (e) {
      _logger.e('❌ Failed to initialize Socket.IO connection: $e');
      // Don't throw error here as it shouldn't block the login process
    }
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _state.setObscurePassword(!_state.obscurePassword);
  }

  /// Clear any error messages
  void clearError() {
    _state.clearError();
  }

  /// Verify token storage after successful login
  Future<void> _verifyTokenAfterLogin() async {
    try {
      final tokenStorage = getIt<TokenStorage<AuthTokenPair>>();
      final tokenPair = await tokenStorage.read();

      if (tokenPair?.accessToken != null && tokenPair!.accessToken.isNotEmpty) {
        _logger.d('Token verification successful after login');
      } else {
        _logger.e(
          'Token verification failed after login - token is null or empty',
        );
      }
    } catch (e) {
      _logger.e('Error verifying token after login: $e');
    }
  }
}
