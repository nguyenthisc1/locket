import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:locket/data/auth/models/auth_token_model.dart';
import 'package:logger/logger.dart';

/// LoggingInterceptor for debugging network requests and responses.
/// Uses the `logger` package for structured logging.
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('--> ${options.method} ${options.uri}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    _logger.i('--> END ${options.method}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('<-- ${response.statusCode} ${response.requestOptions.uri}');
    _logger.d('Response: ${response.data}');
    _logger.i('<-- END HTTP');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('*** DioError ***');
    _logger.e('URI: ${err.requestOptions.uri}');
    _logger.e('Message: ${err.message}');
    if (err.response != null) {
      _logger.e('Response: ${err.response}');
    }
    _logger.e('*** End DioError ***');
    super.onError(err, handler);
  }
}

/// AuthInterceptor for adding Authorization token to requests.
/// Uses flutter_secure_storage to retrieve the token with key 'auth_token'.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Optionally log or handle token retrieval errors
    }
    super.onRequest(options, handler);
  }
}

/// Enhanced AuthInterceptor with automatic token refresh
class EnhancedAuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;
  final String _refreshTokenUrl;
  final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  // Track refresh attempts to prevent infinite loops
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  EnhancedAuthInterceptor({
    required Dio dio,
    required String refreshTokenUrl,
    FlutterSecureStorage? storage,
  }) : _dio = dio,
       _refreshTokenUrl = refreshTokenUrl,
       _storage = storage ?? const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for refresh token requests to prevent loops
    if (options.path.contains('refresh')) {
      super.onRequest(options, handler);
      return;
    }

    try {
      final tokens = await TokenManager.loadTokens();
      if (tokens != null && !tokens.isExpired) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        super.onRequest(options, handler);
        return;
      }

      // Token is expired or will expire soon, try to refresh
      if (tokens != null && tokens.willExpireSoon && !_isRefreshing) {
        _logger.d('🔄 Token expiring soon, attempting refresh');
        await _refreshTokenAndRetry(options, handler);
        return;
      }

      // No valid token, proceed without auth header
      super.onRequest(options, handler);
    } catch (e) {
      _logger.e('❌ Auth interceptor error: $e');
      super.onRequest(options, handler);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _logger.d('🔄 401 error, attempting token refresh');

      // Add request to pending queue
      _pendingRequests.add(err.requestOptions);

      try {
        await _refreshTokenAndRetry(err.requestOptions, null, isError: true);
        return;
      } catch (refreshError) {
        _logger.e('❌ Token refresh failed: $refreshError');
        // Clear tokens on refresh failure
        await TokenManager.clearTokens();
        handler.reject(err);
        return;
      }
    }

    super.onError(err, handler);
  }

  Future<void> _refreshTokenAndRetry(
    RequestOptions options,
    RequestInterceptorHandler? handler, {
    bool isError = false,
  }) async {
    if (_isRefreshing) {
      // Wait for current refresh to complete
      await _waitForRefresh();
      _retryRequest(options, handler, isError);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Call refresh token endpoint
      final response = await _dio.post(
        _refreshTokenUrl,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        // Save new tokens
        final newTokens = AuthTokenModel(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String? ?? refreshToken,
        );

        await TokenManager.saveTokens(newTokens);
        _logger.d('✅ Token refresh successful');

        // Retry original request
        _retryRequest(options, handler, isError);

        // Retry all pending requests
        for (final pendingRequest in _pendingRequests) {
          _retryRequest(pendingRequest, null, false);
        }
        _pendingRequests.clear();
      } else {
        throw Exception('Token refresh failed');
      }
    } catch (e) {
      _logger.e('❌ Token refresh error: $e');
      // Clear tokens on refresh failure
      await TokenManager.clearTokens();

      if (handler != null) {
        handler.reject(
          DioException(requestOptions: options, error: 'Authentication failed'),
        );
      }
    } finally {
      _isRefreshing = false;
    }
  }

  void _retryRequest(
    RequestOptions options,
    RequestInterceptorHandler? handler,
    bool isError,
  ) async {
    try {
      final tokens = await TokenManager.loadTokens();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }

      final response = await _dio.fetch(options);

      if (handler != null) {
        handler.resolve(response);
      }
    } catch (e) {
      if (handler != null) {
        handler.reject(DioException(requestOptions: options, error: e));
      }
    }
  }

  Future<void> _waitForRefresh() async {
    while (_isRefreshing) {
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
}

/// Helper function to add interceptors to a Dio instance.
/// Extend this to add more interceptors as needed.
///
/// If [useAuth] is true, adds AuthInterceptor using flutter_secure_storage.
/// If [useEnhancedAuth] is true, adds EnhancedAuthInterceptor with automatic token refresh.
void addInterceptors(
  Dio dio, {
  bool useAuth = false,
  bool useEnhancedAuth = false,
  String? refreshTokenUrl,
  FlutterSecureStorage? storage,
}) {
  dio.interceptors.add(LoggingInterceptor());

  if (useEnhancedAuth && refreshTokenUrl != null) {
    dio.interceptors.add(
      EnhancedAuthInterceptor(
        dio: dio,
        refreshTokenUrl: refreshTokenUrl,
        storage: storage,
      ),
    );
  } else if (useAuth) {
    dio.interceptors.add(AuthInterceptor(storage: storage));
  }

  // Add more interceptors here if needed
}
