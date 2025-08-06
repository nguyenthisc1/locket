import 'dart:convert';

import 'package:locket/data/feed/models/feed_model.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/core/mappers/feed_mapper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class FeedCacheService {
  static const String _feedCacheKey = 'cached_feeds';
  static const String _cacheTimestampKey = 'feed_cache_timestamp';
  static const String _cacheVersionKey = 'feed_cache_version';
  
  // Cache expiration time (30 minutes)
  static const Duration _cacheExpiration = Duration(minutes: 30);
  
  // Cache version for handling schema changes
  static const int _currentCacheVersion = 1;
  
  final Logger _logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  List<FeedEntity> _cachedFeeds = [];
  DateTime? _lastCacheTime;

  List<FeedEntity> get cachedFeeds => List.unmodifiable(_cachedFeeds);
  bool get hasCachedData => _cachedFeeds.isNotEmpty;
  bool get isCacheValid => _lastCacheTime != null && 
      DateTime.now().difference(_lastCacheTime!) < _cacheExpiration;

  /// Cache feeds to SharedPreferences
  Future<void> cacheFeeds(List<FeedEntity> feeds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert entities to models for JSON serialization
      final feedModels = feeds.map((entity) => FeedMapper.fromEntity(entity)).toList();
      
      // Create cache data with metadata
      final cacheData = {
        'version': _currentCacheVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'feeds': feedModels.map((model) => model.toJson()).toList(),
      };
      
      final jsonStr = jsonEncode(cacheData);
      await prefs.setString(_feedCacheKey, jsonStr);
      
      // Update in-memory cache
      _cachedFeeds = List.from(feeds);
      _lastCacheTime = DateTime.now();
      
      _logger.d('📦 Cached ${feeds.length} feeds');
    } catch (e) {
      _logger.e('❌ Failed to cache feeds: $e');
    }
  }

  /// Load feeds from SharedPreferences
  Future<List<FeedEntity>> loadCachedFeeds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_feedCacheKey);
      
      if (jsonStr == null) {
        _logger.d('📦 No cached feeds found');
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
      
      // Check cache expiration
      final timestampStr = cacheData['timestamp'] as String?;
      if (timestampStr != null) {
        _lastCacheTime = DateTime.parse(timestampStr);
        if (!isCacheValid) {
          _logger.d('📦 Cache expired, returning empty list');
          return [];
        }
      }
      
      // Parse feeds
      final feedsJson = cacheData['feeds'] as List<dynamic>?;
      if (feedsJson == null) {
        return [];
      }
      
      final feedModels = feedsJson
          .map((json) => FeedModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final feedEntities = feedModels
          .map((model) => FeedMapper.toEntity(model))
          .toList();
      
      // Update in-memory cache
      _cachedFeeds = List.from(feedEntities);
      
      _logger.d('📦 Loaded ${feedEntities.length} cached feeds');
      return feedEntities;
    } catch (e) {
      _logger.e('❌ Failed to load cached feeds: $e');
      await clearCache(); // Clear corrupted cache
      return [];
    }
  }

  /// Add new feed to cache
  Future<void> addFeedToCache(FeedEntity feed) async {
    try {
      // Add to in-memory cache
      _cachedFeeds = [feed, ..._cachedFeeds];
      
      // Limit cache size (keep only latest 100 feeds)
      if (_cachedFeeds.length > 100) {
        _cachedFeeds = _cachedFeeds.take(100).toList();
      }
      
      // Update persistent cache
      await cacheFeeds(_cachedFeeds);
      
      _logger.d('📦 Added new feed to cache');
    } catch (e) {
      _logger.e('❌ Failed to add feed to cache: $e');
    }
  }

  /// Update existing feed in cache
  Future<void> updateFeedInCache(FeedEntity updatedFeed) async {
    try {
      final index = _cachedFeeds.indexWhere((feed) => feed.id == updatedFeed.id);
      if (index != -1) {
        _cachedFeeds[index] = updatedFeed;
        await cacheFeeds(_cachedFeeds);
        _logger.d('📦 Updated feed in cache');
      }
    } catch (e) {
      _logger.e('❌ Failed to update feed in cache: $e');
    }
  }

  /// Remove feed from cache
  Future<void> removeFeedFromCache(String feedId) async {
    try {
      _cachedFeeds.removeWhere((feed) => feed.id == feedId);
      await cacheFeeds(_cachedFeeds);
      _logger.d('📦 Removed feed from cache');
    } catch (e) {
      _logger.e('❌ Failed to remove feed from cache: $e');
    }
  }

  /// Clear all cached feeds
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_feedCacheKey);
      
      _cachedFeeds.clear();
      _lastCacheTime = null;
      
      _logger.d('📦 Cleared feed cache');
    } catch (e) {
      _logger.e('❌ Failed to clear feed cache: $e');
    }
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedData': hasCachedData,
      'isCacheValid': isCacheValid,
      'feedCount': _cachedFeeds.length,
      'lastCacheTime': _lastCacheTime?.toIso8601String(),
      'cacheAge': _lastCacheTime != null 
          ? DateTime.now().difference(_lastCacheTime!).inMinutes 
          : null,
    };
  }
}