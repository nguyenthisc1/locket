import 'package:equatable/equatable.dart';

class SharedWithUser extends Equatable {
  final String id;
  final String? username;

  const SharedWithUser({
    required this.id,
    this.username,
  });

  factory SharedWithUser.fromJson(Map<String, dynamic> json) {
    return SharedWithUser(
      id: json['_id'] as String? ?? json['id'] as String,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'username': username,
      };

  @override
  List<Object?> get props => [id, username];
}
