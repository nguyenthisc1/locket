import 'package:equatable/equatable.dart';
import 'package:locket/common/helper/utils.dart';

class LastMessageEntity extends Equatable {
  final String messageId;
  final String text;
  final String senderId;
  final DateTime timestamp;

  const LastMessageEntity({
    required this.messageId,
    required this.text,
    required this.senderId,
    required this.timestamp,
  });

  factory LastMessageEntity.fromJson(Map<String, dynamic> json) {
    return LastMessageEntity(
      messageId: json['messageId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      timestamp: DateTimeUtils.parseDateTime(json['timestamp']),
    );
  }

  /// Creates a LastMessageEntity from a LastMessageModel
  factory LastMessageEntity.fromModel(dynamic model) {
    // Accepts a model with the same fields as LastMessageModel
    return LastMessageEntity(
      messageId: model.messageId,
      text: model.text,
      senderId: model.senderId,
      timestamp: model.timestamp,
    );
  }

  /// Creates a LastMessageEntity from another LastMessageEntity (clone)
  factory LastMessageEntity.fromEntity(LastMessageEntity entity) {
    return LastMessageEntity(
      messageId: entity.messageId,
      text: entity.text,
      senderId: entity.senderId,
      timestamp: entity.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
        'senderId': senderId,
        'timestamp': DateTimeUtils.toIsoString(timestamp),
      };

  @override
  List<Object?> get props => [messageId, text, senderId, timestamp];
}
