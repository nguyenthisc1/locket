class UserProfileModel {
  final String id;
  final String username;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final bool? isVerified;
  final DateTime? lastActiveAt;
  final List<String>? friends;
  final List<String>? chatRooms;

  const UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.isVerified = false,
    this.lastActiveAt,
    this.friends = const [],
    this.chatRooms = const [],
  });

  /// Creates a [UserProfileModel] from a JSON map.
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id:
          json['id'] as String? ??
          '', // MongoDB uses '_id' for the document id
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      lastActiveAt:
          json['lastActiveAt'] != null
              ? DateTime.tryParse(json['lastActiveAt'].toString())
              : null,
      friends:
          (json['friends'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      chatRooms:
          (json['chatRooms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// Converts this [UserProfileModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'friends': friends,
      'chatRooms': chatRooms,
    };
  }


}
