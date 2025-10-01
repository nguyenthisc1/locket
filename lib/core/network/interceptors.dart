import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:logger/logger.dart';

/// This interceptor is used to show request and response logs
class LoggerInterceptor extends Interceptor {
  Logger logger = Logger(
    printer: PrettyPrinter(methodCount: 0, colors: true, printEmojis: true),
  );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final requestPath = '${options.baseUrl}${options.path}';
    logger.e('${options.method} request ==> $requestPath'); //Error log
    logger.d(
      'Error type: ${err.error} \n '
      'Error message: ${err.message}',
    ); //Debug log
    handler.next(err); //Continue with the Error
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestPath = '${options.baseUrl}${options.path}';
    logger.i('${options.method} request ==> $requestPath'); //Info log
    handler.next(options); // continue with the Request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      'STATUSCODE: ${response.statusCode} \n '
      'STATUSMESSAGE: ${response.statusMessage} \n'
      'HEADERS: ${response.headers} \n'
      'Data: ${response.data}',
    ); // Debug log
    handler.next(response); // continue with the Response
  }
}

/// AuthorizationInterceptor
///
/// Adds the Authorization header with the Bearer token to outgoing requests.
/// Handles missing or empty tokens gracefully and logs issues for debugging.
/// Also validates token expiration and clears expired tokens.
class AuthorizationInterceptor extends Interceptor {
  final TokenStorage<AuthTokenPair> _tokenStorage;
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  AuthorizationInterceptor(this._tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      _logger.d('🔐 AuthorizationInterceptor: Checking for token...');
      final tokenPair = await _tokenStorage.read();

      if (tokenPair?.accessToken != null && tokenPair!.accessToken.isNotEmpty) {
        // Check if access token is expired
        if (tokenPair.isAccessTokenExpired) {
          _logger.w('⚠️ Access token is expired, clearing storage');
          await _tokenStorage.delete();
          _logger.d(
            '🔐 AuthorizationInterceptor: Proceeding without Authorization header (token expired)',
          );
        } else {
          // Token is valid, add to headers
          options.headers['Authorization'] = 'Bearer ${tokenPair.accessToken}';
          _logger.d('🔐 AuthorizationInterceptor: Added Authorization header');

          // Log remaining time for debugging
          final remainingTime = tokenPair.accessTokenRemainingTime;
          if (remainingTime != null) {
            _logger.d('🕒 Token expires in: ${_formatDuration(remainingTime)}');

            // Warn if token will expire soon
            if (remainingTime.inMinutes < 10) {
              _logger.w(
                '⚠️ Token will expire soon: ${_formatDuration(remainingTime)}',
              );
            }
          }
        }
      } else {
        _logger.w('🔐 AuthorizationInterceptor: No token found in storage');
      }
      handler.next(options); // continue with the Request
    } catch (e) {
      _logger.e('🔐 AuthorizationInterceptor error: $e');
      // Clear potentially corrupted tokens
      try {
        await _tokenStorage.delete();
      } catch (deleteError) {
        _logger.e('Failed to clear tokens after error: $deleteError');
      }
      handler.next(options); // continue without Authorization header
    }
  }

  /// Format duration for logging
  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Interceptor for handling token refresh logic using Fresh
///
/// This class encapsulates the configuration for token management,
/// including automatic token refresh and header injection.
/// It is designed for maintainability and extensibility.
class TokenRefreshInterceptor extends Interceptor {
  final TokenStorage<AuthTokenPair> _tokenStorage;

  /// Constructs a [TokenRefreshInterceptor] with the provided [TokenStorage].
  TokenRefreshInterceptor(this._tokenStorage);

  /// Returns a configured [Fresh] interceptor for token management.
  Fresh<AuthTokenPair> get fresh {
    final Logger logger = Logger(
      printer: PrettyPrinter(colors: true, printEmojis: true),
    );

    logger.d('🔧 Creating Fresh interceptor instance');

    return Fresh<AuthTokenPair>(
      tokenStorage: _tokenStorage,
      tokenHeader: (token) {
        // Add the access token to the Authorization header for each request.
        logger.d(
          '🔑 TokenHeader called with token: Token exists (${token.accessToken.length} chars)',
        );

        if (token.accessToken.isEmpty) {
          // Defensive: Do not add header if token is missing.
          logger.w(
            '⚠️ No access token available, skipping Authorization header',
          );
          return <String, String>{};
        }

        // Check if token is expired before adding header
        if (token.isAccessTokenExpired) {
          logger.w('⚠️ Access token is expired, skipping Authorization header');
          return <String, String>{};
        }

        logger.d('✅ Adding Authorization header with token');

        // Log remaining time for debugging
        final remainingTime = token.accessTokenRemainingTime;
        if (remainingTime != null && remainingTime.inMinutes < 10) {
          logger.w('⚠️ Token will expire soon: ${remainingTime.inMinutes}m');
        }

        return {'Authorization': 'Bearer ${token.accessToken}'};
      },
      refreshToken: (token, client) async {
        // Attempt to refresh the token when a 401 is encountered.
        final Logger logger = Logger(
          printer: PrettyPrinter(colors: true, printEmojis: true),
        );

        logger.d('🔄 Refresh token called');

        if (token == null ||
            token.refreshToken.isEmpty ||
            token.accessToken.isEmpty) {
          // Defensive: If tokens are missing, trigger logout.
          logger.e('❌ Token refresh failed: Missing tokens');
          throw RevokeTokenException();
        }

        // Check if refresh token is expired
        if (token.isRefreshTokenExpired) {
          logger.e('❌ Token refresh failed: Refresh token is expired');
          throw RevokeTokenException();
        }
        try {
          final response = await client.post(
            ApiUrl.refreshToken,
            data: {
              'refreshToken': token.refreshToken,
              'accessToken': token.accessToken,
            },
          );

          final newTokens = response.data;
          if (newTokens == null ||
              newTokens['accessToken'] == null ||
              newTokens['refreshToken'] == null) {
            // Defensive: If response is malformed, trigger logout.
            throw RevokeTokenException();
          }

          return AuthTokenPair(
            accessToken: newTokens['accessToken'] as String,
            refreshToken: newTokens['refreshToken'] as String,
          );
        } catch (e) {
          // If refresh fails, throw to trigger logout.
          throw RevokeTokenException();
        }
      },
      shouldRefresh: (response) {
        // Only attempt refresh on HTTP 401 Unauthorized.
        final shouldRefresh = response?.statusCode == 401;
        logger.d(
          '🔄 ShouldRefresh called: ${response?.statusCode} -> $shouldRefresh',
        );
        return shouldRefresh;
      },
    );
  }
}
