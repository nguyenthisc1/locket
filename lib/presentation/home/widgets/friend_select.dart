import 'package:flutter/material.dart';
import 'package:locket/common/wigets/custom_dropdown.dart';

class FriendSelect extends StatefulWidget {
  const FriendSelect({super.key});

  @override
  State<FriendSelect> createState() => _FriendSelectState();
}

class _FriendSelectState extends State<FriendSelect> {
  @override
  Widget build(BuildContext context) {
    return CustomDropdown(
      initialLabel: 'Mọi người',
      items: [
        {'label': 'Mọi người'},
        {'label': 'Bạn bè'},
        {'label': 'Tùy chỉnh'},
      ],
      onChanged: (value) {
        print('Chọn: $value');
      },
      dropdownChildBuilder:
          (index, item, selectedItem) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[800],
                  child: Text(
                    item["label"]![0].toUpperCase(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item["label"]!,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white30),
              ],
            ),
          ),
    );
  }
}
