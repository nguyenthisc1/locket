import 'package:equatable/equatable.dart';
import 'package:locket/domain/conversation/entities/conversation_detail_entity.dart';
import 'converstation_model.dart';

class SenderModel extends Equatable {
  final String id;
  final String username;
  final String? avatarUrl;

  const SenderModel({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: (json['_id'] ?? json['id']) as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
    };
  }

  /// Creates a SenderModel from a SenderEntity
  factory SenderModel.fromEntity(SenderEntity entity) {
    return SenderModel(
      id: entity.id,
      username: entity.username,
      avatarUrl: entity.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, username, avatarUrl];
}

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

  /// Parses participants based on group type:
  /// - For groups (isGroup = true): participants should be a List
  /// - For single conversations (isGroup = false): participants should be a Map (single participant)
  static List<ConversationParticipantModel> _parseParticipants(dynamic jsonValue, bool isGroup) {
    if (jsonValue == null) return [];
    
    if (isGroup) {
      // For groups, expect a list of participants
      if (jsonValue is List) {
        return jsonValue
            .map((e) => ConversationParticipantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (jsonValue is Map<String, dynamic>) {
        // Fallback: if single participant provided for group, wrap in list
        return [ConversationParticipantModel.fromJson(jsonValue)];
      }
    } else {
      // For single conversations, expect a single participant as Map
      if (jsonValue is Map<String, dynamic>) {
        return [ConversationParticipantModel.fromJson(jsonValue)];
      } else if (jsonValue is List && jsonValue.isNotEmpty) {
        // Fallback: if list provided for single conversation, take first participant
        return [ConversationParticipantModel.fromJson(jsonValue.first as Map<String, dynamic>)];
      }
    }
    
    return [];
  }

  factory ConversationDetailModel.fromJson(Map<String, dynamic> json) {
    final isGroup = json['isGroup'] as bool? ?? false;
    
    return ConversationDetailModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      participants: _parseParticipants(json['participants'], isGroup),
      isGroup: isGroup,
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
