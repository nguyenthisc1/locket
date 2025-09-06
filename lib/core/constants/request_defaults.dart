/// Default configuration values for API requests and pagination
/// 
/// This class centralizes all default values used across the application
/// for consistent request handling and easier maintenance.
class RequestDefaults {
  RequestDefaults._();

  /// Default pagination limits for different types of requests
  static const int defaultListLimit = 10;
  static const int feedListLimit = 20;
  static const int conversationListLimit = 15;
  static const int messageListLimit = 25;
  
  /// Cache configuration defaults
  static const int maxCachedConversations = 100;
  static const int maxCachedMessages = 200;
  static const int maxCachedFeeds = 50;

  /// Network timeout defaults (in seconds)
  static const int defaultTimeout = 20;
  static const int uploadTimeout = 60;
  static const int downloadTimeout = 30;

  /// Media upload defaults
  static const int maxVideoRecordingMinutes = 5;
  static const int maxImageUploadSizeMB = 10;
  static const int maxVideoUploadSizeMB = 50;

  /// Search and filtering defaults
  static const int searchResultsLimit = 15;
  static const int minSearchQueryLength = 2;

  /// UI pagination defaults
  static const int loadMoreThreshold = 100; // pixels from bottom to trigger load more
  static const int refreshCooldownSeconds = 2;

  /// Friend request defaults
  static const int friendRequestsLimit = 20;
  static const int friendsListLimit = 30;
  static const int mutualFriendsLimit = 10;

  /// Profile and user defaults
  static const int userSearchLimit = 20;
  static const int recentUsersLimit = 10;

  /// API response defaults
  static const String defaultErrorMessage = 'An unexpected error occurred';
  static const String defaultNetworkErrorMessage = 'Network connection error';
  static const String defaultServerErrorMessage = 'Server error occurred';

  /// Helper methods to get typed limits for specific use cases
  static int getLimitForEndpoint(String endpoint) {
    switch (endpoint) {
      case '/feed':
        return feedListLimit;
      case '/conversation/user':
        return conversationListLimit;
      case '/message/conversation':
        return messageListLimit;
      case '/users/search':
        return userSearchLimit;
      case '/user/friends':
        return friendsListLimit;
      case '/user/friends/requests':
        return friendRequestsLimit;
      default:
        return defaultListLimit;
    }
  }

  /// Get cache limit based on data type
  static int getCacheLimit(String dataType) {
    switch (dataType) {
      case 'conversations':
        return maxCachedConversations;
      case 'messages':
        return maxCachedMessages;
      case 'feeds':
        return maxCachedFeeds;
      default:
        return defaultListLimit;
    }
  }

  /// Get timeout based on operation type
  static int getTimeoutForOperation(String operation) {
    switch (operation) {
      case 'upload':
        return uploadTimeout;
      case 'download':
        return downloadTimeout;
      default:
        return defaultTimeout;
    }
  }
}
