import 'package:flutter/material.dart';
import 'package:locket/common/helper/messages/display_message.dart';
import 'package:locket/common/wigets/appbar/appbar.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:flutter/services.dart';

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

  Future<void> _downloadImage(BuildContext context) async {
    // try {
    //   await GallerySaver.saveImage(imageUrl);
    //   // ignore: use_build_context_synchronously
    //   DisplayMessage.message(context, 'Đã lưu ảnh về máy');
    // } catch (e) {
    //   // ignore: use_build_context_synchronously
    //   DisplayMessage.message(context, 'Lưu ảnh thất bại');
    // }
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
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Sao chép liên kết'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await Clipboard.setData(ClipboardData(text: imageUrl));
                  // ignore: use_build_context_synchronously
                  DisplayMessage.message(context, 'Đã sao chép liên kết ảnh');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Chia sẻ'),
                onTap: () async {
                  Navigator.of(context).pop();
                  // ignore: deprecated_member_use
                  // await Share.share(imageUrl, subject: 'Chia sẻ ảnh');
                },
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
