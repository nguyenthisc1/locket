// lib/presentation/home/controllers/feed_controller.dart

import 'package:flutter/material.dart';
import 'package:locket/core/services/feed_cache_service.dart';
import 'package:locket/data/feed/respositories/feed_repository_impl.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/domain/feed/usecases/get_feed_usecase.dart';
import 'package:logger/logger.dart';

class FeedControllerState extends ChangeNotifier {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  final FocusNode messageFieldFocusNode = FocusNode();
  bool _isVisibleGallery = true;
  bool _isKeyboardOpen = false;
  int _popImageIndex = 0;
  List<FeedEntity> _listFeed = [];
  bool _isLoading = false;
  bool _hasInitialized = false;
  String? _errorMessage;
  bool _isRefreshing = false;

  // Cache service
  late final FeedCacheService _cacheService;

  // Getters
  List<FeedEntity> get listFeed => _listFeed;
  bool get isVisibleGallery => _isVisibleGallery;
  bool get isKeyboardOpen => _isKeyboardOpen;
  int get popImageIndex => _popImageIndex;
  bool get isLoading => _isLoading;
  bool get hasInitialized => _hasInitialized;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;

  FeedControllerState() {
    messageFieldFocusNode.addListener(_handleKeyboardFocus);
    _cacheService = getIt<FeedCacheService>();
  }

  Future<void> init() async {
    // Only initialize once
    if (_hasInitialized) {
      return;
    }
    
    // Load cached data first (instant UI update)
    await _loadCachedFeeds();
    
    // Then fetch fresh data
    await fetchFeed({});
    _hasInitialized = true;
  }

  /// Load cached feeds (fast, offline-first)
  Future<void> _loadCachedFeeds() async {
    try {
      final cachedFeeds = await _cacheService.loadCachedFeeds();
      if (cachedFeeds.isNotEmpty) {
        _listFeed = cachedFeeds;
        logger.d('📦 Loaded ${cachedFeeds.length} feeds from cache');
        notifyListeners();
      }
    } catch (e) {
      logger.e('❌ Failed to load cached feeds: $e');
    }
  }

  Future<void> fetchFeed(Map<String, dynamic> query, {bool isRefresh = false}) async {
    if (isRefresh) {
      _isRefreshing = true;
    } else {
      _isLoading = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final feedRepository = getIt<FeedRepositoryImpl>();
      final getFeedUseCase = GetFeedUsecase(feedRepository);

      final result = await getFeedUseCase(query);

      result.fold(
        (failure) {
          logger.e('UI Failed to fetch Feed: ${failure.message}');
          _errorMessage = failure.message;
          
          // If it's a fresh fetch (not refresh) and we have no cached data, clear the list
          if (!isRefresh && _listFeed.isEmpty) {
            _listFeed = [];
          }
          // If it's a refresh, keep the existing cached data
        },
        (response) {
          logger.d('UI Feed fetched successfully');
          _errorMessage = null;

          final feeds = response.data['feeds'] as List<FeedEntity>;
          _listFeed = [...feeds];
          
          // Cache the new data
          _cacheService.cacheFeeds(_listFeed);
        },
      );
    } catch (e) {
      logger.e('UI Error fetching feed: $e');
      _errorMessage = 'An unexpected error occurred';
      
      if (!isRefresh && _listFeed.isEmpty) {
        _listFeed = [];
      }
    } finally {
      _isLoading = false;
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Refresh feed data (pull-to-refresh)
  Future<void> refreshFeed([Map<String, dynamic>? query]) async {
    await fetchFeed(query ?? {}, isRefresh: true);
  }

  /// Add new feed (for real-time updates)
  Future<void> addNewFeed(FeedEntity feed) async {
    _listFeed = [feed, ..._listFeed];
    await _cacheService.addFeedToCache(feed);
    notifyListeners();
  }

  /// Update existing feed
  Future<void> updateFeed(FeedEntity updatedFeed) async {
    final index = _listFeed.indexWhere((feed) => feed.id == updatedFeed.id);
    if (index != -1) {
      _listFeed[index] = updatedFeed;
      await _cacheService.updateFeedInCache(updatedFeed);
      notifyListeners();
    }
  }

  /// Remove feed
  Future<void> removeFeed(String feedId) async {
    _listFeed.removeWhere((feed) => feed.id == feedId);
    await _cacheService.removeFeedFromCache(feedId);
    notifyListeners();
  }

  void _handleKeyboardFocus() {
    final isOpen = messageFieldFocusNode.hasFocus;
    if (isOpen != _isKeyboardOpen) {
      _isKeyboardOpen = isOpen;
      notifyListeners();
    }
  }

  void toggleGalleryVisibility() {
    _isVisibleGallery = !_isVisibleGallery;
    notifyListeners();
  }

  void setPopImageIndex(int? value) {
    if (value != null && value != _popImageIndex) {
      _popImageIndex = value;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  /// Clear cache (for debugging/logout)
  Future<void> clearCache() async {
    await _cacheService.clearCache();
    _listFeed.clear();
    notifyListeners();
  }

  /// Get cache info (for debugging)
  Map<String, dynamic> getCacheInfo() {
    return _cacheService.getCacheInfo();
  }

  @override
  void dispose() {
    messageFieldFocusNode.removeListener(_handleKeyboardFocus);
    messageFieldFocusNode.dispose();
    super.dispose();
  }
}