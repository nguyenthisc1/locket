import 'package:equatable/equatable.dart';

class ReactionModel extends Equatable {
  final String userId;
  final String type; // e.g., ❤️ 😂 😮 etc.
  final DateTime createdAt;

  const ReactionModel({
    required this.userId,
    required this.type,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      userId: json['userId'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [userId, type, createdAt];
}
