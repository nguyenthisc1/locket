import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPickerModalDemo extends StatefulWidget {
  const GalleryPickerModalDemo({super.key});

  @override
  State<GalleryPickerModalDemo> createState() => _GalleryPickerModalDemoState();
}

class _GalleryPickerModalDemoState extends State<GalleryPickerModalDemo> {
  List<AssetEntity> images = [];

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      setState(() {
        images = [];
      });
      return;
    }

    final recent = albums.first;
    final media = await recent.getAssetListPaged(page: 0, size: 100);

    setState(() {
      images = media;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: images.length,
            itemBuilder: (_, index) {
              final asset = images[index];
              return FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(
                  const ThumbnailSize.square(240),
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () => Navigator.pop(context, asset),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusLg,
                      ),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
