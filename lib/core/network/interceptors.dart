import 'package:dio/dio.dart';
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
/// Replace the token retrieval logic with your actual implementation.
class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;

  AuthInterceptor({required this.getToken});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      // Optionally log or handle token retrieval errors
    }
    super.onRequest(options, handler);
  }
}

/// Helper function to add interceptors to a Dio instance.
/// Extend this to add more interceptors as needed.
///
/// [getToken] should be a function that returns a Future<String?> for the auth token.
void addInterceptors(Dio dio, {Future<String?> Function()? getToken}) {
  dio.interceptors.add(LoggingInterceptor());
  if (getToken != null) {
    dio.interceptors.add(AuthInterceptor(getToken: getToken));
  }
  // Add more interceptors here if needed
}
