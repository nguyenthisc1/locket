// lib/presentation/home/controllers/feed_controller.dart

import 'package:flutter/material.dart';
import 'package:locket/core/services/feed_cache_service.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/domain/feed/usecases/get_feed_usecase.dart';
import 'package:locket/domain/feed/usecases/upload_feed_usecase.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/core/models/pagination_model.dart';
import 'package:locket/core/mappers/pagination_mapper.dart';
import 'package:locket/di.dart';
import 'package:logger/logger.dart';
import 'dart:io';

/// Business logic controller - handles all operations and business rules
class FeedController {
  final FeedControllerState _state;
  final FeedCacheService _cacheService;
  final GetFeedsUsecase _getFeedsUsecase;
  final UploadFeedUsecase _uploadFeedUsecase;
  final Logger _logger;
  final FocusNode _messageFieldFocusNode;
  // Upload and media state

  FeedController({
    required FeedControllerState state,
    required FeedCacheService cacheService,
    required GetFeedsUsecase getFeedsUsecase,
    required UploadFeedUsecase uploadFeedUsecase,
    Logger? logger,
  }) : _state = state,
       _cacheService = cacheService,
       _getFeedsUsecase = getFeedsUsecase,
       _uploadFeedUsecase = uploadFeedUsecase,
       _logger =
           logger ??
           Logger(printer: PrettyPrinter(colors: true, printEmojis: true)),
       _messageFieldFocusNode = FocusNode() {
    _messageFieldFocusNode.addListener(_handleKeyboardFocus);
  }

  // Getters for external access
  FeedControllerState get state => _state;
  FocusNode get messageFieldFocusNode => _messageFieldFocusNode;

  /// Initialize the controller with cached data only
  Future<void> init() async {
    // Only initialize once
    if (_state.hasInitialized) {
      return;
    }

    // Load cached data first (instant UI update)
    await fetchFeed();
    _state.setInitialized(true);
  }

  /// Fetch initial feeds from server (called when HomePage is mounted)
  Future<void> fetchInitialFeeds() async {
    await _loadCachedFeeds();
  }

  /// Load cached feeds (fast, offline-first)
  Future<void> _loadCachedFeeds() async {
    try {
      final cachedFeeds = await _cacheService.loadCachedFeeds();
      if (cachedFeeds.isNotEmpty) {
        _state.setFeedsPreservingDrafts(cachedFeeds);
        _logger.d('📦 Loaded ${cachedFeeds.length} feeds from cache');
      }
    } catch (e) {
      _logger.e('❌ Failed to load cached feeds: $e');
    }
  }

