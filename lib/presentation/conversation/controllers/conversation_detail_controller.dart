import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';

class ConversationDetailControllerState extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();

  List<MessageEntity> get conversationData =>
      [
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
          replyInfo: ReplyInfoEntity.fromJson(const {
            'messageId': '660f1a2b3c4d5e6f7a8b9c0d',
            'text': 'Hey! How are you doing today?',
            'senderName': 'Yến Vy',
            'attachmentType': null,
          }),
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
          replyInfo: ReplyInfoEntity(
            messageId: '660f1a2b3c4d5e6f7a8b9c13',
            text: 'Check out this beautiful view!',
            senderName: 'Yến Vy',
            attachmentType: 'image',
            attachments: [
              {
                'url':
                    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                'type': 'image',
                'name': 'mountain.jpg',
              },
            ],
          ),
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
          replyInfo: ReplyInfoEntity.fromJson(const {
            'messageId': '660f1a2b3c4d5e6f7a8b9c0e',
            'text': 'I\'m doing great! Just finished my morning workout.',
            'senderName': 'Minh Anh',
            'attachmentType': null,
          }),
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
          replyInfo: ReplyInfoEntity.fromJson(const {
            'messageId': '660f1a2b3c4d5e6f7a8b9c0f',
            'text': 'That sounds awesome! What exercises did you do?',
            'senderName': 'Yến Vy',
            'attachmentType': null,
          }),
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
          replyInfo: ReplyInfoEntity.fromJson(const {
            'messageId': '660f1a2b3c4d5e6f7a8b9c10',
            'text': 'Mostly cardio and some strength training. How about you?',
            'senderName': 'Minh Anh',
            'attachmentType': null,
          }),
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
          replyInfo: ReplyInfoEntity.fromJson(const {
            'messageId': '660f1a2b3c4d5e6f7a8b9c11',
            'text': 'I\'m planning to go for a run later. Want to join?',
            'senderName': 'Yến Vy',
            'attachmentType': null,
          }),
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
      ].reversed.toList();

  // Track which message indices have their timestamp visible
  final Set<int> visibleTimestamps = {};

  final List<LinearGradient> _backgroundGradients = [
    LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4E342E), Color(0xFF004D40)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF3E2723), Color(0xFF1C1C1C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF000000)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF37474F), Color(0xFF212121)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF1B1B1B)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ];

  LinearGradient _currentBackgroundGradient = LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient get currentBackgroundGradient => _currentBackgroundGradient;

  double _lastScrollPosition = 0;

  ConversationDetailControllerState() {
    scrollController.addListener(_onScroll);

    // Always scroll to end on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  /// Handles scroll events and triggers background gradient changes
  /// when the scroll delta exceeds a threshold.
  void _onScroll() {
    final currentPosition = scrollController.position.pixels;
    final scrollDelta = (currentPosition - _lastScrollPosition).abs();

    // Change background gradient when scrolling more than 800 pixels
    if (scrollDelta > 800) {
      _changeBackgroundGradient();
      _lastScrollPosition = currentPosition;
    }
  }

  /// Randomly selects a new background gradient, ensuring it is different
  /// from the current one, and notifies listeners.
  void _changeBackgroundGradient() {
    final random = Random();
    LinearGradient newGradient;
    do {
      newGradient =
          _backgroundGradients[random.nextInt(_backgroundGradients.length)];
    } while (newGradient == _currentBackgroundGradient &&
        _backgroundGradients.length > 1);

    _currentBackgroundGradient = newGradient;
    notifyListeners();
  }

  bool shouldShowTimestamp(int index, List<MessageEntity> data) {
    if (index == 0) return true;
    final prev = data[index - 1];
    final curr = data[index];
    final diff = curr.createdAt.difference(prev.createdAt).inMinutes.abs();
    return diff > 20;
  }

  void toggleTimestampVisibility(int index) {
    if (visibleTimestamps.contains(index)) {
      visibleTimestamps.remove(index);
    } else {
      visibleTimestamps.add(index);
    }
    notifyListeners();
  }
}
