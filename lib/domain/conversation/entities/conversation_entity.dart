import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String name;
  final bool isGroup;
  final List<String> participants;
  final String? admin;
  final LastMessageEntity? lastMessage;
  final String timestamp;
  final String imageUrl;
  final bool isActive;
  final List<dynamic> pinnedMessages;
  final ConversationSettingsEntity settings;
  final DateTime startedAt;
  final List<dynamic> readReceipts;

  const ConversationEntity({
    required this.id,
    required this.name,
    required this.isGroup,
    required this.participants,
    this.admin,
    this.lastMessage,
    required this.timestamp,
    required this.imageUrl,
    required this.isActive,
    required this.pinnedMessages,
    required this.settings,
    required this.startedAt,
    required this.readReceipts,
  });

  ConversationEntity copyWith({
    String? id,
    String? name,
    bool? isGroup,
    List<String>? participants,
    String? admin,
    LastMessageEntity? lastMessage,
    String? timestamp,
    String? imageUrl,
    bool? isActive,
    List<dynamic>? pinnedMessages,
    ConversationSettingsEntity? settings,
    DateTime? startedAt,
    List<dynamic>? readReceipts,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isGroup: isGroup ?? this.isGroup,
      participants: participants ?? List<String>.from(this.participants),
      admin: admin ?? this.admin,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      pinnedMessages: pinnedMessages ?? List<dynamic>.from(this.pinnedMessages),
      settings: settings ?? this.settings,
      startedAt: startedAt ?? this.startedAt,
      readReceipts: readReceipts ?? List<dynamic>.from(this.readReceipts),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    isGroup,
    participants,
    admin,
    lastMessage,
    timestamp,
    imageUrl,
    isActive,
    pinnedMessages,
    settings,
    startedAt,
    readReceipts,
  ];
}

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

  LastMessageEntity copyWith({
    String? messageId,
    String? text,
    String? senderId,
    DateTime? timestamp,
  }) {
    return LastMessageEntity(
      messageId: messageId ?? this.messageId,
      text: text ?? this.text,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [messageId, text, senderId, timestamp];
}

class ConversationSettingsEntity extends Equatable {
  final bool muteNotifications;
  final String? customEmoji;
  final String theme;
  final String? wallpaper;

  const ConversationSettingsEntity({
    required this.muteNotifications,
    this.customEmoji,
    required this.theme,
    this.wallpaper,
  });

  ConversationSettingsEntity copyWith({
    bool? muteNotifications,
    String? customEmoji,
    String? theme,
    String? wallpaper,
  }) {
    return ConversationSettingsEntity(
      muteNotifications: muteNotifications ?? this.muteNotifications,
      customEmoji: customEmoji ?? this.customEmoji,
      theme: theme ?? this.theme,
      wallpaper: wallpaper ?? this.wallpaper,
    );
  }

  @override
  List<Object?> get props => [muteNotifications, customEmoji, theme, wallpaper];
}
