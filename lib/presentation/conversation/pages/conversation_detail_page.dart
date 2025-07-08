import 'package:flutter/material.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/common/wigets/message_field.dart';
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail_controller.dart';
import 'package:locket/presentation/conversation/widgets/message.dart';

import '../../../core/configs/theme/index.dart';

class ConversationDetailPage extends StatefulWidget {
  const ConversationDetailPage({super.key});

  @override
  State<ConversationDetailPage> createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  late final ConversationDetailControllerState _controller;

  // Example conversation data modeled after the provided Mongoose message schema
  List<MessageEntity> get _conversationData => [
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0d',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c01',
      senderName: 'Yến Vy',
      text: 'Hey! How are you doing today?',
      type: 'text',
      attachments: const [],
      replyTo: null,
      replyInfo: null,
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: [
        {
          'userId': '660f1a2b3c4d5e6f7a8b9c02',
          'type': '❤️',
          'createdAt': DateTime(2023, 5, 6, 10, 31),
        },
      ],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-1',
        'deviceId': 'ios-001',
        'platform': 'ios',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 30),
      timestamp: '10:30 AM',
      isMe: false,
    ),
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0e',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c02',
      senderName: 'Minh Anh',
      text: 'I\'m doing great! Just finished my morning workout.',
      type: 'text',
      attachments: const [],
      replyTo: '660f1a2b3c4d5e6f7a8b9c0d',
      replyInfo: const {
        'messageId': '660f1a2b3c4d5e6f7a8b9c0d',
        'text': 'Hey! How are you doing today?',
        'senderName': 'Yến Vy',
        'attachmentType': null,
      },
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: [
        {
          'userId': '660f1a2b3c4d5e6f7a8b9c01',
          'type': '😂',
          'createdAt': DateTime(2023, 5, 6, 10, 33),
        },
      ],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-2',
        'deviceId': 'android-001',
        'platform': 'android',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 32),
      timestamp: '10:32 AM',
      isMe: true,
    ),
    // Message with Unsplash image attachment
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c13',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c01',
      senderName: 'Yến Vy',
      text: 'Check out this beautiful view!',
      type: 'image',
      attachments: const [
        {
          'url':
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
          'type': 'image',
          'name': 'mountain.jpg',
        },
      ],
      replyTo: null,
      replyInfo: null,
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: [
        {
          'userId': '660f1a2b3c4d5e6f7a8b9c02',
          'type': '😍',
          'createdAt': DateTime(2023, 5, 6, 10, 40),
        },
      ],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-7',
        'deviceId': 'ios-001',
        'platform': 'ios',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 40),
      timestamp: '10:40 AM',
      isMe: false,
    ),
    // Another message with Unsplash image
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c14',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c02',
      senderName: 'Minh Anh',
      text: 'Wow! Here is one from my last trip.',
      type: 'image',
      attachments: const [
        {
          'url':
              'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
          'type': 'image',
          'name': 'lake.jpg',
        },
      ],
      replyTo: '660f1a2b3c4d5e6f7a8b9c13',
      replyInfo: const {
        'messageId': '660f1a2b3c4d5e6f7a8b9c13',
        'text': 'Check out this beautiful view!',
        'senderName': 'Yến Vy',
        'attachmentType': 'image',
      },
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: [
        {
          'userId': '660f1a2b3c4d5e6f7a8b9c01',
          'type': '👍',
          'createdAt': DateTime(2023, 5, 6, 10, 42),
        },
      ],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-8',
        'deviceId': 'android-001',
        'platform': 'android',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 42),
      timestamp: '10:42 AM',
      isMe: true,
    ),
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c0f',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c01',
      senderName: 'Yến Vy',
      text: 'That sounds awesome! What exercises did you do?',
      type: 'text',
      attachments: const [],
      replyTo: '660f1a2b3c4d5e6f7a8b9c0e',
      replyInfo: const {
        'messageId': '660f1a2b3c4d5e6f7a8b9c0e',
        'text': 'I\'m doing great! Just finished my morning workout.',
        'senderName': 'Minh Anh',
        'attachmentType': null,
      },
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: const [],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-3',
        'deviceId': 'ios-001',
        'platform': 'ios',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 33),
      timestamp: '10:33 AM',
      isMe: false,
    ),
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c10',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c02',
      senderName: 'Minh Anh',
      text: 'Mostly cardio and some strength training. How about you?',
      type: 'text',
      attachments: const [],
      replyTo: '660f1a2b3c4d5e6f7a8b9c0f',
      replyInfo: const {
        'messageId': '660f1a2b3c4d5e6f7a8b9c0f',
        'text': 'That sounds awesome! What exercises did you do?',
        'senderName': 'Yến Vy',
        'attachmentType': null,
      },
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: const [],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-4',
        'deviceId': 'android-001',
        'platform': 'android',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 35),
      timestamp: '10:35 AM',
      isMe: true,
    ),
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c11',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c01',
      senderName: 'Yến Vy',
      text: 'I\'m planning to go for a run later. Want to join?',
      type: 'text',
      attachments: const [],
      replyTo: '660f1a2b3c4d5e6f7a8b9c10',
      replyInfo: const {
        'messageId': '660f1a2b3c4d5e6f7a8b9c10',
        'text': 'Mostly cardio and some strength training. How about you?',
        'senderName': 'Minh Anh',
        'attachmentType': null,
      },
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: const [],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-5',
        'deviceId': 'ios-001',
        'platform': 'ios',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 36),
      timestamp: '10:36 AM',
      isMe: false,
    ),
    MessageEntity(
      id: '660f1a2b3c4d5e6f7a8b9c12',
      conversationId: '660f1a2b3c4d5e6f7a8b9c0a',
      senderId: '660f1a2b3c4d5e6f7a8b9c02',
      senderName: 'Minh Anh',
      text: 'Sure! That would be fun. What time works for you?',
      type: 'text',
      attachments: const [],
      replyTo: '660f1a2b3c4d5e6f7a8b9c11',
      replyInfo: const {
        'messageId': '660f1a2b3c4d5e6f7a8b9c11',
        'text': 'I\'m planning to go for a run later. Want to join?',
        'senderName': 'Yến Vy',
        'attachmentType': null,
      },
      forwardedFrom: null,
      forwardInfo: null,
      threadInfo: null,
      reactions: const [],
      isRead: true,
      isEdited: false,
      isDeleted: false,
      isPinned: false,
      editHistory: const [],
      metadata: const {
        'clientMessageId': 'client-6',
        'deviceId': 'android-001',
        'platform': 'android',
      },
      sticker: null,
      emote: null,
      createdAt: DateTime(2023, 5, 6, 10, 38),
      timestamp: '10:38 AM',
      isMe: true,
    ),
    // ... (Add more messages as needed, following the above structure)
  ];

  @override
  void initState() {
    super.initState();
    _controller = ConversationDetailControllerState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: BasicAppbar(
            backgroundColor: Colors.transparent,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
                  size: AppDimensions.avatarMd,
                ),
                const SizedBox(width: AppDimensions.md),
                Text(
                  'Name 1123',
                  style: AppTypography.headlineLarge.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            action: Icon(Icons.more_horiz, size: AppDimensions.iconLg),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: _controller.currentBackgroundGradient,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: _controller.currentBackgroundGradient,
              ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _controller.scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.md,
                        right: AppDimensions.md,
                        top: AppDimensions.lg,
                        bottom: AppDimensions.xxl * 2,
                      ),
                      child: Column(
                        children:
                            _conversationData.map((messageData) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.lg,
                                ),
                                child: Message(data: messageData),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.md,
                        right: AppDimensions.md,
                        top: AppDimensions.lg,
                        bottom: AppDimensions.lg,
                      ),
                      child: MessageField(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
