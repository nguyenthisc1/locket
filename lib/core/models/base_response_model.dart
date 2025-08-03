class BaseResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final dynamic errors;

  const BaseResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return BaseResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      errors: json['error'],
    );
  }
}