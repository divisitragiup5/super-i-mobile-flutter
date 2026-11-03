import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DropdownItem<T> {
  final T value;
  final String label;
  final String? subtitle;

  const DropdownItem({
    required this.value,
    required this.label,
    this.subtitle,
  });
}

/// Dropdown dengan modal pencarian untuk daftar pilihan yang banyak (Gardu, Feeder, Tower)
class SearchableDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool isRequired;
  final String? errorText;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
    this.isRequired = false,
    this.errorText,
  });

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalCtx) {
        return _SearchModalContent<T>(
          title: label,
          items: items,
          selectedValue: value,
        );
      },
    ).then((selected) {
      if (selected != null) {
        onChanged(selected);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedItem =
        items.where((it) => it.value == value).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showSearchModal(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: errorText != null
                    ? AppColors.danger
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem?.label ?? hint,
                    style: TextStyle(
                      fontSize: 14,
                      color: selectedItem != null
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                      fontWeight: selectedItem != null
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.danger, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

class _SearchModalContent<T> extends StatefulWidget {
  final String title;
  final List<DropdownItem<T>> items;
  final T? selectedValue;

  const _SearchModalContent({
    required this.title,
    required this.items,
    this.selectedValue,
  });

  @override
  State<_SearchModalContent<T>> createState() => _SearchModalContentState<T>();
}

class _SearchModalContentState<T> extends State<_SearchModalContent<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<DropdownItem<T>> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((it) {
          final matchLabel = it.label.toLowerCase().contains(query);
          final matchSubtitle =
              it.subtitle?.toLowerCase().contains(query) ?? false;
          return matchLabel || matchSubtitle;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            children: [
              // Indicator handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pilih ${widget.title}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Search input
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari ${widget.title.toLowerCase()}...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // List items
              Expanded(
                child: _filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada data ditemukan',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: _filteredItems.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final isSelected = item.value == widget.selectedValue;

                          return ListTile(
                            title: Text(
                              item.label,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: item.subtitle != null
                                ? Text(item.subtitle!)
                                : null,
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.pop(context, item.value),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
