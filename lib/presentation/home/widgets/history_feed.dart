import 'dart:io';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart' as Utils;
import 'package:locket/common/wigets/user_image.dart';
import 'package:locket/core/configs/theme/app_dimensions.dart';
import 'package:locket/core/configs/theme/app_typography.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/presentation/home/controllers/feed/feed_controller_state.dart';
import 'package:provider/provider.dart';

class HistoryFeed extends StatefulWidget {
  const HistoryFeed({super.key});

  @override
  State<HistoryFeed> createState() => _HistoryFeedState();
}

class _HistoryFeedState extends State<HistoryFeed> {
  int _currentIndex = 0;
  List<FeedEntity> _feeds = [];
  bool _isCycling = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final feedState = context.watch<FeedControllerState>();

    final feeds =
        feedState.listFeed
            .where(
              (f) =>
                  (f.mediaType == MediaType.image ||
                      (f.mediaType != MediaType.video &&
                          (f.format.toLowerCase() != 'mp4' &&
                              f.format.toLowerCase() != 'mov' &&
                              f.format.toLowerCase() != 'avi'))),
            )
            .cast<FeedEntity>()
            .take(3)
            .toList();

    if (_feeds != feeds) {
      setState(() {
        _feeds = feeds;
        _currentIndex = 0;
      });
      _isCycling = false;
      if (_feeds.isNotEmpty) {
        _startImageCycle();
      }
    } else if (_feeds.isNotEmpty && !_isCycling) {
      _startImageCycle();
    }
  }

  void _startImageCycle() {
    if (_isCycling || _feeds.length < 2) return;
    _isCycling = true;
    Future.delayed(const Duration(seconds: 5), _nextImage);
  }

  void _nextImage() {
    if (!mounted || _feeds.isEmpty) {
      _isCycling = false;
      return;
    }
    setState(() {
      _currentIndex = (_currentIndex + 1) % _feeds.length;
    });
    if (mounted && _feeds.length > 1) {
      Future.delayed(const Duration(seconds: 5), _nextImage);
    } else {
      _isCycling = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_feeds.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentFeed = _feeds[_currentIndex];

    final isLocal = Utils.isLocalFilePath(currentFeed.imageUrl);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: AppDimensions.avatarSm,
              height: AppDimensions.avatarSm,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child:
                    isLocal
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          child: Image.file(
                            File(Utils.getActualFilePath(currentFeed.imageUrl)),
                            fit: BoxFit.cover,
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        )
                        : UserImage(
                          key: ValueKey(currentFeed.id),
                          imageUrl: currentFeed.imageUrl,
                          size: AppDimensions.avatarSm,
                          borderRadius: AppDimensions.radiusMd,
                        ),
              ),
            ),
            const SizedBox(width: AppDimensions.sm),
            Text(
              'Lịch sử',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Transform.rotate(
          angle: -1.55,
          child: const Icon(Icons.arrow_back_ios_sharp, color: Colors.white),
        ),
      ],
    );
  }
}
