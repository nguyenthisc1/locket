import 'package:equatable/equatable.dart';

class PaginationEntity extends Equatable {
  final int limit;
  final bool hasNextPage;
  final DateTime? nextCursor;

  PaginationEntity({
    required this.limit,
    required this.hasNextPage,
    required this.nextCursor,
  });

  @override
  List<Object?> get props => [limit, hasNextPage, nextCursor];
}
