import 'package:flutter/material.dart';
import 'package:locket/common/wigets/custom_dropdown.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:locket/core/services/user_service.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller.dart';
import 'package:provider/provider.dart';

class FriendSelect extends StatelessWidget {
  const FriendSelect({super.key});

  @override
  Widget build(BuildContext context) {
    final feedController = context.read<FeedController>();

    return Consumer<UserService>(
      builder: (context, userService, child) {
        final friends = userService.currentUser?.friends;
        final List<Map<String, String>> dropdownItems = [
          {'label': 'Mọi người', 'value': ''},
          {
            'label': 'Bạn',
            'value': userService.currentUser?.username ?? '',
            'avatarUrl': userService.currentUser?.avatarUrl ?? '',
          },
        ];

        if (friends != null && friends.isNotEmpty) {
          dropdownItems.addAll(
            friends.map(
              (friend) => {
                'label':
                    friend.username.isNotEmpty ? friend.username : friend.email,
                'value':
                    friend.username.isNotEmpty ? friend.username : friend.email,
                'avatarUrl': friend.avatarUrl ?? '',
              },
            ),
          );
        }

        return CustomDropdown(
          initialLabel: 'Mọi người',
          items: dropdownItems,
          onChanged: (value) async {
            await feedController.fetchFeed(query: value.toString(), isRefresh: true);
          },
          dropdownChildBuilder: (index, item, selectedItem) {
            // Handle separator
            if (item['label'] == '---') {
              return const Divider(
                color: Colors.white24,
                thickness: 1,
                height: 1,
              );
            }
            // If friend has avatarUrl, show avatar, else show first letter
            final avatarUrl = item['avatarUrl'];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[800],
                    backgroundImage:
                        (avatarUrl != null && avatarUrl.isNotEmpty)
                            ? NetworkImage(avatarUrl)
                            : null,
                    child:
                        (avatarUrl == null || avatarUrl.isEmpty)
                            ? Text(
                              item["label"]![0].toUpperCase(),
                              style: const TextStyle(fontSize: 16),
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item["label"]!,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.white30, size: AppDimensions.iconMd,),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
