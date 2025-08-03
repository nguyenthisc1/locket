import 'package:locket/data/user/models/user_profile_model.dart';
import 'package:locket/domain/user/entities/user_profile_entity.dart';

class UserProfileMapper {
  static UserProfileEntity toEntity(UserProfileModel user) {
    return UserProfileEntity(
      id: user.id,
      username: user.username,
      email: user.email,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      lastActiveAt: user.lastActiveAt,
      friends: user.friends,
      chatRooms: user.chatRooms,
    );
  }

  static UserProfileModel fromEntity(UserProfileEntity user) {
    return UserProfileModel(
      id: user.id,
      username: user.username,
      email: user.email,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      isVerified: user.isVerified,
      lastActiveAt: user.lastActiveAt,
      friends: user.friends,
      chatRooms: user.chatRooms,
    );
  }
}
