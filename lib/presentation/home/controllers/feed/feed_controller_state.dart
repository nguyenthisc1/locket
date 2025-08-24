import 'package:flutter/material.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';

/// Pure state class - only holds data, no business logic
class FeedControllerState extends ChangeNotifier {
  // Private fields
  bool _isVisibleGallery = true;
  bool _isKeyboardOpen = false;
  bool _isNavigatingFromGallery = false;
  int _popImageIndex = 0;
  List<FeedEntity> _listFeed = [];
  bool _isLoading = false;
  bool _hasInitialized = false;
  String? _errorMessage;
  bool _isRefreshing = false;

  // Upload and media state
  bool _isUploading = false;
  bool _isUploadSuccess = false;
  FeedEntity? _newFeed;
  String? _captionFeed = '';

  // Pagination state
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  DateTime? _lastCreatedAt;

  // Getters
  bool get isVisibleGallery => _isVisibleGallery;
  bool get isKeyboardOpen => _isKeyboardOpen;
  bool get isNavigatingFromGallery => _isNavigatingFromGallery;
  int get popImageIndex => _popImageIndex;
  List<FeedEntity> get listFeed => _listFeed;
  bool get isLoading => _isLoading;
  bool get hasInitialized => _hasInitialized;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  bool get isUploading => _isUploading;
  bool get isUploadSuccess => _isUploadSuccess;
  FeedEntity? get newFeed => _newFeed;
  String? get captionFeed => _captionFeed;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;
  DateTime? get lastCreatedAt => _lastCreatedAt;

  // State update methods (no business logic)
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  void setRefreshing(bool value) {
    if (_isRefreshing != value) {
      _isRefreshing = value;
      notifyListeners();
    }
  }

  void setError(String? value) {
    if (_errorMessage != value) {
      _errorMessage = value;
      notifyListeners();
    }
  }

  void setFeeds(List<FeedEntity> feeds) {
    _listFeed = List.from(feeds);
    notifyListeners();
  }

  void addFeed(FeedEntity feed) {
    _listFeed = [feed, ..._listFeed];
    notifyListeners();
  }

  void updateFeedAtIndex(int index, FeedEntity feed) {
    if (index >= 0 && index < _listFeed.length) {
      _listFeed[index] = feed;
      notifyListeners();
    }
  }

  void removeFeedById(String feedId) {
    _listFeed.removeWhere((feed) => feed.id == feedId);
    notifyListeners();
  }

  void setGalleryVisibility(bool isVisible) {
    if (_isVisibleGallery != isVisible) {
      _isVisibleGallery = isVisible;
      notifyListeners();
    }
  }

  void toggleGalleryVisibility() {
    _isVisibleGallery = !_isVisibleGallery;
    notifyListeners();
  }

  void setNavigatingFromGallery(bool value) {
    if (_isNavigatingFromGallery != value) {
      _isNavigatingFromGallery = value;
      notifyListeners();
    }
  }

  void setKeyboardOpen(bool isOpen) {
    if (_isKeyboardOpen != isOpen) {
      _isKeyboardOpen = isOpen;
      notifyListeners();
    }
  }

  void setPopImageIndex(int? value) {
    if (value != null && value != _popImageIndex) {
      _popImageIndex = value;
      notifyListeners();
    } else if (value == null) {
      // Reset to default value when null is passed
      _popImageIndex = 0;
      notifyListeners();
    }
  }

  void setInitialized(bool value) {
    if (_hasInitialized != value) {
      _hasInitialized = value;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  // Upload and media state methods
  void setUploading(bool value) {
    if (_isUploading != value) {
      _isUploading = value;
      notifyListeners();
    }
  }

  void setUploadSuccess(bool value) {
    if (_isUploadSuccess != value) {
      _isUploadSuccess = value;
      notifyListeners();
    }
  }

  void setNewFeed(FeedEntity? feed) {
    if (_newFeed != feed) {
      _newFeed = feed;
      notifyListeners();
    }
  }

  void setCaption(String value) {
    if (_captionFeed != value) {
      _captionFeed = value;
      notifyListeners();
    }
  }

  void setLoadingMore(bool value) {
    if (_isLoadingMore != value) {
      _isLoadingMore = value;
      notifyListeners();
    }
  }

  void setHasMoreData(bool value) {
    if (_hasMoreData != value) {
      _hasMoreData = value;
      notifyListeners();
    }
  }

  void setLastCreatedAt(DateTime? value) {
    if (_lastCreatedAt != value) {
      _lastCreatedAt = value;
      notifyListeners();
    }
  }

  void appendFeeds(List<FeedEntity> newFeeds) {
    _listFeed.addAll(newFeeds);
    notifyListeners();
  }

  /// Check if a feed is a draft (local feed not yet uploaded)
  bool _isDraftFeed(FeedEntity feed) {
    return feed.id.startsWith('draft_') || feed.imageUrl.startsWith('local://');
  }

  /// Get only server feeds (non-draft feeds)
  List<FeedEntity> get serverFeeds {
    return _listFeed.where((feed) => !_isDraftFeed(feed)).toList();
  }

  /// Get only draft feeds
  List<FeedEntity> get draftFeeds {
    return _listFeed.where((feed) => _isDraftFeed(feed)).toList();
  }

  /// Replace server feeds while preserving draft feeds at the top
  void setFeedsPreservingDrafts(List<FeedEntity> serverFeeds) {
    final currentDrafts = draftFeeds;
    _listFeed = [...currentDrafts, ...serverFeeds];
    notifyListeners();
  }

  /// Append server feeds while preserving draft feeds and avoiding duplicates
  void appendFeedsPreservingDrafts(List<FeedEntity> newServerFeeds) {
    // Get existing server feed IDs to avoid duplicates
    final existingServerIds = serverFeeds.map((f) => f.id).toSet();
    final uniqueNewFeeds = newServerFeeds.where((feed) => 
      !existingServerIds.contains(feed.id) && !_isDraftFeed(feed)
    ).toList();
    
    if (uniqueNewFeeds.isNotEmpty) {
      _listFeed.addAll(uniqueNewFeeds);
      notifyListeners();
    }
  }

  void clearUploadStatus() {
    bool hasChanges = false;
    if (_isUploadSuccess != false) {
      _isUploadSuccess = false;
      hasChanges = true;
    }
    if (_isUploading != false) {
      _isUploading = false;
      hasChanges = true;
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  void reset() {
    _isVisibleGallery = true;
    _isKeyboardOpen = false;
    _isNavigatingFromGallery = false; // Reset this too
    _popImageIndex = 0;
    _listFeed.clear();
    _isLoading = false;
    _hasInitialized = false;
    _errorMessage = null;
    _isRefreshing = false;
    _isUploading = false;
    _isUploadSuccess = false;
    _newFeed = null;
    _captionFeed = '';
    notifyListeners();
  }
}
