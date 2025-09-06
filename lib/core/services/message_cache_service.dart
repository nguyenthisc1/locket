import 'dart:convert';

import 'package:locket/core/constants/request_defaults.dart';
import 'package:locket/core/mappers/message_mapper.dart';
import 'package:locket/data/conversation/models/message_model.dart';
import 'package:locket/domain/conversation/entities/message_entity.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageCacheService {
  static const String _messagesCacheKeyPrefix = 'cached_messages_';
  static const String _cacheTimestampKeyPrefix = 'messages_cache_timestamp_';

  // Cache expiration time (30 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 30);
  static const int _currentCacheVersion = 1;

  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  final Map<String, List<MessageEntity>> _cachedMessages = {};
  final Map<String, DateTime> _lastCacheTimes = {};

  /// Get cache key for a specific conversation
  String _getCacheKey(String conversationId) => '$_messagesCacheKeyPrefix$conversationId';
  String _getTimestampKey(String conversationId) => '$_cacheTimestampKeyPrefix$conversationId';

  /// Check if cache is valid for a conversation
  bool isCacheValid(String conversationId) {
    final lastCacheTime = _lastCacheTimes[conversationId];
    return lastCacheTime != null &&
        DateTime.now().difference(lastCacheTime) < _cacheExpiration;
  }

  /// Check if we have cached data for a conversation
  bool hasCachedData(String conversationId) => 
      _cachedMessages[conversationId]?.isNotEmpty ?? false;

  /// Get cached messages for a conversation
  List<MessageEntity> getCachedMessages(String conversationId) => 
      List.unmodifiable(_cachedMessages[conversationId] ?? []);

  /// Cache messages for a specific conversation
  Future<void> cacheMessages(
    String conversationId,
    List<MessageEntity> messages,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final messageModels = MessageMapper.toModelList(messages);
      final cacheData = {
        'version': _currentCacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'messages': messageModels.map((m) => m.toJson()).toList(),
      };

      await prefs.setString(_getCacheKey(conversationId), jsonEncode(cacheData));
      
      // Update in-memory cache
      _cachedMessages[conversationId] = List.from(messages);
      _lastCacheTimes[conversationId] = DateTime.now();

      _logger.d('📦 Cached ${messages.length} messages for conversation $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to cache messages for conversation $conversationId: $e');
    }
  }

  /// Load cached messages for a specific conversation
  Future<List<MessageEntity>> loadCachedMessages(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_getCacheKey(conversationId));

      if (jsonStr == null) {
        _logger.d('📦 No cached messages found for conversation $conversationId');
        return [];
      }

      final cacheData = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Check cache version
      final version = cacheData['version'] as int? ?? 0;
      if (version != _currentCacheVersion) {
        _logger.w('📦 Cache version mismatch for conversation $conversationId, clearing cache');
        await clearCache(conversationId);
        return [];
      }

      // Check cache expiration
      final timestampStr = cacheData['timestamp'] as String?;
      if (timestampStr != null) {
        final cacheTime = DateTime.tryParse(timestampStr);
        if (cacheTime != null) {
          _lastCacheTimes[conversationId] = cacheTime;
          if (!isCacheValid(conversationId)) {
            _logger.d('📦 Cache expired for conversation $conversationId');
            await clearCache(conversationId);
            return [];
          }
        }
      }

      // Parse messages
      final messagesJson = cacheData['messages'] as List<dynamic>?;
      if (messagesJson == null) {
        return [];
      }

      final messageModels = messagesJson
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final messageEntities = MessageMapper.toEntityList(messageModels);
      _cachedMessages[conversationId] = List<MessageEntity>.from(messageEntities);

      _logger.d('📦 Loaded ${messageEntities.length} cached messages for conversation $conversationId');
      return messageEntities;
    } catch (e) {
      _logger.e('❌ Failed to load cached messages for conversation $conversationId: $e');
      await clearCache(conversationId); // Clear corrupted cache
      return [];
    }
  }

  /// Add new message to cache (insert at end for chronological order)
  Future<void> addMessageToCache(String conversationId, MessageEntity message) async {
    try {
      final currentMessages = _cachedMessages[conversationId] ?? [];
      final updatedMessages = [...currentMessages, message];

      // Limit cache size (keep only latest messages per conversation based on configuration)
      if (updatedMessages.length > RequestDefaults.maxCachedMessages) {
        final limitedMessages = updatedMessages.skip(updatedMessages.length - RequestDefaults.maxCachedMessages).toList();
        await cacheMessages(conversationId, limitedMessages);
      } else {
        await cacheMessages(conversationId, updatedMessages);
      }

      _logger.d('📦 Added new message to cache for conversation $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to add message to cache for conversation $conversationId: $e');
    }
  }

  /// Update existing message in cache
  Future<void> updateMessageInCache(String conversationId, MessageEntity updatedMessage) async {
    try {
      final currentMessages = _cachedMessages[conversationId] ?? [];
      final index = currentMessages.indexWhere((m) => m.id == updatedMessage.id);
      
      if (index != -1) {
        final updatedMessages = List<MessageEntity>.from(currentMessages);
        updatedMessages[index] = updatedMessage;
        await cacheMessages(conversationId, updatedMessages);
        _logger.d('📦 Updated message in cache for conversation $conversationId');
      }
    } catch (e) {
      _logger.e('❌ Failed to update message in cache for conversation $conversationId: $e');
    }
  }

  /// Remove message from cache
  Future<void> removeMessageFromCache(String conversationId, String messageId) async {
    try {
      final currentMessages = _cachedMessages[conversationId] ?? [];
      final updatedMessages = currentMessages.where((m) => m.id != messageId).toList();
      await cacheMessages(conversationId, updatedMessages);
      _logger.d('📦 Removed message from cache for conversation $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to remove message from cache for conversation $conversationId: $e');
    }
  }

  /// Clear cached messages for a specific conversation
  Future<void> clearCache(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getCacheKey(conversationId));
      await prefs.remove(_getTimestampKey(conversationId));

      _cachedMessages.remove(conversationId);
      _lastCacheTimes.remove(conversationId);

      _logger.d('📦 Cleared message cache for conversation $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to clear message cache for conversation $conversationId: $e');
    }
  }

  /// Clear all cached messages
  Future<void> clearAllCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_messagesCacheKeyPrefix) || 
            key.startsWith(_cacheTimestampKeyPrefix)) {
          await prefs.remove(key);
        }
      }

      _cachedMessages.clear();
      _lastCacheTimes.clear();

      _logger.d('📦 Cleared all message caches');
    } catch (e) {
      _logger.e('❌ Failed to clear all message caches: $e');
    }
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo(String conversationId) {
    return {
      'conversationId': conversationId,
      'cachedMessageCount': _cachedMessages[conversationId]?.length ?? 0,
      'lastCacheTime': _lastCacheTimes[conversationId]?.toIso8601String(),
      'isCacheValid': isCacheValid(conversationId),
      'hasCachedData': hasCachedData(conversationId),
    };
  }

  /// Get all cache info for debugging
  Map<String, dynamic> getAllCacheInfo() {
    return {
      'totalConversationsInCache': _cachedMessages.length,
      'conversations': _cachedMessages.keys.map((id) => getCacheInfo(id)).toList(),
    };
  }
}
