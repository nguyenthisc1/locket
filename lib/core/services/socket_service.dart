import 'dart:async';

import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// Socket.IO service for real-time communication
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final Logger _logger = Logger();
  bool _isConnected = false;
  String? _currentUserId;
  String? _authToken;

  // Event streams
  final StreamController<MessageEntity> _messageController = 
      StreamController<MessageEntity>.broadcast();
  final StreamController<ConversationEntity> _conversationUpdateController = 
      StreamController<ConversationEntity>.broadcast();
  final StreamController<String> _connectionStatusController = 
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _typingController = 
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _readReceiptController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  Stream<MessageEntity> get messageStream => _messageController.stream;
  Stream<ConversationEntity> get conversationUpdateStream => _conversationUpdateController.stream;
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream => _readReceiptController.stream;

  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Initialize socket connection
  Future<void> initialize({
    required String serverUrl,
    required String userId,
    required String authToken,
  }) async {
    try {
      _currentUserId = userId;
      _authToken = authToken;

      _logger.d('🔌 Initializing Socket.IO connection to: $serverUrl');

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': authToken, 'userId': userId})
            .enableAutoConnect()
            .build(),
      );

      _setupEventListeners();
      _logger.d('✅ Socket.IO initialized successfully');
    } catch (e) {
      _logger.e('❌ Failed to initialize Socket.IO: $e');
      rethrow;
    }
  }

  /// Setup all event listeners
  void _setupEventListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      _isConnected = true;
      _logger.d('🔗 Socket connected');
      _connectionStatusController.add('connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _logger.d('🔌 Socket disconnected');
      _connectionStatusController.add('disconnected');
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      _logger.e('❌ Socket connection error: $error');
      _connectionStatusController.add('error');
    });

    // Message events
    _socket!.on('new_message', (data) {
      try {
        _logger.d('📨 Received new message: $data');
        final message = _parseMessage(data);
        if (message != null) {
          _messageController.add(message);
        }
      } catch (e) {
        _logger.e('❌ Error parsing new message: $e');
      }
    });

    _socket!.on('message_updated', (data) {
      try {
        _logger.d('✏️ Message updated: $data');
        final message = _parseMessage(data);
        if (message != null) {
          _messageController.add(message);
        }
      } catch (e) {
        _logger.e('❌ Error parsing message update: $e');
      }
    });

    _socket!.on('message_deleted', (data) {
      try {
        _logger.d('🗑️ Message deleted: $data');
        // Handle message deletion
        _messageController.add(MessageEntity.empty());
      } catch (e) {
        _logger.e('❌ Error parsing message deletion: $e');
      }
    });

    // Conversation events
    _socket!.on('conversation_updated', (data) {
      try {
        _logger.d('💬 Conversation updated: $data');
        final conversation = _parseConversation(data);
        if (conversation != null) {
          _conversationUpdateController.add(conversation);
        }
      } catch (e) {
        _logger.e('❌ Error parsing conversation update: $e');
      }
    });

    // Typing events
    _socket!.on('user_typing', (data) {
      try {
        _logger.d('⌨️ User typing: $data');
        _typingController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _logger.e('❌ Error parsing typing event: $e');
      }
    });

    _socket!.on('user_stopped_typing', (data) {
      try {
        _logger.d('⌨️ User stopped typing: $data');
        _typingController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _logger.e('❌ Error parsing stop typing event: $e');
      }
    });

    // Read receipt events
    _socket!.on('message_read', (data) {
      try {
        _logger.d('👁️ Message read: $data');
        _readReceiptController.add(Map<String, dynamic>.from(data));
      } catch (e) {
        _logger.e('❌ Error parsing read receipt: $e');
      }
    });

    // Error handling
    _socket!.onError((error) {
      _logger.e('❌ Socket error: $error');
      _connectionStatusController.add('error');
    });
  }

  /// Join a conversation room
  Future<void> joinConversation(String conversationId) async {
    if (_socket == null || !_isConnected) {
      _logger.w('⚠️ Socket not connected, cannot join conversation');
      return;
    }

    try {
      _logger.d('🚪 Joining conversation: $conversationId');
      _socket!.emit('join_conversation', {
        'conversationId': conversationId,
        'userId': _currentUserId,
      });
    } catch (e) {
      _logger.e('❌ Error joining conversation: $e');
    }
  }

  /// Leave a conversation room
  Future<void> leaveConversation(String conversationId) async {
    if (_socket == null || !_isConnected) {
      _logger.w('⚠️ Socket not connected, cannot leave conversation');
      return;
    }

    try {
      _logger.d('🚪 Leaving conversation: $conversationId');
      _socket!.emit('leave_conversation', {
        'conversationId': conversationId,
        'userId': _currentUserId,
      });
    } catch (e) {
      _logger.e('❌ Error leaving conversation: $e');
    }
  }

  /// Send a message
  Future<void> sendMessage({
    required String conversationId,
    required String text,
    String? replyTo,
    List<Map<String, dynamic>>? attachments,
  }) async {
    if (_socket == null || !_isConnected) {
      _logger.w('⚠️ Socket not connected, cannot send message');
      return;
    }

    try {
      final messageData = {
        'conversationId': conversationId,
        'text': text,
        'senderId': _currentUserId,
        'type': 'text',
        'replyTo': replyTo,
        'attachments': attachments ?? [],
        'timestamp': DateTime.now().toIso8601String(),
      };

      _logger.d('📤 Sending message: $messageData');
      _socket!.emit('send_message', messageData);
    } catch (e) {
      _logger.e('❌ Error sending message: $e');
    }
  }

  /// Send typing indicator
  Future<void> sendTyping(String conversationId) async {
    if (_socket == null || !_isConnected) return;

    try {
      _socket!.emit('typing', {
        'conversationId': conversationId,
        'userId': _currentUserId,
      });
    } catch (e) {
      _logger.e('❌ Error sending typing indicator: $e');
    }
  }

  /// Send stop typing indicator
  Future<void> sendStopTyping(String conversationId) async {
    if (_socket == null || !_isConnected) return;

    try {
      _socket!.emit('stop_typing', {
        'conversationId': conversationId,
        'userId': _currentUserId,
      });
    } catch (e) {
      _logger.e('❌ Error sending stop typing indicator: $e');
    }
  }

  /// Send read receipt
  Future<void> sendReadReceipt(String conversationId, String messageId) async {
    if (_socket == null || !_isConnected) return;

    try {
      _socket!.emit('mark_message_read', {
        'conversationId': conversationId,
        'messageId': messageId,
        'userId': _currentUserId,
      });
    } catch (e) {
      _logger.e('❌ Error sending read receipt: $e');
    }
  }

  /// Parse message from socket data
  MessageEntity? _parseMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return MessageEntity(
          id: data['id'] ?? '',
          conversationId: data['conversationId'] ?? '',
          senderId: data['senderId'] ?? '',
          senderName: data['senderName'] ?? '',
          text: data['text'] ?? '',
          type: data['type'] ?? 'text',
          attachments: List<Map<String, dynamic>>.from(data['attachments'] ?? []),
          replyTo: data['replyTo'],
          replyInfo: data['replyInfo'] != null 
              ? ReplyInfoEntity.fromJson(data['replyInfo']) 
              : null,
          forwardedFrom: data['forwardedFrom'],
          forwardInfo: data['forwardInfo'],
          threadInfo: data['threadInfo'],
          reactions: List<Map<String, dynamic>>.from(data['reactions'] ?? []),
          isRead: data['isRead'] ?? false,
          isEdited: data['isEdited'] ?? false,
          isDeleted: data['isDeleted'] ?? false,
          isPinned: data['isPinned'] ?? false,
          editHistory: List<Map<String, dynamic>>.from(data['editHistory'] ?? []),
          metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
          sticker: data['sticker'],
          emote: data['emote'],
          createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
          timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
          isMe: data['senderId'] == _currentUserId,
        );
      }
      return null;
    } catch (e) {
      _logger.e('❌ Error parsing message: $e');
      return null;
    }
  }

  /// Parse conversation from socket data
  ConversationEntity? _parseConversation(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        // This would need to be implemented based on your ConversationEntity structure
        // For now, returning null as we need to see the full structure
        _logger.d('📝 Conversation parsing not fully implemented yet');
        return null;
      }
      return null;
    } catch (e) {
      _logger.e('❌ Error parsing conversation: $e');
      return null;
    }
  }

  /// Reconnect socket
  Future<void> reconnect() async {
    if (_socket != null) {
      _logger.d('🔄 Reconnecting socket...');
      _socket!.disconnect();
      _socket!.connect();
    }
  }

  /// Disconnect socket
  Future<void> disconnect() async {
    if (_socket != null) {
      _logger.d('🔌 Disconnecting socket...');
      _socket!.disconnect();
      _isConnected = false;
    }
  }

  /// Dispose resources
  void dispose() {
    _socket?.disconnect();
    _socket = null;
    _messageController.close();
    _conversationUpdateController.close();
    _connectionStatusController.close();
    _typingController.close();
    _readReceiptController.close();
  }
}
