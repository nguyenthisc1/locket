
class  ApiUrl {
  // static const String baseUrl = 'https://locket-backend.onrender.com/api/v1';
  static const String baseIp = '172.16.16.145';
  static const String baseUrl = 'http://$baseIp:8080/api/v1';
  static const String socketUrl = 'http://$baseIp:8080';

  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Conversations
  static const String createConversation = '/conversation';
  static const String getUserConversations = '/conversation/user';
  static const String searchConversations = '/conversation/search';
  static const String unreadCountConversations = '/conversation/unread-count';
  static String getConversationById(String conversationId) =>
      '/conversation/$conversationId';
    static String markConversationAsRead(String conversationId) =>
      '/message/$conversationId/read';
  static String updateConversation(String conversationId) =>
      '/conversation/$conversationId';
  static String addParticipants(String conversationId) =>
      '/conversation/$conversationId/participants';
  static String removeParticipant(String conversationId) =>
      '/conversation/$conversationId/participants';
  static String getConversationThreads(String conversationId) =>
      '/conversation/$conversationId/threads';
  static String leaveConversation(String conversationId) =>
      '/conversation/$conversationId/leave';
  static String deleteConversation(String conversationId) =>
      '/conversation/$conversationId';

  // Messages
  static const String sendMessage = '/message';
  static String getConversationMessages(String conversationId) =>
      '/message/conversation/$conversationId';
  static const String searchMessages = '/message/search';
  static String getMessageById(String messageId) => '/message/$messageId';
  static String editMessage(String messageId) => '/message/$messageId';
  static String deleteMessage(String messageId) => '/message/$messageId';
  static String addReaction(String messageId) =>
      '/message/$messageId/reactions';
  static String removeReaction(String messageId) =>
      '/message/$messageId/reactions';
  static String replyToMessage(String messageId) => '/message/$messageId/reply';
  static String getThreadMessages(String messageId) =>
      '/message/$messageId/thread';
  static String pinMessage(String messageId) => '/message/$messageId/pin';
  static const String forwardMessages = '/message/forward';

  // Photos
  static const String getPhotos = '/feed';
  static String getPhotoById(String photoId) => '/feed/$photoId';
  static String getUserPhotos(String userId) => '/feed/user/$userId';
  static const String createPhoto = '/feed';
  static String updatePhoto(String photoId) => '/feed/$photoId';
  static String deletePhoto(String photoId) => '/feed/$photoId';
  static String addPhotoReaction(String photoId) => '/feed/$photoId/reactions';
  static String removePhotoReaction(String photoId) =>
      '/feed/$photoId/reactions';

  static const String uploadPhoto = '/upload';
  static const String uploadMultiplePhotos = '/upload/upload-multiple';
  static String deletePhotoWithCloudinary(String photoId) => '/upload/$photoId';
  static String getImageUrls(String photoId) => '/upload/$photoId/urls';

  // Users
  static const String getProfile = '/user';
  static const String updateProfile = '/users';
  static String deleteAccount(String userId) => '/users/$userId';
  static const String searchUsers = '/users/search';

  // Friends Feature
  static const String sendFriendRequest = '/user/friends/request';
  static String respondToFriendRequest(String requestId) => '/user/friends/request/$requestId';
  static const String getFriendRequests = '/user/friends/requests';
  static const String getFriends = '/user/friends';
  static String removeFriend(String friendId) => '/user/friends/$friendId';
  static String blockUser(String userId) => '/user/friends/block/$userId';
  static String getMutualFriends(String userId) => '/user/friends/mutual/$userId';
}
