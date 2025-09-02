import 'package:equatable/equatable.dart';
import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/core/models/sender_model.dart';

class LastMessageModel extends Equatable {
  final String messageId;
  final String text;
  final SenderModel sender;
  final DateTime timestamp;
  final bool isRead;

  const LastMessageModel({
    required this.messageId,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.isRead,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      messageId: json['messageId'] as String,
      text: json['text'] as String,
      sender: json['sender'] is Map<String, dynamic>
          ? SenderModel.fromJson(json['sender'] as Map<String, dynamic>)
          : throw ArgumentError('Invalid sender format in LastMessageModel.fromJson'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'text': text,
      'sender': sender.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  /// Creates a LastMessageModel from a LastMessageEntity
  factory LastMessageModel.fromEntity(LastMessageEntity entity) {
    return LastMessageModel(
      messageId: entity.messageId,
      text: entity.text,
      sender: SenderModel.fromEntity(entity.sender),
      timestamp: entity.timestamp,
      isRead: entity.isRead,
    );
  }

  /// Creates a LastMessageModel from another LastMessageModel (copy)
  factory LastMessageModel.fromModel(LastMessageModel model) {
    return LastMessageModel(
      messageId: model.messageId,
      text: model.text,
      sender: model.sender,
      timestamp: model.timestamp,
      isRead: model.isRead,
    );
  }

  @override
  List<Object?> get props => [messageId, text, sender, timestamp, isRead];
}