import 'package:locket/common/helper/utils.dart';

class PaginationModel {
  final int limit;
  final bool hasNextPage;
  final DateTime? nextCursor;

  PaginationModel({
    required this.limit,
    required this.hasNextPage,
    required this.nextCursor,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      limit: json['limit'],
      hasNextPage: json['hasNextPage'],
      nextCursor:
          json['nextCursor'] != null
              ? DateTime.parse(json['nextCursor'])
              : null,
    );
  }
}
