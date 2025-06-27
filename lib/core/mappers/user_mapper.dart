import 'package:locket/data/auth/models/user_model.dart';
import 'package:locket/domain/auth/entities/user_entity.dart';

class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      username: model.username,
      email: model.email,
      phoneNumber: model.phoneNumber,
      avatarUrl: model.avatarUrl,
      isVerified: model.isVerified,
      lastActiveAt: model.lastActiveAt,
      friends: model.friends,
      chatRooms: model.chatRooms,
      createdAt: model.createdAt,
    );
  }
}
