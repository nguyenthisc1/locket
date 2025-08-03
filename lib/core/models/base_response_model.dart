class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic error;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error'],
    );
  }
}