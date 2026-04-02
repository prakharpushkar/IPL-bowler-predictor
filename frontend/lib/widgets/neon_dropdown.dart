import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Searchable dropdown with neon styling, glow-on-focus, and filter capability.
/// Implements a custom overlay-based dropdown for better UX than DropdownButton.
class NeonSearchableDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;

  const NeonSearchableDropdown({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<NeonSearchableDropdown> createState() => _NeonSearchableDropdownState();
}

class _NeonSearchableDropdownState extends State<NeonSearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredItems = [];
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    if (widget.selectedValue != null) {
      _searchController.text = widget.selectedValue!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NeonSearchableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _searchController.text = widget.selectedValue ?? '';
    }
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _openDropdown();
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        _closeDropdown();
      });
    }
  }

  void _openDropdown() {
    if (_isOpen) return;
    _isOpen = true;
    _filteredItems = widget.items;
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    if (!_isOpen) return;
    _isOpen = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _filterItems(String query) {
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    // Rebuild overlay
    _overlayEntry?.remove();
    _overlayEntry = _createOverlay();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _selectItem(String item) {
    _searchController.text = item;
    widget.onChanged(item);
    _focusNode.unfocus();
    _closeDropdown();
  }

  OverlayEntry _createOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 250),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neonBlue.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonBlue.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _filteredItems.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No players found',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = item == widget.selectedValue;
                          return InkWell(
                            onTap: () => _selectItem(item),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.neonBlue.withOpacity(0.1)
                                    : Colors.transparent,
                                border: Border(
                                  bottom: BorderSide(
                                    color: AppColors.textMuted.withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Text(
                                item,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.neonBlue
                                      : AppColors.textPrimary,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _focusNode.hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.neonBlue.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: _searchController,
          focusNode: _focusNode,
          validator: widget.validator,
          onChanged: _filterItems,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: 'Search ${widget.label.toLowerCase()}...',
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _focusNode.hasFocus
                        ? AppColors.neonBlue
                        : AppColors.textMuted,
                    size: 20,
                  )
                : null,
            suffixIcon: Icon(
              _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
