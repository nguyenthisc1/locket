// reusable_dropdown.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:locket/common/helper/utils.dart';
import 'package:locket/common/wigets/pressed_button.dart';
import 'package:locket/core/configs/theme/index.dart';

class CustomDropdown extends StatefulWidget {
  final String initialLabel;
  final List<Map<String, String>> items; // Each item: {label, value, avatarUrl}
  final void Function(String) onChanged;
  final Widget Function(
    int index,
    Map<String, String> item,
    String selectedValue,
  )
  dropdownChildBuilder;

  const CustomDropdown({
    super.key,
    required this.initialLabel,
    required this.items,
    required this.onChanged,
    required this.dropdownChildBuilder,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown>
    with SingleTickerProviderStateMixin {
  final GlobalKey _buttonKey = GlobalKey();
  late String _selectedValue;
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _arrowController;

  @override
  void initState() {
    super.initState();
    // Find initial value from label, fallback to first item's value
    final initialItem = widget.items.firstWhere(
      (item) => item['label'] == widget.initialLabel,
      orElse:
          () =>
              widget.items.isNotEmpty
                  ? widget.items.first
                  : {'label': '', 'value': '', 'avatarUrl': ''},
    );
    _selectedValue = initialItem['value'] ?? initialItem['label'] ?? '';
    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _arrowController.forward();
    final overlay = Overlay.of(context);
    _overlayEntry = _buildOverlay();
    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _arrowController.reverse();
    _dropdownCloseCallback?.call(); // Trigger dropdown animation close
  }

  // Store the close callback
  VoidCallback? _dropdownCloseCallback;

  OverlayEntry _buildOverlay() {
    final renderBox =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth * 0.8;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Backdrop to detect taps outside
            GestureDetector(
              onTap: _closeDropdown,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
            Positioned(
              top: offset.dy + size.height,
              left: (screenWidth - width) / 2,
              width: width,
              child: Material(
                color: Colors.transparent,
                child: _DropdownItemsMenu(
                  items: widget.items,
                  selectedValue: _selectedValue,
                  onSelect: (value) {
                    widget.onChanged(value);
                    setState(() => _selectedValue = value);
                    _closeDropdown();
                  },
                  dropdownChildBuilder: widget.dropdownChildBuilder,
                  onDismissed: () {
                    _overlayEntry?.remove();
                    _overlayEntry = null;
                    _dropdownCloseCallback = null;
                    setState(() => _isOpen = false);
                  },
                  registerClose: (callback) {
                    _dropdownCloseCallback = callback;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Find the label for the selected value
    String displayLabel = widget.initialLabel;
    final selectedItem = widget.items.firstWhere(
      (item) => item['value'] == _selectedValue,
      orElse: () => {},
    );
    if (selectedItem.isNotEmpty && selectedItem['label'] != null) {
      displayLabel = selectedItem['label']!;
    }

    return PressedButton(
      key: _buttonKey,
      onPressed: _toggleDropdown,
      backgroundColor: Colors.white.safeOpacity(0.2),
      foregroundColor: Colors.white70,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              displayLabel,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _arrowController,
            builder:
                (_, child) => Transform.rotate(
                  angle: _arrowController.value * 3.14, // 180 deg
                  child: child,
                ),
            child: const Icon(
              Icons.keyboard_arrow_down,
              size: AppDimensions.iconMd,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownItemsMenu extends StatefulWidget {
  final List<Map<String, String>> items;
  final String selectedValue;
  final void Function(String) onSelect;
  final Widget Function(
    int index,
    Map<String, String> item,
    String selectedValue,
  )
  dropdownChildBuilder;
  final VoidCallback onDismissed;
  final void Function(VoidCallback close) registerClose;

  const _DropdownItemsMenu({
    required this.items,
    required this.selectedValue,
    required this.onSelect,
    required this.dropdownChildBuilder,
    required this.onDismissed,
    required this.registerClose,
  });

  @override
  State<_DropdownItemsMenu> createState() => _DropdownItemsMenuState();
}

class _DropdownItemsMenuState extends State<_DropdownItemsMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offset;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Register close method to parent
    widget.registerClose(_reverseAndClose);
  }

  Future<void> _reverseAndClose() async {
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(String value) {
    widget.onSelect(value);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.safeOpacity(0.9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  widget.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final value = item['value'] ?? item['label'] ?? '';
                    return InkWell(
                      onTap: () => _select(value),
                      child: widget.dropdownChildBuilder(
                        index,
                        item,
                        widget.selectedValue,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
