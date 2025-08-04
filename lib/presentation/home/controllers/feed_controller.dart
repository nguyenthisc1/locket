import 'package:flutter/material.dart';
import 'package:locket/data/feed/respositories/feed_repository_impl.dart';
import 'package:locket/di.dart';
import 'package:locket/domain/feed/entities/feed_entity.dart';
import 'package:locket/domain/feed/usecases/get_feed_usecase.dart';
import 'package:logger/logger.dart';

class FeedControllerState extends ChangeNotifier {
  Logger logger = Logger(
    printer: PrettyPrinter(colors: true, printEmojis: true),
  );

  final FocusNode messageFieldFocusNode = FocusNode();
  bool _isVisibleGallery = true;
  bool _isKeyboardOpen = false;
  int _popImageIndex = 0;
  List<FeedEntity> _listFeed = [];

  List<FeedEntity> get  listFeed => _listFeed;
  bool get isVisibleGallery => _isVisibleGallery;
  bool get isKeyboardOpen => _isKeyboardOpen;
  int get popImageIndex => _popImageIndex;

  FeedControllerState() {
    messageFieldFocusNode.addListener(_handleKeyboardFocus);
  }

  Future<void> fetchFeed(Map<String, dynamic> query) async {
    try {
      final feedRepository = getIt<FeedRepositoryImpl>();
      final getFeedUseCase = GetFeedUsecase(feedRepository);

      final result = await getFeedUseCase(query);

      result.fold(
        (failure) {
          logger.e('Failed to fetch Feed: ${failure.message}');
        },
        (response) {
          logger.d('Feed fetched successfully');
          
          final feeds = response.data['feeds'] as List<FeedEntity>;

          _listFeed = [...feeds];
        },
      );
    } catch (e) {
      logger.e('Error fetching profile: $e');
    }
  }

  void _handleKeyboardFocus() {
    final isOpen = messageFieldFocusNode.hasFocus;
    if (isOpen != _isKeyboardOpen) {
      _isKeyboardOpen = isOpen;
      notifyListeners();
    }
  }

  void toggleGalleryVisibility() {
    _isVisibleGallery = !_isVisibleGallery;
    notifyListeners();
  }

  set setPopImageIndex(int? value) {
    if (value != null && value != _popImageIndex) {
      _popImageIndex = value;
      // print(_popImageIndex);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    messageFieldFocusNode.removeListener(_handleKeyboardFocus);
    messageFieldFocusNode.dispose();
    super.dispose();
  }
}