  /// Fetch feeds from API with caching
  Future<void> fetchFeed({
    String? query,
    DateTime? lastCreatedAt,
    int? limit,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _state.setRefreshing(true);
    } else {
      _state.setLoading(true);
    }
    _state.clearError();

    try {
      final result = await _getFeedsUsecase.call(
        query: query,
        lastCreatedAt: lastCreatedAt,
        limit: limit,
      );

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
          final paginationData = response.data['pagination'];

          // Parse pagination data if available
          if (paginationData != null) {
            final paginationModel = PaginationModel.fromJson(paginationData);
            final pagination = PaginationMapper.toEntity(paginationModel);
            _logger.d(
              'Pagination info: hasNextPage=${pagination.hasNextPage}, nextCursor=${pagination.nextCursor}',
            );

            // Update pagination state with server response
            _state.setHasMoreData(pagination.hasNextPage);
            if (pagination.nextCursor != null) {
              _state.setLastCreatedAt(pagination.nextCursor);
            }
          } else {
            // Fallback to old logic if no pagination data
            if (feeds.isNotEmpty) {
              _state.setLastCreatedAt(feeds.last.createdAt);
              _state.setHasMoreData(feeds.length == limit);
            } else {
              _state.setHasMoreData(false);
            }
          }

          // Use draft-preserving method instead of setFeeds
          _state.setFeedsPreservingDrafts(feeds);

          // Cache only server feeds (not drafts)
          _cacheService.cacheFeeds(_state.serverFeeds);
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
  Future<void> refreshFeed([String? query, DateTime? lastCreatedAt]) async {
    await fetchFeed(
      query: query,
      lastCreatedAt: lastCreatedAt,
      isRefresh: true,
    );
  }

  /// Add new feed (for real-time updates)
  Future<void> addNewFeed(FeedEntity feed) async {
    // Check if it's a draft feed
    final isDraft =
        feed.id.startsWith('draft_') || feed.imageUrl.startsWith('local://');

    if (isDraft) {
      // For draft feeds, add normally (they go to the top)
      _state.addFeed(feed);
    } else {
      // For server feeds, check for duplicates
      final existingIds = _state.serverFeeds.map((f) => f.id).toSet();
      if (!existingIds.contains(feed.id)) {
        _state.addFeed(feed);
        await _cacheService.addFeedToCache(feed);
      }
    }
  }

  /// Update existing feed
  Future<void> updateFeed(FeedEntity updatedFeed) async {
    final index = _state.listFeed.indexWhere(
      (feed) => feed.id == updatedFeed.id,
    );
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

  /// Load more feeds for infinite scroll
  Future<void> loadMoreFeeds() async {
    if (_state.isLoadingMore || !_state.hasMoreData) {
      return; // Already loading or no more data
    }

    _state.setLoadingMore(true);
    _state.clearError();

    try {
      final result = await _getFeedsUsecase.call(
        lastCreatedAt: _state.lastCreatedAt,
      );

      result.fold(
        (failure) {
          _logger.e('Failed to load more feeds: ${failure.message}');
          _state.setError(failure.message);
        },
        (response) {
          _logger.d('More feeds loaded successfully');
          _state.clearError();

          final newFeeds = response.data['feeds'] as List<FeedEntity>;
          final paginationData = response.data['pagination'];
          _logger.d('new Loadmore feed $newFeeds');

          // Parse pagination data if available
          if (paginationData != null) {
            final paginationModel = PaginationModel.fromJson(paginationData);
            final pagination = PaginationMapper.toEntity(paginationModel);
            _logger.d(
              'Load more pagination: hasNextPage=${pagination.hasNextPage}, nextCursor=${pagination.nextCursor}',
            );

            // Update pagination state with server response
            _state.setHasMoreData(pagination.hasNextPage);
            if (pagination.nextCursor != null) {
              _state.setLastCreatedAt(pagination.nextCursor);
            }
          } else {
            // Fallback to old logic if no pagination data
            if (newFeeds.isEmpty) {
              _state.setHasMoreData(false);
            } else if (newFeeds.isNotEmpty) {
              _state.setLastCreatedAt(newFeeds.last.createdAt);
            }
          }

          // Append new feeds while preserving drafts and avoiding duplicates
          if (newFeeds.isNotEmpty) {
            _state.appendFeedsPreservingDrafts(newFeeds);
          }

          // Cache only server feeds (not drafts)
          _cacheService.cacheFeeds(_state.serverFeeds);
        },
      );
    } catch (e) {
      _logger.e('Error loading more feeds: $e');
      _state.setError('Failed to load more feeds');
    } finally {
      _state.setLoadingMore(false);
    }
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

  /// Create a draft feed entity for preview/caching before upload
  void createDraftFeed(
    String filePath,
    MediaType mediaType,
    String fileName,
    bool isFrontCamera,
  ) {
    try {
      final userService = getIt<UserService>();
      final currentUser = userService.currentUser;

      if (currentUser == null) {
        _logger.w('Cannot create draft feed - no current user');
        return;
      }

      // Create a temporary feed entity with a special draft indicator
      _logger.d('Creating draft feed with caption: ${_state.captionFeed}');

      final draftFeed = FeedEntity(
        id: 'draft_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
        user: FeedUser(
          id: currentUser.id,
          username: currentUser.username,
          avatarUrl: currentUser.avatarUrl ?? '',
        ),
        imageUrl: _createLocalUri(filePath),
        caption: _state.captionFeed,
        isFrontCamera: isFrontCamera,
        mediaType: mediaType,
        format: mediaType == MediaType.video ? 'mp4' : 'jpg',
        createdAt: DateTime.now(),
        width: 0,
        height: 0,
        fileSize: 0,
      );

      _state.setNewFeed(draftFeed);
      
      // Immediately add the draft feed to the list for preview
      _state.addFeed(draftFeed);
      _logger.d('Draft feed created and added to list: ${draftFeed.id}');
    } catch (e) {
      _logger.e('Error creating draft feed: $e');
    }
  }

  /// Upload captured media (photo or video)
  Future<void> uploadMedia(
    String filePath,
    String fileName,
    String mediaType,
    bool isFrontCamera,
  ) async {
    if (_state.newFeed == null) {
      _logger.e('No media to upload - no draft feed found');
      _state.setError('No media captured to upload');
      return;
    }

    _state.clearError();
    _state.clearUploadStatus();
    _state.setUploading(true);

    try {
      // Create multipart file
      final file = File(filePath);

      // Prepare payload with conditional key based on mediaType
      final payload = <String, dynamic>{
        'filePath': file.path,
        'fileName': fileName,
        'mediaType': mediaType,
        'isFrontCamera': isFrontCamera,
        'caption': _state.captionFeed,
      };

      _logger.d('Uploading $mediaType: $fileName');
      _logger.d('Caption: ${_state.captionFeed ?? 'No caption'}');

      // Upload via use case
      final result = await _uploadFeedUsecase.call(payload);

      result.fold(
        (failure) {
          _logger.e('Upload failed: ${failure.message}');
          _state.setError('Upload failed: ${failure.message}');
          _state.setUploading(false);
        },
        (success) {
          _logger.d('Upload successful! Response: ${success.message}');
          _state.setUploadSuccess(true);

          // Add the draft feed to the feed list
          addNewFeedToList();

          // Reset after delay (but keep the feed in the list)
          Future.delayed(const Duration(seconds: 2), () {
            resetUploadStateAfterSuccess();
          });
        },
      );
    } catch (e) {
      _logger.e('Upload exception: $e');
      _state.setError('Upload exception: $e');
      _state.setUploading(false);
    } finally {
      _state.setUploading(false);
    }
  }

  /// Add the new feed to the list (used after successful upload)
  void addNewFeedToList() {
    if (_state.newFeed != null) {
      // Check if the draft feed is already in the list
      final existingIndex = _state.listFeed.indexWhere((feed) => feed.id == _state.newFeed!.id);
      
      if (existingIndex == -1) {
        // Feed not in list yet, add it
        _logger.d('Adding new feed to list: ${_state.newFeed!.id}');
        _state.addFeed(_state.newFeed!);
        _logger.d('Feed added to list. Total feeds: ${_state.listFeed.length}');
      } else {
        // Feed already in list, just update it if needed
        _state.updateFeedAtIndex(existingIndex, _state.newFeed!);
        _logger.d('Updated existing feed in list at index $existingIndex');
      }
    } else {
      _logger.w('No new feed to add to list');
    }
  }

  /// Reset upload state after successful upload (keeps the feed in the list)
  void resetUploadStateAfterSuccess() {
    _logger.d('Resetting upload state after successful upload...');

    // Don't remove the feed from the list, just clear upload state
    _state.setUploadSuccess(false);
    _state.setUploading(false);
    _state.setNewFeed(null);
    _state.setCaption('');
    _state.clearError();

    _logger.d('Upload state reset completed (feed kept in list)');
  }

  /// Reset upload state (clears draft feed and related state) - used for cancellation
  void resetUploadState() {
    _logger.d('Resetting upload state...');

    // Remove draft feed from list if it exists
    if (_state.newFeed != null) {
      _state.removeFeedById(_state.newFeed!.id);
      _logger.d('Removed draft feed from list: ${_state.newFeed!.id}');
    }

    _state.setUploadSuccess(false);
    _state.setUploading(false);
    _state.setNewFeed(null);
    _state.setCaption('');
    _state.clearError();

    _logger.d('Upload state reset completed');
  }

  /// Set caption for the current feed
  void setCaption(String caption) {
    _state.setCaption(caption);
    _logger.d('Caption updated: $caption');
    
    // Update the draft feed with the new caption if it exists
    if (_state.newFeed != null) {
      final updatedDraftFeed = _state.newFeed!.copyWith(caption: caption);
      _state.setNewFeed(updatedDraftFeed);
      
      // Also update the feed in the list if it's already there
      final draftIndex = _state.listFeed.indexWhere((feed) => feed.id == _state.newFeed!.id);
      if (draftIndex != -1) {
        _state.updateFeedAtIndex(draftIndex, updatedDraftFeed);
        _logger.d('Updated draft feed caption in list at index $draftIndex');
      }
      
      _logger.d('Updated draft feed caption: $caption');
    }
  }

  /// Create a properly formatted local URI for file paths
  String _createLocalUri(String filePath) {
    // Handle case where filePath might already have a prefix
    String cleanPath = filePath;
    
    // Remove any existing prefixes
    if (cleanPath.startsWith('local:////')) {
      cleanPath = cleanPath.substring(10);
    } else if (cleanPath.startsWith('local:///')) {
      cleanPath = cleanPath.substring(9);
    } else if (cleanPath.startsWith('file:///')) {
      cleanPath = cleanPath.substring(8);
    } else if (cleanPath.startsWith('file://')) {
      cleanPath = cleanPath.substring(7);
    }
    
    // Handle case where path starts with additional slashes
    while (cleanPath.startsWith('//')) {
      cleanPath = cleanPath.substring(1);
    }
    
    // Ensure we have an absolute path
    if (cleanPath.isNotEmpty && !cleanPath.startsWith('/')) {
      cleanPath = '/$cleanPath';
    }
    
    // Return with consistent local:// prefix (single slash after colon)
    return 'local://$cleanPath';
  }

  /// Dispose resources
  void dispose() {
    _messageFieldFocusNode.removeListener(_handleKeyboardFocus);
    _messageFieldFocusNode.dispose();
  }
}
