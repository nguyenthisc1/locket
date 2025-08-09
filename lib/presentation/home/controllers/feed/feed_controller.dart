// lib/presentation/home/controllers/feed_controller.dart

import 'package:flutter/material.dart';
import 'package:locket/core/services/feed_cache_service.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/domain/feed/usecases/get_feed_usecase.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:logger/logger.dart';

/// Business logic controller - handles all operations and business rules
class FeedController {
  final FeedControllerState _state;
  final FeedCacheService _cacheService;
  final GetFeedUsecase _getFeedUsecase;
  final Logger _logger;
  final FocusNode _messageFieldFocusNode;

  FeedController({
    required FeedControllerState state,
    required FeedCacheService cacheService,
    required GetFeedUsecase getFeedUsecase,
    Logger? logger,
  })  : _state = state,
        _cacheService = cacheService,
        _getFeedUsecase = getFeedUsecase,
        _logger = logger ?? Logger(printer: PrettyPrinter(colors: true, printEmojis: true)),
        _messageFieldFocusNode = FocusNode() {
    _messageFieldFocusNode.addListener(_handleKeyboardFocus);
  }

  // Getters for external access
  FeedControllerState get state => _state;
  FocusNode get messageFieldFocusNode => _messageFieldFocusNode;

  /// Initialize the controller with cached and fresh data
  Future<void> init() async {
    // Only initialize once
    if (_state.hasInitialized) {
      return;
    }

    // Load cached data first (instant UI update)
    await _loadCachedFeeds();

    // Then fetch fresh data
    await fetchFeed({});
    _state.setInitialized(true);
  }

  /// Load cached feeds (fast, offline-first)
  Future<void> _loadCachedFeeds() async {
    try {
      final cachedFeeds = await _cacheService.loadCachedFeeds();
      if (cachedFeeds.isNotEmpty) {
        _state.setFeeds(cachedFeeds);
        _logger.d('📦 Loaded ${cachedFeeds.length} feeds from cache');
      }
    } catch (e) {
      _logger.e('❌ Failed to load cached feeds: $e');
    }
  }

  /// Fetch feeds from API with caching
  Future<void> fetchFeed(Map<String, dynamic> query, {bool isRefresh = false}) async {
    if (isRefresh) {
      _state.setRefreshing(true);
    } else {
      _state.setLoading(true);
    }
    _state.clearError();

    try {
      final result = await _getFeedUsecase.call(query);

      result.fold(
        (failure) {
          _logger.e('Failed to fetch Feed: ${failure.message}');
          _state.setError(failure.message);

          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if (!isRefresh && _state.listFeed.isEmpty) {
            _state.setFeeds([]);
          }
          // If it's a refresh, keep the existing cached data
        },
        (response) {
          _logger.d('Feed fetched successfully');
          _state.clearError();

          final feeds = response.data['feeds'] as List<FeedEntity>;
          _state.setFeeds(feeds);

          // Cache the new data
          _cacheService.cacheFeeds(feeds);
        },
      );
    } catch (e) {
      _logger.e('Error fetching feed: $e');
      _state.setError('An unexpected error occurred');

      if (!isRefresh && _state.listFeed.isEmpty) {
        _state.setFeeds([]);
      }
    } finally {
      _state.setLoading(false);
      _state.setRefreshing(false);
    }
  }

  /// Refresh feed data (pull-to-refresh)
  Future<void> refreshFeed([Map<String, dynamic>? query]) async {
    await fetchFeed(query ?? {}, isRefresh: true);
  }

  /// Add new feed (for real-time updates)
  Future<void> addNewFeed(FeedEntity feed) async {
    _state.addFeed(feed);
    await _cacheService.addFeedToCache(feed);
  }

  /// Update existing feed
  Future<void> updateFeed(FeedEntity updatedFeed) async {
    final index = _state.listFeed.indexWhere((feed) => feed.id == updatedFeed.id);
    if (index != -1) {
      _state.updateFeedAtIndex(index, updatedFeed);
      await _cacheService.updateFeedInCache(updatedFeed);
    }
  }

  /// Remove feed
  Future<void> removeFeed(String feedId) async {
    _state.removeFeedById(feedId);
    await _cacheService.removeFeedFromCache(feedId);
  }

  /// Toggle gallery visibility
  void toggleGalleryVisibility() {
    _state.toggleGalleryVisibility();
  }

  /// Set the pop image index for navigation
  void setPopImageIndex(int? value) {
    _logger.d('Setting pop image index: $value');
    _state.setPopImageIndex(value);
  }

  /// Set navigation state from gallery
  void setNavigatingFromGallery(bool value) {
    _state.setNavigatingFromGallery(value);
  }

  /// Handle navigation from gallery with proper state management
  void handleGalleryNavigation(int selectedIndex) {
    setNavigatingFromGallery(true);
    setPopImageIndex(selectedIndex);
    
    // Reset the navigation flag after a delay to prevent unwanted outer scroll
    Future.delayed(const Duration(milliseconds: 500), () {
      setNavigatingFromGallery(false);
    });
  }

  /// Clear cache (for debugging/logout)
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    _state.setFeeds([]);
  }

  /// Get cache info (for debugging)
  Map<String, dynamic> getCacheInfo() {
    return _cacheService.getCacheInfo();
  }

  /// Handle keyboard focus changes
  void _handleKeyboardFocus() {
    final isOpen = _messageFieldFocusNode.hasFocus;
    _state.setKeyboardOpen(isOpen);
  }

  /// Dispose resources
  void dispose() {
    _messageFieldFocusNode.removeListener(_handleKeyboardFocus);
    _messageFieldFocusNode.dispose();
  }
}