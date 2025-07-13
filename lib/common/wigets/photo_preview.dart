// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PhotoPreview extends StatelessWidget {
  final String imageUrl;
  final String? tag;
  final Function() onClose;

  const PhotoPreview({
    super.key,
    required this.imageUrl,
    this.tag,
    required this.onClose,
  });

  // Returns the application documents directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _copyFile(BuildContext context) async {
    try {
      final path = await _localPath;
      final filePath = '$path/image.png';

      // Download the image and save it as image.png in the app documents directory
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Copy the content URI to clipboard
        await Clipboard.setData(
          ClipboardData(text: "content://$path/image.png"),
        );
        DisplayMessage.message(context, 'Đã sao chép đường dẫn ảnh');
      } else {
        DisplayMessage.message(context, 'Không thể tải ảnh để sao chép');
      }
    } catch (e) {
      DisplayMessage.message(context, 'Sao chép ảnh thất bại');
    }
  }

  Future<void> _downloadImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/downloaded_image.jpg');
        await file.writeAsBytes(response.bodyBytes);

        final success = await GallerySaver.saveImage(file.path);

        if (success ?? false) {
          DisplayMessage.message(context, 'Đã lưu ảnh về máy');
        } else {
          DisplayMessage.message(context, 'Lưu ảnh thất bại');
        }
      } else {
        DisplayMessage.message(
          context,
          'Tải ảnh thất bại (status code ${response.statusCode})',
        );
      }
    } catch (e) {
      DisplayMessage.message(context, 'Lưu ảnh thất bại');
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/shared_image.jpg');
        await file.writeAsBytes(bytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Chia sẻ ảnh này nhé!');
      }
    } catch (e) {
      print('Lỗi khi share ảnh: $e');
    }
  }

  void _showMoreOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.forward),
                title: const Text('Chuyển tiếp'),
                onTap: () {
                  Navigator.of(context).pop();
                  DisplayMessage.message(
                    context,
                    'Chức năng chuyển tiếp chưa được hỗ trợ',
                  );
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.copy),
              //   title: const Text('Sao chép liên kết'),
              //   onTap: () => _copyFile(context),
              // ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Chia sẻ'),
                onTap: () => _shareImage(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        hideBack: true,
        action: Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, size: AppDimensions.iconLg),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _downloadImage(context),
                      child: Icon(
                        Icons.download_sharp,
                        size: AppDimensions.iconLg,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    GestureDetector(
                      onTap: () => _showMoreOptions(context),
                      child: Icon(
                        Icons.more_horiz_outlined,
                        size: AppDimensions.xl,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.md,
        ),
        child: GestureDetector(
          onScaleStart: (details) {},
          onScaleUpdate: (details) {},
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            child: SizedBox.expand(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
