import 'dart:convert';

import 'package:locket/core/mappers/conversation_mapper.dart';
import 'package:locket/data/conversation/models/converstation_model.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationCacheService {
  static const String _conversationsCacheKey = 'cached_conversations';
  static const String _cacheTimestampKey = 'conversations_cache_timestamp';
  static const String _cacheVersionKey = 'conversations_cache_version';

  // No expiration: cache is persistent until explicitly cleared or overwritten
  static const int _currentCacheVersion = 1;

  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  List<ConversationEntity> _cachedConversations = [];
  DateTime? _lastCacheTime;

  List<ConversationEntity> get cachedConversations =>
      List.unmodifiable(_cachedConversations);
  bool get hasCachedData => _cachedConversations.isNotEmpty;

  /// Cache conversations to SharedPreferences (no expiration)
  Future<void> cacheConversations(
    List<ConversationEntity> conversations,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert entities to models for JSON serialization
      final conversationModels =
          conversations
              .map((entity) => ConversationMapper.toModel(entity))
              .toList();

      // Create cache data with metadata
      final cacheData = {
        'version': _currentCacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'conversations':
            conversationModels.map((model) => model.toJson()).toList(),
      };

      final jsonStr = jsonEncode(cacheData);
      await prefs.setString(_conversationsCacheKey, jsonStr);

      // Update in-memory cache
      _cachedConversations = List.from(conversations);
      _lastCacheTime = DateTime.now();

      _logger.d('📦 Cached ${conversations.length} conversations');
    } catch (e) {
      _logger.e('❌ Failed to cache conversations: $e');
    }
  }

  /// Load conversations from SharedPreferences (no expiration)
  Future<List<ConversationEntity>> loadCachedConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_conversationsCacheKey);

      if (jsonStr == null) {
        _logger.d('📦 No cached conversations found');
        return [];
      }

      final cacheData = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Check cache version
      final version = cacheData['version'] as int? ?? 0;
      if (version != _currentCacheVersion) {
        _logger.w('📦 Cache version mismatch, clearing cache');
        await clearCache();
        return [];
      }

      // Parse timestamp (for info only)
      final timestampStr = cacheData['timestamp'] as String?;
      if (timestampStr != null) {
        _lastCacheTime = DateTime.tryParse(timestampStr);
      }

      // Parse conversations
      final conversationsJson = cacheData['conversations'] as List<dynamic>?;
      if (conversationsJson == null) {
        return [];
      }

      final conversationModels = conversationsJson
          .map((json) => ConversationModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final conversationEntities = ConversationMapper.toEntityList(conversationModels);
      _cachedConversations = List<ConversationEntity>.from(conversationEntities);

      _logger.d(
        '📦 Loaded ${_cachedConversations.length} cached conversations',
      );
      return _cachedConversations;
    } catch (e) {
      _logger.e('❌ Failed to load cached conversations: $e');
      await clearCache(); // Clear corrupted cache
      return [];
    }
  }

  /// Add new conversation to cache (insert at start)
  Future<void> addConversationToCache(ConversationEntity conversation) async {
    try {
      _cachedConversations = [conversation, ..._cachedConversations];

      // Limit cache size (keep only latest 100 conversations)
      if (_cachedConversations.length > 100) {
        _cachedConversations = _cachedConversations.take(100).toList();
      }

      await cacheConversations(_cachedConversations);

      _logger.d('📦 Added new conversation to cache');
    } catch (e) {
      _logger.e('❌ Failed to add conversation to cache: $e');
    }
  }

  /// Update existing conversation in cache
  Future<void> updateConversationInCache(
    ConversationEntity updatedConversation,
  ) async {
    try {
      final index = _cachedConversations.indexWhere(
        (c) => c.id == updatedConversation.id,
      );
      if (index != -1) {
        _cachedConversations[index] = updatedConversation;
        await cacheConversations(_cachedConversations);
        _logger.d('📦 Updated conversation in cache');
      }
    } catch (e) {
      _logger.e('❌ Failed to update conversation in cache: $e');
    }
  }

  /// Remove conversation from cache
  Future<void> removeConversationFromCache(String conversationId) async {
    try {
      _cachedConversations.removeWhere((c) => c.id == conversationId);
      await cacheConversations(_cachedConversations);
      _logger.d('📦 Removed conversation from cache');
    } catch (e) {
      _logger.e('❌ Failed to remove conversation from cache: $e');
    }
  }

  /// Clear all cached conversations
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_conversationsCacheKey);

      _cachedConversations.clear();
      _lastCacheTime = null;

      _logger.d('📦 Cleared conversation cache');
    } catch (e) {
      _logger.e('❌ Failed to clear conversation cache: $e');
    }
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedData': hasCachedData,
      'conversationCount': _cachedConversations.length,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
    };
  }
}
