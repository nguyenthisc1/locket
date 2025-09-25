import 'package:equatable/equatable.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/entities/last_message_entity.dart';

class LastMessageModel extends Equatable {
  final String messageId;
  final String text;
  final String senderId;
  final DateTime timestamp;

  const LastMessageModel({
    required this.messageId,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      messageId: json['messageId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      timestamp: DateTimeUtils.parseDateTime(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'text': text,
      'senderId': senderId,
      'timestamp': DateTimeUtils.toIsoString(timestamp),
    };
  }

  /// Creates a LastMessageModel from a LastMessageEntity
  factory LastMessageModel.fromEntity(LastMessageEntity entity) {
    return LastMessageModel(
      messageId: entity.messageId,
      text: entity.text,
      senderId: entity.senderId,
      timestamp: entity.timestamp,
    );
  }

  /// Creates a LastMessageModel from another LastMessageModel (copy)
  factory LastMessageModel.fromModel(LastMessageModel model) {
    return LastMessageModel(
      messageId: model.messageId,
      text: model.text,
      senderId: model.senderId,
      timestamp: model.timestamp,
    );
  }

  @override
  List<Object?> get props => [messageId, text, senderId, timestamp];
}