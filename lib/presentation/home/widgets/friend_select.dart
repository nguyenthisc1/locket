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
          (index, item) => Padding(
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


  // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.white.safeOpacity(0.2),
          //     borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          //   ),
          //   child:
          //   // child: CustomDropdown(
          //   //   items: ['mọi người', 'chỉ bạn bè', 'tùy chỉnh'],
          //   //   initialValue: 'mọi người',
          //   //   onChanged: (value) {
          //   //     print('Selected: $value');
          //   //   },
          //   // ),
          //   // child: Material(
          //   //   color: Colors.transparent,
          //   //   child: InkWell(
          //   //     borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
          //   //     onTap: _showDropdown,
          //   //     child: Padding(
          //   //       padding: EdgeInsets.symmetric(
          //   //         horizontal: AppDimensions.md,
          //   //         vertical: AppDimensions.sm,
          //   //       ),
          //   //       child: Row(
          //   //         mainAxisSize: MainAxisSize.min,
          //   //         children: [
          //   //           Text(
          //   //             _selectedValue,
          //   //             style: AppTypography.headlineMedium.copyWith(
          //   //               fontWeight: FontWeight.w800,
          //   //               color: Colors.white70,
          //   //             ),
          //   //           ),
          //   //           const SizedBox(width: 8),
          //   //           const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          //   //         ],
          //   //       ),
          //   //     ),
          //   //   ),
          //   // ),
          // ),