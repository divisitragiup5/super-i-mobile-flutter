import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget pilihan multi-select dengan chips, identik dengan DropdownMulti di React Native
class MultiSelectChips extends StatelessWidget {
  final String label;
  final String hint;
  final List<String> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final bool disabled;
  final String? errorText;

  const MultiSelectChips({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.disabled = false,
    this.errorText,
  });

  void _showSelectionModal(BuildContext context) {
    if (disabled) return;

    final tempSelected = List<String>.from(selectedValues);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(modalContext).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: options.map((option) {
                            final isChecked = tempSelected.contains(option);
                            return CheckboxListTile(
                              title: Text(option, style: const TextStyle(fontSize: 14)),
                              value: isChecked,
                              activeColor: AppColors.primary,
                              controlAffinity: ListTileControlAffinity.trailing,
                              onChanged: (checked) {
                                setModalState(() {
                                  if (checked == true) {
                                    if (!tempSelected.contains(option)) {
                                      tempSelected.add(option);
                                    }
                                  } else {
                                    tempSelected.remove(option);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        onChanged(tempSelected);
                        Navigator.of(modalContext).pop();
                      },
                      child: const Text('Terapkan Pilihan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: disabled ? null : () => _showSelectionModal(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: disabled ? const Color(0xFFF8FAFC) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? AppColors.danger : const Color(0xFFD1D5DB),
              ),
            ),
            child: selectedValues.isEmpty
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hint,
                        style: TextStyle(
                          color: disabled ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
                    ],
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...selectedValues.map((val) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                val,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              if (!disabled) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    final updated = List<String>.from(selectedValues)..remove(val);
                                    onChanged(updated);
                                  },
                                  child: const Icon(
                                    Icons.close,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }),
                      if (!disabled)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(Icons.add_circle_outline, size: 18, color: AppColors.primary),
                        ),
                    ],
                  ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.danger, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
