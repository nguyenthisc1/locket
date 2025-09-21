import 'dart:async';

import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/core/mappers/message_mapper.dart';
import 'package:locket/data/conversation/models/message_model.dart';
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
  Stream<ConversationEntity> get conversationUpdateStream =>
      _conversationUpdateController.stream;
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;
  Stream<Map<String, dynamic>> get typingStream => _typingController.stream;
  Stream<Map<String, dynamic>> get readReceiptStream =>
      _readReceiptController.stream;

  bool get isConnected => _isConnected;
  bool get socketConnected => _socket?.connected ?? false;
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
      _logger.d('🔗 Socket connected ${_socket?.id} ${_socket?.auth}');
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

    _socket!.onAny((event, data) {
      _logger.d('📡 Event: $event - $data');

      // Enhanced debugging for read receipt events
      if (event.toString().toLowerCase().contains('read') ||
          event.toString().toLowerCase().contains('receipt')) {
        _logger.d('🔍 POTENTIAL READ RECEIPT EVENT: $event with data: $data');
      }
    });

    // Message events
    _socket!.on('message:send', (data) {
      try {
        _logger.d('📨 message send: $data');
        final message = _parseMessage(data);
        if (message != null) {
          _messageController.add(message);
        }
      } catch (e) {
        _logger.e('❌ Error parsing new message: $e');
      }
    });

    _socket!.on('message:updated', (data) {
      try {
        _logger.d('✏️ Message updated: ${data['data']['message']}');

        final message = _parseMessage(data);
        _logger.d('✏️ Message updated: $message');
        if (message != null) {
          _messageController.add(message);
        }
      } catch (e) {
        _logger.e('❌ Error parsing message update: $e');
      }
    });

    _socket!.on('message:deleted', (data) {
      try {
        _logger.d('🗑️ Message deleted: $data');
        // Handle message deletion
        _messageController.add(MessageEntity.empty());
      } catch (e) {
        _logger.e('❌ Error parsing message deletion: $e');
      }
    });

    // Conversation events
    _socket!.on('conversation:updated', (data) {
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
    _socket!.on('message:read', (data) {
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

  Future<void> connect() async {
    if (_socket != null && !_isConnected) {
      try {
        _logger.d('🔌 Manually connecting socket...');
        _socket!.connect();
      } catch (e) {
        _logger.e('❌ Error manually connecting socket: $e');
        rethrow;
      }
    } else if (_socket == null) {
      _logger.w('⚠️ Socket not initialized, cannot connect');
    } else {
      _logger.d('🔗 Socket already connected');
    }
  }

  /// Join a conversation room
  Future<void> joinConversation(String conversationId) async {
    _logger.d('check Socket ${_socket} ${_isConnected}');
    if (_socket == null || !_isConnected) {
      _logger.w('⚠️ Socket not connected, cannot join conversation');
      return;
    }

    try {
      _logger.d('🚪 Joining conversation: $conversationId');
      _socket!.emit('conversation:join', {'conversationId': conversationId});
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
      _socket!.emit('conversation:leave', {'conversationId': conversationId});
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
  Future<void> sendReadReceipt({
    required String conversationId,
    String? lastReadMessageId,
    required String userId,
  }) async {
    if (_socket == null || !_isConnected) return;

    try {
      final data = {
        'conversationId': conversationId,
        'lastReadMessageId': lastReadMessageId,
        'userId': userId,
      };

      _socket!.emit('message:read', data);
    } catch (e) {
      _logger.e('❌ Error sending read receipt: $e');
    }
  }

  /// Parse message from socket data
  MessageEntity? _parseMessage(dynamic data) {
    _logger.d('✏️ _parseMessage: $data');

    try {
      if (data is Map<String, dynamic>) {
        final messageJson = data['data']['message'];
        final messageModel = MessageModel.fromJson(messageJson);
        print('_parseMessage ${MessageMapper.toEntity(messageModel)}');
        return MessageMapper.toEntity(messageModel);
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
        // Extract conversation data from socket payload
        final conversationId = data['conversationId'] as String;
        final updateData = data['updateData'] as Map<String, dynamic>?;

        if (updateData == null) {
          _logger.w('⚠️ No updateData found in conversation update');
          return null;
        }

        // Parse last message from updateData
        LastMessageEntity? lastMessage;
        if (updateData['lastMessage'] != null) {
          final lastMessageData =
              updateData['lastMessage'] as Map<String, dynamic>;
          lastMessage = LastMessageEntity.fromJson(lastMessageData);
        }

        // Parse updatedAt
        DateTime? updatedAt;
        if (updateData['updatedAt'] != null) {
          updatedAt = DateTime.parse(updateData['updatedAt'] as String);
        }

        // Create a minimal ConversationEntity for the update
        // Note: This is just for the update - we don't have all conversation data
        return ConversationEntity(
          id: conversationId,
          name: '', // We don't have name in the socket update
          participants:
              const [], // We don't have participants in the socket update
          isGroup: false, // We don't have group info in the socket update
          isActive: true, // Assume active for socket updates
          pinnedMessages: const [],
          settings: const ConversationSettingsEntity(
            muteNotifications: false,
            theme: '',
          ),
          readReceipts: const [],
          createdAt:
              DateTime.now(), // We don't have createdAt in the socket update
          lastMessage: lastMessage,
          updatedAt: updatedAt,
        );
      }
      return null;
    } catch (e) {
      _logger.e('❌ Error parsing conversation: $e');
      _logger.e('❌ Data: $data');
      return null;
    }
  }

  /// Check socket connection status with detailed logging
  void checkConnectionStatus() {
    _logger.d('🔍 Socket status check:');
    _logger.d('  - Socket instance: ${_socket != null ? 'exists' : 'null'}');
    _logger.d('  - Is connected: $_isConnected');
    _logger.d('  - Socket connected: ${_socket?.connected ?? false}');
    _logger.d('  - Current user ID: $_currentUserId');
    _logger.d('  - Auth token: ${_authToken != null ? 'exists' : 'null'}');
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
