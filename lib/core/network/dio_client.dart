import 'package:dio/dio.dart';
import 'package:locket/core/constants/api_url.dart';
import 'package:locket/core/network/interceptors.dart';

class DioClient {
  final Dio _dio;

  DioClient({BaseOptions? options})
    : _dio = Dio(
        options ??
            BaseOptions(
              baseUrl: ApiUrl.api,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                // Add more default headers here if needed
              },
            ),
      ) {
    // Add interceptors (e.g., logging, auth, etc.)
    addInterceptors(_dio);
  }

  /// Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw Exception('GET request failed: ${e.message}');
    }
  }

  /// Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw Exception('POST request failed: ${e.message}');
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw Exception('PUT request failed: ${e.message}');
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw Exception('DELETE request failed: ${e.message}');
    }
  }

  /// Access to the underlying Dio instance for advanced use cases
  Dio get dio => _dio;
}
