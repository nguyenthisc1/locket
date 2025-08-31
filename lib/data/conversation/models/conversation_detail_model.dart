import 'package:equatable/equatable.dart';
import 'package:locket/domain/conversation/entities/conversation_detail_entity.dart';
import 'converstation_model.dart';

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
      messageId: json['messageId'] as String,
      text: json['text'] as String,
      senderId: json['senderId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
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

class ThreadInfoModel extends Equatable {
  final int threadCount;

  const ThreadInfoModel({required this.threadCount});

  factory ThreadInfoModel.fromJson(Map<String, dynamic> json) {
    return ThreadInfoModel(threadCount: json['threadCount'] as int? ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'threadCount': threadCount};
  }

  @override
  List<Object?> get props => [threadCount];
}

class ConversationDetailModel extends Equatable {
  final String id;
  final String? name;
  final List<ConversationParticipantModel> participants;
  final bool isGroup;
  final GroupSettingsModel? groupSettings;
  final LastMessageModel? lastMessage;
  final ThreadInfoModel? threadInfo;
  final bool isActive;
  final List<dynamic> pinnedMessages;
  final ConversationSettingsModel settings;
  final DateTime startedAt;
  final List<dynamic> readReceipts;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ConversationDetailModel({
    required this.id,
    this.name,
    required this.participants,
    required this.isGroup,
    this.groupSettings,
    this.lastMessage,
    this.threadInfo,
    required this.isActive,
    required this.pinnedMessages,
    required this.settings,
    required this.startedAt,
    required this.readReceipts,
    required this.createdAt,
    this.updatedAt,
  });

  /// Accepts both a List or a single Map for participants.
  static List<ConversationParticipantModel> _parseParticipants(dynamic jsonValue) {
    if (jsonValue == null) return [];
    if (jsonValue is List) {
      return jsonValue
          .map((e) => ConversationParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (jsonValue is Map<String, dynamic>) {
      // Single participant as object
      return [ConversationParticipantModel.fromJson(jsonValue)];
    }
    return [];
  }

  factory ConversationDetailModel.fromJson(Map<String, dynamic> json) {
    return ConversationDetailModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      participants: _parseParticipants(json['participants']),
      isGroup: json['isGroup'] as bool? ?? false,
      groupSettings: json['groupSettings'] != null
          ? GroupSettingsModel.fromJson(json['groupSettings'] as Map<String, dynamic>)
          : null,
      lastMessage: json['lastMessage'] != null
          ? LastMessageModel.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      threadInfo: json['threadInfo'] != null
          ? ThreadInfoModel.fromJson(json['threadInfo'] as Map<String, dynamic>)
          : null,
      isActive: json['isActive'] as bool? ?? false,
      pinnedMessages: List<dynamic>.from(json['pinnedMessages'] ?? []),
      settings: ConversationSettingsModel.fromJson(json['settings'] ?? {}),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ?? DateTime.now(),
      readReceipts: List<dynamic>.from(json['readReceipts'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participants': participants.map((e) => e.toJson()).toList(),
      'isGroup': isGroup,
      'groupSettings': groupSettings?.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'threadInfo': threadInfo?.toJson(),
      'isActive': isActive,
      'pinnedMessages': pinnedMessages,
      'settings': settings.toJson(),
      'startedAt': startedAt.toIso8601String(),
      'readReceipts': readReceipts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        participants,
        isGroup,
        groupSettings,
        lastMessage,
        threadInfo,
        isActive,
        pinnedMessages,
        settings,
        startedAt,
        readReceipts,
        createdAt,
        updatedAt,
      ];
}
