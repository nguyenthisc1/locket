import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/core/configs/theme/index.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class MessageField extends StatefulWidget {
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<String>? onChanged;
  final void Function(String? text, List<AssetEntity> photos)? onSubmitted;
  final bool? isShowPickImagesGalleryIcon;
  final bool? isShowGallery;
  final bool? isVisibleBackdrop;
  final void Function()? onPickimagesGallery;
  final ValueChanged<bool>? onGalleryStateChanged;

  const MessageField({
    super.key,
    this.padding = const EdgeInsets.only(
      left: AppDimensions.md,
      right: AppDimensions.md,
      top: AppDimensions.lg,
      bottom: AppDimensions.lg,
    ),
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onPickimagesGallery,
    this.isVisibleBackdrop = false,
    this.isShowPickImagesGalleryIcon = false,
    this.isShowGallery = false,
    this.onGalleryStateChanged,
  });

  @override
  State<MessageField> createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField>
    with TickerProviderStateMixin {
  FocusNode? _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode!;
  final TextEditingController _textController = TextEditingController();

  bool isShowGallery = false;
  List<AssetEntity> photos = [];
  late ValueNotifier<List<AssetEntity>> _selectedPhotosNotifier;

  bool isKeyboardVisible = false;

  late AnimationController _animationController;
  late AnimationController _showMessageFieldGalleryController;

  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideTransition;

  @override
  void initState() {
    super.initState();
    _selectedPhotosNotifier = ValueNotifier<List<AssetEntity>>([]);

    // Only create and manage internal focus node if widget.focusNode is null
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      _internalFocusNode!.addListener(_handleFocusChange);
    } else {
      widget.focusNode!.addListener(_handleFocusChange);
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _showMessageFieldGalleryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // By default, the message field (in gallery) should be hidden
    _showMessageFieldGalleryController.value = 1.0;

    _slideTransition = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 1),
    ).animate(
      CurvedAnimation(
        parent: _showMessageFieldGalleryController,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _internalFocusNode?.removeListener(_handleFocusChange);
      _internalFocusNode?.dispose();
    } else {
      widget.focusNode?.removeListener(_handleFocusChange);
      // Do not dispose external focusNode
    }

    _textController.dispose();
    _animationController.dispose();
    _showMessageFieldGalleryController.dispose();
    _selectedPhotosNotifier.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      isKeyboardVisible = _effectiveFocusNode.hasFocus;
      if (isKeyboardVisible) {
        // Save current keyboard height if visible
        final kbHeight = MediaQuery.of(context).viewInsets.bottom;
        if (kbHeight > 0) {
          // _keyboardHeight = kbHeight;
        }
      }
    });

    if (_effectiveFocusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _unfocus() {
    if (_effectiveFocusNode.hasFocus) {
      _effectiveFocusNode.unfocus();
    }
  }

  void _handleSubmit() {
    final text = _textController.text.trim();

    widget.onSubmitted?.call(text, photos);
    _textController.clear();
    _selectedPhotosNotifier.value = [];
  }

  void _handleToggleSelect(AssetEntity photo) {
    final currentSelectedPhotos = List<AssetEntity>.of(
      _selectedPhotosNotifier.value,
    );
    if (currentSelectedPhotos.contains(photo)) {
      currentSelectedPhotos.remove(photo);
    } else {
      currentSelectedPhotos.add(photo);
    }

    // If there are more than 1 selected photo, show message field.
    // If 1 or fewer, hide it.
    if (currentSelectedPhotos.isNotEmpty) {
      _showMessageFieldGalleryController.reverse();
    } else {
      _showMessageFieldGalleryController.forward();
    }

    _selectedPhotosNotifier.value = currentSelectedPhotos;
  }

  void _showGalleryBottomSheet(BuildContext context) {
    if (!mounted) return;

    _showMessageFieldGalleryController.value = 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      enableDrag: false,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          snap: true,
          snapSizes: [0.5, 0.9],
          builder: (context, scrollController) {
            if (photos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return ValueListenableBuilder<List<AssetEntity>>(
              valueListenable: _selectedPhotosNotifier,
              builder: (context, selectedPhotos, _) {
                return Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(
                              left: AppDimensions.sm,
                              right: AppDimensions.sm,
                              bottom: 80,
                            ),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 2,
                                ),
                            itemCount: photos.length,
                            itemBuilder: (context, index) {
                              final photo = photos[index];
                              final isSelected = selectedPhotos.contains(photo);
                              final order =
                                  isSelected
                                      ? selectedPhotos.indexOf(photo) + 1
                                      : null;
                              return GestureDetector(
                                onTap: () async {
                                  _handleToggleSelect(photo);
                                  final file = await photo.file;
                                  if (file != null) {
                                    // print('Selected image: ${file.path}');
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: Image(
                                          image: AssetEntityImageProvider(
                                            photo,
                                            isOriginal: false,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                            ),
                                            child: Center(
                                              child: Container(
                                                width: 48,
                                                height: 48,
                                                decoration: const BoxDecoration(
                                                  color: AppColors.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  order.toString(),
                                                  style: AppTypography
                                                      .headlineLarge
                                                      .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,

                      child: SlideTransition(
                        position: _slideTransition,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.white),
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm,
                            vertical: AppDimensions.sm,
                          ),
                          child: Row(
                            spacing: AppDimensions.md,
                            children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    if (selectedPhotos.isNotEmpty) ...[
                                      if (selectedPhotos.length > 2)
                                        Positioned(
                                          child: Transform(
                                            alignment: Alignment.center,
                                            transform:
                                                Matrix4.identity()
                                                  ..translate(8.0, 0.0)
                                                  ..rotateZ(
                                                    12 *
                                                        3.141592653589793 /
                                                        180,
                                                  )
                                                  ..scale(
                                                    0.6,
                                                  ), // -30 degrees in radians

                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDimensions.radiusMd,
                                                    ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDimensions.radiusMd,
                                                    ),
                                                child: Image(
                                                  width: 48,
                                                  height: 48,
                                                  image:
                                                      AssetEntityImageProvider(
                                                        selectedPhotos[2],
                                                        isOriginal: false,
                                                      ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (selectedPhotos.length > 1)
                                        Positioned(
                                          child: Transform(
                                            alignment: Alignment.center,
                                            transform:
                                                Matrix4.identity()
                                                  ..translate(-8.0, 0.0)
                                                  ..rotateZ(
                                                    -12 *
                                                        3.141592653589793 /
                                                        180,
                                                  )
                                                  ..scale(
                                                    0.6,
                                                  ), // -30 degrees in radians

                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDimensions.radiusMd,
                                                    ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppDimensions.radiusMd,
                                                    ),
                                                child: Image(
                                                  width: 48,
                                                  height: 48,
                                                  image:
                                                      AssetEntityImageProvider(
                                                        selectedPhotos[1],
                                                        isOriginal: false,
                                                      ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Transform(
                                        alignment: Alignment.center,
                                        transform:
                                            Matrix4.identity()..scale(
                                              selectedPhotos.length > 1
                                                  ? 0.7
                                                  : 1.0,
                                            ),

                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusMd,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              AppDimensions.radiusMd,
                                            ),
                                            child: Image(
                                              width: 48,
                                              height: 48,
                                              image: AssetEntityImageProvider(
                                                selectedPhotos.first,
                                                isOriginal: false,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (selectedPhotos.length > 3)
                                        Positioned(
                                          right: 0,
                                          top: 0,
                                          child: Container(
                                            width: 20,
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: Center(
                                              child: Text(
                                                selectedPhotos.length
                                                    .toString(),
                                                style: AppTypography.bodyLarge
                                                    .copyWith(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),

                              Flexible(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusXl,
                                  ),
                                  child: TextField(
                                    controller: _textController,
                                    focusNode: _effectiveFocusNode,
                                    onChanged: widget.onChanged,
                                    onSubmitted: (_) => _handleSubmit(),
                                    decoration: InputDecoration(
                                      hintText: 'Gửi tin nhắn...',
                                      filled: true,
                                      hintStyle: TextStyle(color: Colors.black),
                                      fillColor: AppColors.background,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusXxl,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(
                                          Icons.send,
                                          color: Colors.black,
                                        ),
                                        onPressed: _handleSubmit,
                                      ),
                                    ),
                                    style: AppTypography.headlineMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    ).whenComplete(() {
      _selectedPhotosNotifier.value = [];
      _showMessageFieldGalleryController.value = 1.0;
    });
  }

  Future<void> _loadPhotos() async {
    final permission = await PhotoManager.requestPermissionExtend();
    if (!permission.isAuth) return;

    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    final result = await albums.first.getAssetListPaged(page: 0, size: 100);
    setState(() => photos = result);
  }

  void _handleShowGallery() async {
    _unfocus();
    await _loadPhotos();
    // Instead of setState after showModalBottomSheet, use isShowGallery locally.
    // Invoke the callback only if necessary.
    isShowGallery = !isShowGallery;
    if (widget.onGalleryStateChanged != null) {
      widget.onGalleryStateChanged!.call(isShowGallery);
    }
    // We open the gallery after toggling state.
    _showGalleryBottomSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding =
        widget.padding ??
        const EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          top: AppDimensions.md,
          bottom: AppDimensions.md,
        );

    final keyboardH = MediaQuery.of(context).viewInsets.bottom;
    // If keyboard is shown, update the rememberd keyboard height
    if (keyboardH > 0 && isKeyboardVisible) {
      // _keyboardHeight = keyboardH;
    }

    return Stack(
      children: [
        // Fullscreen GestureDetector to close keyboard when tapping outside
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !isKeyboardVisible,
            child: GestureDetector(
              onTap: _unfocus,
              behavior: HitTestBehavior.translucent,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  color:
                      widget.isVisibleBackdrop!
                          ? Colors.transparent
                          : Colors.black.safeOpacity(0.8),
                ),
              ),
            ),
          ),
        ),
        // The message field with backdrop blur
        Padding(
          padding: effectivePadding,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              spacing: AppDimensions.md,
              children: [
                if (widget.isShowPickImagesGalleryIcon ?? false)
                  IconButton(
                    onPressed: _handleShowGallery,
                    icon: Icon(
                      Icons.image,
                      size: AppDimensions.iconLg,
                      color: Colors.white,
                    ),
                  ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXl),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: TextField(
                        controller: _textController,
                        focusNode: _effectiveFocusNode,
                        onChanged: widget.onChanged,
                        onSubmitted: (_) => _handleSubmit(),
                        decoration: InputDecoration(
                          hintText: 'Gửi tin nhắn...',
                          filled: true,
                          hintStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white.safeOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusXxl,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _handleSubmit,
                          ),
                        ),
                        style: AppTypography.headlineMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
