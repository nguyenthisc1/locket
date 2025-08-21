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