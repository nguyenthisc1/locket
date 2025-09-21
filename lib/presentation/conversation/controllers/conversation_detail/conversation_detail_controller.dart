import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:locket/core/entities/last_message_entity.dart';
import 'package:locket/core/mappers/last_message_mapper.dart';
import 'package:locket/core/mappers/pagination_mapper.dart';
import 'package:locket/core/models/last_message_model.dart';
import 'package:locket/core/models/pagination_model.dart';
import 'package:locket/core/services/conversation_detail_cache_service.dart';
import 'package:locket/core/services/message_cache_service.dart';
import 'package:locket/core/services/socket_service.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:locket/domain/conversation/usecases/get_conversation_detail_usecase.dart';
import 'package:locket/domain/conversation/usecases/get_messages_conversation_usecase.dart';
import 'package:locket/domain/conversation/usecases/mark_conversation_as_read_usecase.dart';
import 'package:locket/domain/conversation/usecases/send_message_usecase.dart';
import 'package:locket/presentation/conversation/controllers/conversation/conversation_controller_state.dart';
import 'package:locket/presentation/conversation/controllers/conversation_detail/converstion_detail_controller_state.dart';
import 'package:logger/logger.dart';

class ConversationDetailController {
  final ConversationDetailControllerState _state;
  final MessageCacheService _cacheService;
  final ConversationDetailCacheService _conversationDetailCacheService;
  final GetMessagesConversationUsecase _getMessagesUsecase;
  final SendMessageUsecase _sendMessageUsecase;
  final GetConversationDetailUsecase _getConversationDetailUsecase;
  final MarkConversationAsReadUsecase _markConversationAsReadUsecase;
  final SocketService _socketService;
  final Logger _logger;

  // Socket.IO stream subscriptions
  StreamSubscription<MessageEntity>? _messageSubscription;
  StreamSubscription<ConversationEntity>? _conversationUpdateSubscription;
  StreamSubscription<Map<String, dynamic>>? _typingSubscription;
  StreamSubscription<Map<String, dynamic>>? _readReceiptSubscription;

