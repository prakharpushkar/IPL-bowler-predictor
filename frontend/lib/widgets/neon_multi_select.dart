import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Multi-select searchable dropdown for candidate bowlers.
/// Shows selected items as neon chips below the search field.
class NeonMultiSelectDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final int minSelect;
  final int maxSelect;
  final String? Function(List<String>)? validator;
  final IconData? prefixIcon;

  const NeonMultiSelectDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    this.minSelect = 2,
    this.maxSelect = 5,
    this.validator,
    this.prefixIcon,
  });

  @override
  State<NeonMultiSelectDropdown> createState() =>
      _NeonMultiSelectDropdownState();
}

class _NeonMultiSelectDropdownState extends State<NeonMultiSelectDropdown> {
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
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NeonMultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _openDropdown();
    } else {
      Future.delayed(const Duration(milliseconds: 200), _closeDropdown);
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

  void _rebuildOverlay() {
    _overlayEntry?.remove();
    if (_isOpen) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _filterItems(String query) {
    _filteredItems = widget.items
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _rebuildOverlay();
  }

  void _toggleItem(String item) {
    final newList = List<String>.from(widget.selectedValues);
    if (newList.contains(item)) {
      newList.remove(item);
    } else if (newList.length < widget.maxSelect) {
      newList.add(item);
    }
    widget.onChanged(newList);
    _rebuildOverlay();
  }

  void _removeItem(String item) {
    final newList = List<String>.from(widget.selectedValues)..remove(item);
    widget.onChanged(newList);
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
                  color: AppColors.neonViolet.withOpacity(0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonViolet.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selection counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.textMuted.withOpacity(0.15),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${widget.selectedValues.length}/${widget.maxSelect} selected',
                          style: TextStyle(
                            color: widget.selectedValues.length >=
                                    widget.minSelect
                                ? AppColors.neonGreen
                                : AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Min: ${widget.minSelect}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Items list
                  Flexible(
                    child: _filteredItems.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No bowlers found',
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
                              final isSelected =
                                  widget.selectedValues.contains(item);
                              final isDisabled = !isSelected &&
                                  widget.selectedValues.length >=
                                      widget.maxSelect;

                              return InkWell(
                                onTap:
                                    isDisabled ? null : () => _toggleItem(item),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.neonViolet.withOpacity(0.1)
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.neonViolet
                                                : isDisabled
                                                    ? AppColors.textMuted
                                                        .withOpacity(0.3)
                                                    : AppColors.textMuted,
                                          ),
                                          color: isSelected
                                              ? AppColors.neonViolet
                                                  .withOpacity(0.2)
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                size: 14,
                                                color: AppColors.neonViolet,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        item,
                                        style: TextStyle(
                                          color: isDisabled
                                              ? AppColors.textMuted
                                                  .withOpacity(0.4)
                                              : isSelected
                                                  ? AppColors.neonViolet
                                                  : AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
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
    final validationError = widget.validator?.call(widget.selectedValues);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: _focusNode.hasFocus
                  ? [
                      BoxShadow(
                        color: AppColors.neonViolet.withOpacity(0.15),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _filterItems,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'Search bowlers...',
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _focusNode.hasFocus
                            ? AppColors.neonViolet
                            : AppColors.textMuted,
                        size: 20,
                      )
                    : null,
                suffixIcon: Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: AppColors.textMuted,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.neonViolet, width: 2),
                ),
                floatingLabelStyle:
                    const TextStyle(color: AppColors.neonViolet),
                errorText: validationError,
              ),
            ),
          ),

          // Selected chips
          if (widget.selectedValues.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedValues.map((name) {
                final colorIndex =
                    widget.selectedValues.indexOf(name) % AppColors.chartPalette.length;
                final chipColor = AppColors.chartPalette[colorIndex];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Chip(
                    label: Text(
                      name,
                      style: TextStyle(
                        color: chipColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    deleteIcon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: chipColor,
                    ),
                    onDeleted: () => _removeItem(name),
                    backgroundColor: chipColor.withOpacity(0.1),
                    side: BorderSide(color: chipColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
