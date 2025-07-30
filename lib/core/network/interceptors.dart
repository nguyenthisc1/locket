import 'package:dio/dio.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/data/auth/models/token_model.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
class AuthorizationInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final sharedPreferences = await SharedPreferences.getInstance();
      final token = sharedPreferences.getString('token');

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      } else {
        // Optionally log or handle missing token scenario
        // For example: print('AuthorizationInterceptor: No token found.');
      }
      handler.next(options); // continue with the Request
    } catch (e) {
      // Handle unexpected errors in token retrieval
      // For example: print('AuthorizationInterceptor error: $e');
      handler.next(options); // continue without Authorization header
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
  Fresh<AuthTokenPair> get fresh => Fresh<AuthTokenPair>(
        tokenStorage: _tokenStorage,
        tokenHeader: (token) {
          // Add the access token to the Authorization header for each request.
          if (token == null || token.accessToken.isEmpty) {
            // Defensive: Do not add header if token is missing.
            return <String, String>{};
          }
          return {'Authorization': 'Bearer ${token.accessToken}'};
        },
        refreshToken: (token, client) async {
          // Attempt to refresh the token when a 401 is encountered.
          if (token == null ||
              token.refreshToken.isEmpty ||
              token.accessToken.isEmpty) {
            // Defensive: If tokens are missing, trigger logout.
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
          return response?.statusCode == 401;
        },
      );
}