  // Background gradient functionality
  final List<LinearGradient> _backgroundGradients = [
    const LinearGradient(
      colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF0D47A1)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF4E342E), Color(0xFF004D40)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF3E2723), Color(0xFF1C1C1C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    const LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF000000)],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    ),
    const LinearGradient(
      colors: [Color(0xFF37474F), Color(0xFF212121)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    const LinearGradient(
      colors: [Color(0xFF263238), Color(0xFF1B1B1B)],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ),
  ];

  LinearGradient _currentBackgroundGradient = const LinearGradient(
    colors: [Color(0xFF2C3E50), Color(0xFF1A1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  double _lastScrollPosition = 0;

  ConversationDetailController({
    required ConversationDetailControllerState state,
    required MessageCacheService cacheService,
    required ConversationDetailCacheService conversationDetailCacheService,
    required GetMessagesConversationUsecase getMessagesUsecase,
    required SendMessageUsecase sendMessageUsecase,
    required GetConversationDetailUsecase getConversationDetailUsecase,
    required MarkConversationAsReadUsecase markConversationAsReadUsecase,
    required SocketService socketService,
    Logger? logger,
  }) : _state = state,
       _cacheService = cacheService,
       _conversationDetailCacheService = conversationDetailCacheService,
       _getMessagesUsecase = getMessagesUsecase,
       _sendMessageUsecase = sendMessageUsecase,
       _getConversationDetailUsecase = getConversationDetailUsecase,
       _markConversationAsReadUsecase = markConversationAsReadUsecase,
       _socketService = socketService,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true)) {
    _state.scrollController.addListener(_onScroll);
    _setupSocketListeners();
  }

  // -------------------- Getters --------------------

  LinearGradient get currentBackgroundGradient => _currentBackgroundGradient;

  bool get hasCachedMessages =>
      _cacheService.hasCachedData(_state.conversationId);

  bool get hasCachedConversationDetail =>
      _conversationDetailCacheService.hasCachedData(_state.conversationId);

  Map<String, dynamic> get cacheInfo => {
    'messages': _cacheService.getCacheInfo(_state.conversationId),
    'conversationDetail': _conversationDetailCacheService.getCacheInfo(
      _state.conversationId,
    ),
  };

  // -------------------- Initialization --------------------

  Future<void> init(String conversationId) async {
    _state.setConversationId(conversationId);

    // Only initialize once per conversation
    if (_state.hasInitialized && _state.conversationId == conversationId) {
      return;
    }

    // Reset state for new conversation
    if (_state.conversationId != conversationId) {
      _state.reset();
      _state.setConversationId(conversationId);
    }

    // Load cache message if have
    final cachedMessages = await _cacheService.loadCachedMessages(
      conversationId,
    );
    if (cachedMessages.isNotEmpty) {
      _logger.d(
        '💾 Loaded ${cachedMessages.length} cached messages for $conversationId',
      );
      _state.setListMessages(cachedMessages, isFromCache: true);
    }

    // If have cache detail
    final cachedDetail = await _conversationDetailCacheService
        .loadCachedConversationDetail(conversationId);

    _logger.d('💾 Loaded cached conversation detail for $cachedDetail');
    if (cachedDetail != null) {
      _state.setConversation(cachedDetail);
    }

    // Check socket status before joining
    _socketService.checkConnectionStatus();

    // Join the conversation room for real-time updates
    await _socketService.joinConversation(conversationId);

    // Then fetch fresh message data in background
    await fetchConversationDetail(conversationId);
    await fetchMessages();
    await seenMessage();
    _state.setInitialized(true);
  }

  // -------------------- Message Fetching & Manipulation --------------------

  Future<void> fetchMessages({
    int? limit,
    DateTime? lastCreatedAt,
    bool isRefresh = false,
    bool useCase = true,
  }) async {
    if (isRefresh) {
      _state.setRefreshingMessages(true);
    } else {
      _state.setLoadingMessages(true);
    }
    _state.clearError();

    try {
      if (useCase && !isRefresh && lastCreatedAt == null) {
        final cachedMessages = await _cacheService.loadCachedMessages(
          _state.conversationId,
        );

        if (cachedMessages.isNotEmpty) {
          _logger.d('💾 Loaded ${cachedMessages.length} cached messages');
          _state.setListMessages(cachedMessages, isFromCache: true);
        }
      }

      final result = await _getMessagesUsecase(
        conversationId: _state.conversationId,
        limit: limit,
        lastCreatedAt: lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to fetch messages: ${failure.message}');
          _state.setError(failure.message);

          if (!isRefresh && _state.listMessages.isEmpty) {
            _state.setListMessages([]);
          }
        },
        (response) {
          _logger.d('Fetched messages successfully');
          _state.clearError();

          final messages = response.data['messages'] as List<MessageEntity>;
          final paginationData = response.data['pagination'];

          if (paginationData != null) {
            final paginationModel = PaginationModel.fromJson(paginationData);
            final pagination = PaginationMapper.toEntity(paginationModel);
            _logger.d(
              'Pagination info: hasNextPage=${pagination.hasNextPage}, nextCursor=${pagination.nextCursor}',
            );

            _state.setHasMoreData(pagination.hasNextPage);
            if (pagination.nextCursor != null) {
              _state.setLastCreatedAt(pagination.nextCursor);
            }
          } else {
            if (messages.isNotEmpty) {
              _state.setLastCreatedAt(messages.last.createdAt);
              _state.setHasMoreData(messages.length == limit);
            } else {
              _state.setHasMoreData(false);
            }
          }

          if (lastCreatedAt != null) {
            // Merge new messages with existing ones, avoiding duplicates by message ID
            final existingMessages = {
              for (final m in _state.listMessages) m.id: m,
            };
            for (final m in messages) {
              existingMessages[m.id] = m;
            }
            final mergedMessages =
                existingMessages.values.toList()
                  ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

            _state.setListMessages(mergedMessages);
          } else {
            _state.setListMessages(messages, isFromCache: false);
          }

          // Cache the latest list of messages
          _cacheService.cacheMessages(
            _state.conversationId,
            _state.listMessages,
          );

          return _state.listMessages;
        },
      );
    } catch (e) {
      _logger.e('Error fetching messages: $e');
      _state.setError('An unexpected error occurred');

      if (!isRefresh && _state.listMessages.isEmpty) {
        _state.setListMessages([]);
      }
    } finally {
      _state.setLoadingMessages(false);
      _state.setRefreshingMessages(false);
    }
  }

  Future<void> refreshMessages() async {
    await fetchMessages(isRefresh: true);
  }

  Future<void> loadMoreMessages() async {
    if (_state.isLoadingMore || !_state.hasMoreData) {
      return;
    }

    _state.setLoadingMore(true);
    _state.clearError();

    try {
      final result = await _getMessagesUsecase.call(
        conversationId: _state.conversationId,
        lastCreatedAt: _state.lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load more messages: ${failure.message}');
          _state.setError(failure.message);
        },
        (response) {
          _logger.d('More messages loaded successfully');
          _state.clearError();

          final newMessages = response.data['messages'] as List<MessageEntity>;
          final paginationData = response.data['pagination'];
          _logger.d('New load more messages $newMessages');

          if (paginationData != null) {
            final paginationModel = PaginationModel.fromJson(paginationData);
            final pagination = PaginationMapper.toEntity(paginationModel);
            _logger.d(
              'Load more pagination: hasNextPage=${pagination.hasNextPage}, nextCursor=${pagination.nextCursor}',
            );

            _state.setHasMoreData(pagination.hasNextPage);
            if (pagination.nextCursor != null) {
              _state.setLastCreatedAt(pagination.nextCursor);
            }
          } else {
            if (newMessages.isEmpty) {
              _state.setHasMoreData(false);
            } else if (newMessages.isNotEmpty) {
              _state.setLastCreatedAt(newMessages.last.createdAt);
            }
          }

          if (newMessages.isNotEmpty) {
            final existing = _state.listMessages;
            final existingIds = existing.map((m) => m.id).toSet();
            final merged = [
              ...newMessages.where((m) => !existingIds.contains(m.id)),
              ...existing,
            ];
            _state.setListMessages(merged);
          }

          _cacheService.cacheMessages(
            _state.conversationId,
            _state.listMessages,
          );
        },
      );
    } catch (e) {
      _logger.e('Error loading more messages: $e');
      _state.setError('Failed to load more messages');
    } finally {
      _state.setLoadingMore(false);
    }
  }

  Future<void> addMessage(MessageEntity message) async {
    _state.addMessage(message);
    await _cacheService.addMessageToCache(_state.conversationId, message);
  }

  Future<void> updateMessage(MessageEntity updatedMessage) async {
    _state.updateMessage(updatedMessage);
    await _cacheService.updateMessageInCache(
      _state.conversationId,
      updatedMessage,
    );
  }

  Future<void> removeMessage(String messageId) async {
    _state.removeMessage(messageId);
    await _cacheService.removeMessageFromCache(
      _state.conversationId,
      messageId,
    );
  }

  // -------------------- Conversation Detail --------------------

  Future<void> fetchConversationDetail(String conversationId) async {
    try {
      _logger.d('🔍 Fetching conversation detail for ID: $conversationId');

      final result = await _getConversationDetailUsecase.call(conversationId);

      result.fold(
        (failure) {
          _logger.e(
            '❌ Failed to fetch conversation detail: ${failure.message}',
          );
          _state.setError(
            'Failed to load conversation details: ${failure.message}',
          );
        },
        (response) {
          _logger.d('✅ Conversation detail fetched successfully');

          final conversationDetail = response.data['conversation'];

          if (conversationDetail != null) {
            // Convert ConversationDetailEntity to ConversationEntity for caching
            final conversation = ConversationEntity(
              id: conversationDetail.id,
              name: conversationDetail.name ?? '',
              participants: conversationDetail.participants,
              isGroup: conversationDetail.isGroup,
              groupSettings: conversationDetail.groupSettings,
              isActive: conversationDetail.isActive,
              pinnedMessages: conversationDetail.pinnedMessages,
              settings:
                  conversationDetail.settings ??
                  const ConversationSettingsEntity(
                    muteNotifications: false,
                    theme: 'default',
                  ),
              readReceipts: conversationDetail.readReceipts,
              lastMessage: conversationDetail.lastMessage,
              createdAt: conversationDetail.createdAt,
              updatedAt: conversationDetail.updatedAt,
            );

            _state.setConversation(conversation);
            _state.setParticipant(conversationDetail.participants);
            _logger.d(
              '💾 Conversation detail set in state: ${conversation.name}',
            );

            _conversationDetailCacheService.cacheConversationDetail(
              conversationId,
              conversation,
            );
          }
        },
      );
    } catch (e) {
      _logger.e('❌ Error fetching conversation detail: $e');
      _state.setError(
        'An unexpected error occurred while loading conversation details',
      );
    }
  }

  // -------------------- Caching --------------------

  Future<void> _loadCachedConversationDetail(String conversationId) async {
    try {
      final cachedConversation = await _conversationDetailCacheService
          .loadCachedConversationDetail(conversationId);

      if (cachedConversation != null) {
        _logger.d(
          '📦 Loaded cached conversation detail for ID: $conversationId',
        );
        _state.setConversation(cachedConversation);
      } else {
        _logger.d(
          '📦 No cached conversation detail found for ID: $conversationId',
        );
      }
    } catch (e) {
      _logger.e('❌ Error loading cached conversation detail: $e');
    }
  }

  Future<void> _loadCachedMessages() async {
    try {
      final cachedMessages = await _cacheService.loadCachedMessages(
        _state.conversationId,
      );

      if (cachedMessages.isNotEmpty) {
        _logger.d(
          '📦 Loaded ${cachedMessages.length} cached messages for conversation ${_state.conversationId}',
        );
        _state.setListMessages(cachedMessages, isFromCache: true);
      } else {
        _logger.d(
          '📦 No cached messages found for conversation ${_state.conversationId}',
        );
      }
    } catch (e) {
      _logger.e('❌ Error loading cached messages: $e');
    }
  }

  Future<void> loadCachedMessagesOnly() async {
    await _loadCachedMessages();
  }

  Future<void> clearMessageCache() async {
    await _cacheService.clearCache(_state.conversationId);
    _state.setListMessages([]);
  }

  Future<void> clearConversationDetailCache() async {
    await _conversationDetailCacheService.clearConversationDetailCache(
      _state.conversationId,
    );
    _state.setConversation(null);
  }

  Future<void> clearAllCaches() async {
    await Future.wait([clearMessageCache(), clearConversationDetailCache()]);
  }

  // -------------------- Socket & Real-time --------------------

  void _setupSocketListeners() {
    // Listen for new messages
    _messageSubscription = _socketService.messageStream.listen(
      (messageData) {
        _logger.d('📨 Received real-time message: ${messageData}');

        if (messageData.conversationId == _state.conversationId) {
          final existingMessage =
              _state.listMessages
                  .where((m) => m.id == messageData.id)
                  .isNotEmpty;
          // _logger.d('📨 existingMessage: ${existingMessage}');

          if (existingMessage) {
            // _state.addMessage(messageData);
            // _cacheService.addMessageToCache(_state.conversationId, messageData);
            _logger.d('📨 Update message: ${messageData}');
            // _state.updateMessage(messageData);
            // _cacheService.updateMessageInCache(
            //   _state.conversationId,
            //   messageData,
            // );
          }
        }
      },
      onError: (error) {
        _logger.e('❌ Error in message stream: $error');
      },
    );
    // Listen for conversation updates
    _conversationUpdateSubscription = _socketService.conversationUpdateStream
        .listen(
          (conversationData) {
            _logger.d('💬 Received conversation update: ${conversationData}');

            if (conversationData.id == _state.conversationId) {
              if (conversationData.lastMessage != null) {
                // Update List conversations
                final conversationState = getIt<ConversationControllerState>();

                final updatedListConversation =
                    conversationState.listConversation.map((c) {
                      if (c.id == conversationData.id) {
                        return c.copyWith(
                          lastMessage: conversationData.lastMessage,
                          updatedAt: conversationData.updatedAt,
                        );
                      }
                      return c;
                    }).toList();

                print('updated List conversations: $updatedListConversation');

                conversationState.setListConversations(updatedListConversation);

                // Update detail conversations
                final updatedConversation = _state.conversation!.copyWith(
                  lastMessage: conversationData.lastMessage,
                  updatedAt: conversationData.updatedAt,
                );
                _state.setConversation(updatedConversation);

                _conversationDetailCacheService.cacheConversationDetail(
                  _state.conversationId,
                  updatedConversation,
                );
              }
            }
          },
          onError: (error) {
            _logger.e('❌ Error in conversation update stream: $error');
          },
        );

    // Listen for typing indicators
    _typingSubscription = _socketService.typingStream.listen(
      (typingData) {
        _logger.d('⌨️ Received typing indicator: $typingData');
        final userId = typingData['userId'] as String?;
        final conversationId = typingData['conversationId'] as String?;
        final isTyping = typingData['isTyping'] as bool? ?? false;

        if (userId != null && conversationId == _state.conversationId) {
          if (isTyping) {
            _state.addTypingUser(userId);
          } else {
            _state.removeTypingUser(userId);
          }
        }
      },
      onError: (error) {
        _logger.e('❌ Error in typing stream: $error');
      },
    );

    // Listen for read receipts
    _readReceiptSubscription = _socketService.readReceiptStream.listen(
      (readReceiptData) {
        _logger.d('👁️ Received read receipt: $readReceiptData');

        final lastReadMessageJson = readReceiptData['lastReadMessage'];
        LastMessageEntity? lastReadMessage;
        if (lastReadMessageJson != null) {
          final lastReadMesseModel = LastMessageModel.fromJson(
            lastReadMessageJson,
          );
          lastReadMessage = LastMessageMapper.toEntity(lastReadMesseModel);
        }

        final userId = readReceiptData['userId'] as String;

        DateTime? timestamp;
        final rawTimestamp = readReceiptData['timestamp'];
        if (rawTimestamp is DateTime) {
          timestamp = rawTimestamp;
        } else if (rawTimestamp is String) {
          try {
            timestamp = DateTime.tryParse(rawTimestamp);
          } catch (_) {
            timestamp = null;
          }
        } else if (rawTimestamp is int) {
          timestamp = DateTime.fromMillisecondsSinceEpoch(rawTimestamp);
        }
        timestamp ??= DateTime.now();

        _updateMessageReadStatus(lastReadMessage, userId, timestamp);
      },
      onError: (error) {
        _logger.e('❌ Error in read receipt stream: $error');
      },
    );
  }

  Future<void> sendMessage({
    required String text,
    String? replyTo,
    List<Map<String, dynamic>>? attachments,
  }) async {
    if (text.trim().isEmpty) return;

    _state.setSendingMessage(true);

    try {
      await _socketService.sendMessage(
        conversationId: _state.conversationId,
        text: text,
        replyTo: replyTo,
        attachments: attachments,
      );

      final payload = <String, dynamic>{
        'conversationId': _state.conversationId,
        'text': text,
        'replyTo': replyTo,
        'attachments': attachments,
      };

      final result = await _sendMessageUsecase(payload);
      final userService = getIt<UserService>();

      final now = DateTime.now();
      final tempId = UniqueKey().toString();

      final darftMessage = MessageEntity(
        id: tempId,
        conversationId: _state.conversationId,
        senderId: userService.currentUser!.id,
        senderName:
            userService.currentUser?.username ??
            userService.currentUser?.email ??
            '',
        messageStatus: MessageStatus.sent,
        text: text,
        type: attachments != null && attachments.isNotEmpty ? "media" : "text",
        attachments: attachments ?? [],
        replyTo: replyTo,
        createdAt: now,
        timestamp: now.toIso8601String(),
      );

      _state.addMessage(darftMessage);

      result.fold(
        (failure) {
          _logger.e('Failed to send message: ${failure.message}');

          final failedMessage = darftMessage.copyWith(
            messageStatus: MessageStatus.failed,
          );

          _state.replaceMessage(tempId, failedMessage);
        },
        (response) {
          _logger.d('send message successfully');
          _state.clearError();

          final messageData = response.data['message'] as MessageEntity;
          final newMessage = messageData.copyWith(
            messageStatus: MessageStatus.delivered,
          );

          _state.replaceMessage(tempId, newMessage);
        },
      );

      _logger.d('📤 Message sent via Socket.IO');
    } catch (e) {
      _logger.e('❌ Error sending message: $e');
      _state.setError('Failed to send message');
    } finally {
      _state.setSendingMessage(false);
    }
  }

  Future<void> seenMessage() async {
    try {
      final userService = getIt<UserService>();

      // await _socketService.sendReadReceipt(
      //   conversationId: _state.conversationId,
      //   lastReadMessageId: _state.conversation?.lastMessage?.messageId,
      //   userId: userService.currentUser!.id,
      // );

      // await _markConversationAsReadUsecase(_state.conversationId);
    } catch (e) {
      _logger.e('❌ Error Seen message: $e');
      _state.setError('Failed to Seen message');
    }
  }

  Future<void> sendTypingIndicator() async {
    await _socketService.sendTyping(_state.conversationId);
  }

  Future<void> sendStopTypingIndicator() async {
    await _socketService.sendStopTyping(_state.conversationId);
  }

  Future<void> sendReadReceipt(String messageId) async {
    final userService = getIt<UserService>();

    await _socketService.sendReadReceipt(
      conversationId: _state.conversationId,
      lastReadMessageId: _state.conversation?.lastMessage?.messageId,
      userId: userService.currentUser!.id,
    );
  }

  // -------------------- UI & Scroll --------------------

  void _onScroll() {
    final currentPosition = _state.scrollController.position.pixels;
    final scrollDelta = (currentPosition - _lastScrollPosition).abs();

    if (scrollDelta > 800) {
      _changeBackgroundGradient();
      _lastScrollPosition = currentPosition;
    }
  }

  void _changeBackgroundGradient() {
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(_backgroundGradients.length);
    } while (newIndex == _state.currentGradientIndex &&
        _backgroundGradients.length > 1);

    _currentBackgroundGradient = _backgroundGradients[newIndex];
    _state.setCurrentGradientIndex(newIndex);
  }

  // -------------------- Message Read Status --------------------

  void _updateMessageReadStatus(
    LastMessageEntity? lastReadMessage,
    String userId,
    DateTime timestamp,
  ) async {
    final conversation = _state.conversation;
    final listMessages = _state.listMessages;
    final currentUserId = getIt<UserService>().currentUser?.id;

    if (conversation == null || lastReadMessage == null) return;

    // Update message status to 'read' for the matching message
    final updatedMessages =
        listMessages.map((message) {
          if (message.id == lastReadMessage.messageId &&
              message.senderId == currentUserId) {
            return message.copyWith(messageStatus: MessageStatus.read);
          }
          return message;
        }).toList();

    // Update only the participant matching the userId
    final updatedParticipants =
        conversation.participants.map((participant) {
          if (participant.id == userId) {
            return participant.copyWith(
              lastReadMessageId: lastReadMessage.messageId,
              lastReadAt: timestamp,
            );
          }
          return participant;
        }).toList();

    final updatedConversation = conversation.copyWith(
      participants: updatedParticipants,
    );

    final conversationState = getIt<ConversationControllerState>();

    // Update the conversation in the list with new participants
    final updatedListConversation =
        conversationState.listConversation.map((c) {
          if (c.id == conversation.id) {
            return c.copyWith(
              participants: updatedParticipants,
              lastMessage: conversation.lastMessage,
              updatedAt: conversation.updatedAt,
            );
          }
          return c;
        }).toList();

    conversationState.setListConversations(updatedListConversation);
    _state.setConversation(updatedConversation);
    _state.setListMessages(updatedMessages);

    // Debug logs
    print('Updated conversations list: $updatedListConversation');
    print('Updated participant read status: ${_state.conversation}');
  }

  // -------------------- Cleanup --------------------

  Future<void> _leaveConversation() async {
    if (_state.conversationId.isNotEmpty) {
      await _socketService.leaveConversation(_state.conversationId);
    }
  }

  void dispose() {
    _state.scrollController.removeListener(_onScroll);
    _messageSubscription?.cancel();
    _conversationUpdateSubscription?.cancel();
    _typingSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    _leaveConversation();
  }
}
