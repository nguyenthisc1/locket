import 'package:equatable/equatable.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/entities/sender_entity.dart';

class LastMessageEntity extends Equatable {
  final String messageId;
  final String text;
  final SenderEntity sender;
  final DateTime timestamp;
  final bool isRead;

  const LastMessageEntity({
    required this.messageId,
    required this.text,
    required this.sender,
    required this.timestamp,
    required this.isRead,
  });

  factory LastMessageEntity.fromJson(Map<String, dynamic> json) {
    return LastMessageEntity(
      messageId: json['messageId'] as String,
      text: json['text'] as String,
      sender: json['sender'] is Map<String, dynamic>
          ? SenderEntity.fromJson(json['sender'] as Map<String, dynamic>)
          : throw ArgumentError('Invalid sender format in LastMessageEntity.fromJson'),
      timestamp: DateTimeUtils.parseDateTime(json['timestamp']),
      isRead: json['isRead'] as bool,
    );
  }

  /// Creates a LastMessageEntity from a LastMessageModel
  factory LastMessageEntity.fromModel(dynamic model) {
    // Accepts a model with the same fields as LastMessageModel
    return LastMessageEntity(
      messageId: model.messageId,
      text: model.text,
      sender: SenderEntity(
        id: model.sender.id,
        username: model.sender.username,
        avatarUrl: model.sender.avatarUrl,
      ),
      timestamp: model.timestamp,
      isRead: model.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'text': text,
        'sender': sender,
        'timestamp': DateTimeUtils.toIsoString(timestamp),
        'isRead': isRead,
      };

  @override
  List<Object?> get props => [messageId, text, sender, timestamp, isRead];
}
