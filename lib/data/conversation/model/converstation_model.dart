import 'package:locket/domain/conversation/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.name,
    required super.isGroup,
    required super.participants,
    super.admin,
    super.lastMessage,
    required super.timestamp,
    required super.imageUrl,
    required super.isActive,
    required super.pinnedMessages,
    required super.settings,
    required super.startedAt,
    required super.readReceipts,
  });

  factory ConversationModel.fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isGroup: map['isGroup'] as bool,
      participants: List<String>.from(map['participants'] ?? []),
      admin: map['admin'] as String?,
      lastMessage:
          map['lastMessage'] != null
              ? LastMessageModel.fromMap(map['lastMessage'])
              : null,
      timestamp: map['timestamp'] as String,
      imageUrl: map['imageUrl'] as String,
      isActive: map['isActive'] as bool,
      pinnedMessages: List<dynamic>.from(map['pinnedMessages'] ?? []),
      settings: ConversationSettingsModel.fromMap(map['settings'] ?? {}),
      startedAt:
          map['startedAt'] is DateTime
              ? map['startedAt']
              : DateTime.tryParse(map['startedAt'].toString()) ??
                  DateTime.now(),
      readReceipts: List<dynamic>.from(map['readReceipts'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isGroup': isGroup,
      'participants': participants,
      'admin': admin,
      'lastMessage':
          lastMessage is LastMessageModel
              ? (lastMessage as LastMessageModel).toMap()
              : (lastMessage != null
                  ? {
                    'messageId': lastMessage!.messageId,
                    'text': lastMessage!.text,
                    'senderId': lastMessage!.senderId,
                    'timestamp': lastMessage!.timestamp.toIso8601String(),
                  }
                  : null),
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'pinnedMessages': pinnedMessages,
      'settings':
          settings is ConversationSettingsModel
              ? (settings as ConversationSettingsModel).toMap()
              : {
                'muteNotifications': settings.muteNotifications,
                'customEmoji': settings.customEmoji,
                'theme': settings.theme,
                'wallpaper': settings.wallpaper,
              },
      'startedAt': startedAt.toIso8601String(),
      'readReceipts': readReceipts,
    };
  }
}

class LastMessageModel extends LastMessageEntity {
  const LastMessageModel({
    required super.messageId,
    required super.text,
    required super.senderId,
    required super.timestamp,
  });

  factory LastMessageModel.fromMap(Map<String, dynamic> map) {
    return LastMessageModel(
      messageId: map['messageId'] as String,
      text: map['text'] as String,
      senderId: map['senderId'] as String,
      timestamp:
          map['timestamp'] is DateTime
              ? map['timestamp']
              : DateTime.tryParse(map['timestamp'].toString()) ??
                  DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'text': text,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ConversationSettingsModel extends ConversationSettingsEntity {
  const ConversationSettingsModel({
    required super.muteNotifications,
    super.customEmoji,
    required super.theme,
    super.wallpaper,
  });

  factory ConversationSettingsModel.fromMap(Map<String, dynamic> map) {
    return ConversationSettingsModel(
      muteNotifications: map['muteNotifications'] as bool? ?? false,
      customEmoji: map['customEmoji'] as String?,
      theme: map['theme'] as String? ?? 'default',
      wallpaper: map['wallpaper'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'muteNotifications': muteNotifications,
      'customEmoji': customEmoji,
      'theme': theme,
      'wallpaper': wallpaper,
    };
  }
}
