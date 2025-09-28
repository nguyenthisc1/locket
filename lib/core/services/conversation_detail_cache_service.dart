import 'dart:convert';

import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/mappers/conversation_mapper.dart';
import 'package:locket/data/conversation/models/converstation_model.dart';
import 'package:locket/domain/conversation/entities/conversation_entity.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConversationDetailCacheService {
  static const String _conversationDetailCacheKeyPrefix = 'cached_conversation_detail_';

  // Cache expiration time (60 minutes for conversation details)
  static const Duration _cacheExpiration = Duration(minutes: 60);
  static const int _currentCacheVersion = 1;

  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  // In-memory cache for faster access
  final Map<String, ConversationEntity> _cachedConversationDetails = {};
  final Map<String, DateTime> _lastCacheTime = {};

  /// Cache conversation detail to SharedPreferences
  Future<void> cacheConversationDetail(
    String conversationId,
    ConversationEntity conversation,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert entity to model for JSON serialization
      final conversationModel = ConversationMapper.toModel(conversation);

      // Create cache data with metadata
      final cacheData = {
        'version': _currentCacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'conversationId': conversationId,
        'conversation': conversationModel.toJson(),
      };

      final jsonStr = jsonEncode(cacheData);
      final cacheKey = '$_conversationDetailCacheKeyPrefix$conversationId';
      await prefs.setString(cacheKey, jsonStr);

      // Update in-memory cache
      _cachedConversationDetails[conversationId] = conversation;
      _lastCacheTime[conversationId] = DateTime.now();

      _logger.d('📦 Cached conversation detail for ID: $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to cache conversation detail: $e');
    }
  }

  /// Load conversation detail from SharedPreferences
  Future<ConversationEntity?> loadCachedConversationDetail(String conversationId) async {
    try {
      // Check in-memory cache first
      if (_cachedConversationDetails.containsKey(conversationId)) {
        final cached = _cachedConversationDetails[conversationId];
        final cacheTime = _lastCacheTime[conversationId];
        
        if (cached != null && cacheTime != null && !_isCacheExpired(cacheTime)) {
          _logger.d('📦 Retrieved conversation detail from memory cache: $conversationId');
          return cached;
        }
      }

      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_conversationDetailCacheKeyPrefix$conversationId';
      final jsonStr = prefs.getString(cacheKey);

      if (jsonStr == null) {
        _logger.d('📦 No cached conversation detail found for ID: $conversationId');
        return null;
      }

      final cacheData = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Check cache version
      final version = cacheData['version'] as int? ?? 0;
      if (version != _currentCacheVersion) {
        _logger.w('📦 Cache version mismatch for conversation $conversationId, clearing cache');
        await clearConversationDetailCache(conversationId);
        return null;
      }

      // Check if cache is expired
      final timestampStr = cacheData['timestamp'] as String?;
      if (timestampStr != null) {
        final cacheTime = DateTimeUtils.parseTimestampNullable(timestampStr);
        if (cacheTime != null && _isCacheExpired(cacheTime)) {
          _logger.d('📦 Cache expired for conversation $conversationId, clearing cache');
          await clearConversationDetailCache(conversationId);
          return null;
        }
        _lastCacheTime[conversationId] = cacheTime!;
      }

      // Parse conversation data
      final conversationJson = cacheData['conversation'] as Map<String, dynamic>?;
      if (conversationJson == null) {
        return null;
      }

      final conversationModel = ConversationModel.fromJson(conversationJson);
      final conversationEntity = ConversationMapper.toEntity(conversationModel);

      // Update in-memory cache
      _cachedConversationDetails[conversationId] = conversationEntity;

      _logger.d('📦 Loaded cached conversation detail for ID: $conversationId');
      return conversationEntity;
    } catch (e) {
      _logger.e('❌ Failed to load cached conversation detail: $e');
      await clearConversationDetailCache(conversationId); // Clear corrupted cache
      return null;
    }
  }

  /// Update conversation detail in cache
  Future<void> updateConversationDetailInCache(
    String conversationId,
    ConversationEntity updatedConversation,
  ) async {
    try {
      // Update in-memory cache
      _cachedConversationDetails[conversationId] = updatedConversation;
      
      // Update persistent cache
      await cacheConversationDetail(conversationId, updatedConversation);
      
      _logger.d('📦 Updated conversation detail in cache: $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to update conversation detail in cache: $e');
    }
  }

  /// Clear conversation detail cache for specific conversation
  Future<void> clearConversationDetailCache(String conversationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_conversationDetailCacheKeyPrefix$conversationId';
      await prefs.remove(cacheKey);

      // Clear from in-memory cache
      _cachedConversationDetails.remove(conversationId);
      _lastCacheTime.remove(conversationId);

      _logger.d('📦 Cleared conversation detail cache for ID: $conversationId');
    } catch (e) {
      _logger.e('❌ Failed to clear conversation detail cache: $e');
    }
  }

  /// Clear all conversation detail caches
  Future<void> clearAllConversationDetailCaches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Remove all conversation detail cache keys
      for (final key in keys) {
        if (key.startsWith(_conversationDetailCacheKeyPrefix)) {
          await prefs.remove(key);
        }
      }

      // Clear in-memory caches
      _cachedConversationDetails.clear();
      _lastCacheTime.clear();

      _logger.d('📦 Cleared all conversation detail caches');
    } catch (e) {
      _logger.e('❌ Failed to clear all conversation detail caches: $e');
    }
  }

  /// Check if we have cached data for a conversation
  bool hasCachedData(String conversationId) {
    return _cachedConversationDetails.containsKey(conversationId);
  }

  /// Check if cache is expired
  bool _isCacheExpired(DateTime cacheTime) {
    return DateTime.now().difference(cacheTime) > _cacheExpiration;
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo(String conversationId) {
    return {
      'hasCachedData': hasCachedData(conversationId),
      'lastCacheTime': _lastCacheTime[conversationId]?.toIso8601String(),
      'cacheExpiration': _cacheExpiration.inMinutes,
      'isExpired': _lastCacheTime[conversationId] != null 
          ? _isCacheExpired(_lastCacheTime[conversationId]!)
          : null,
    };
  }

  /// Get all cached conversation IDs
  List<String> getCachedConversationIds() {
    return _cachedConversationDetails.keys.toList();
  }

  /// Get cached conversation count
  int get cachedConversationCount => _cachedConversationDetails.length;

  /// Preload multiple conversations into cache
  Future<void> preloadConversations(List<ConversationEntity> conversations) async {
    try {
      for (final conversation in conversations) {
        await cacheConversationDetail(conversation.id, conversation);
      }
      _logger.d('📦 Preloaded ${conversations.length} conversations into cache');
    } catch (e) {
      _logger.e('❌ Failed to preload conversations: $e');
    }
  }

  /// Clean up expired caches
  Future<void> cleanupExpiredCaches() async {
    try {
      final expiredIds = <String>[];
      
      for (final entry in _lastCacheTime.entries) {
        if (_isCacheExpired(entry.value)) {
          expiredIds.add(entry.key);
        }
      }

      for (final conversationId in expiredIds) {
        await clearConversationDetailCache(conversationId);
      }

      if (expiredIds.isNotEmpty) {
        _logger.d('📦 Cleaned up ${expiredIds.length} expired conversation detail caches');
      }
    } catch (e) {
      _logger.e('❌ Failed to cleanup expired caches: $e');
    }
  }
}
