import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../constants/opgi_il1_constants.dart';

class Il1MultiSelectField extends StatelessWidget {
  final String label;
  final String placeholder;
  final List<DropdownOption> options;
  final List<String> selectedValues;
  final ValueChanged<List<String>> onChanged;
  final String? errorText;
  final bool isRequired;

  const Il1MultiSelectField({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValues,
    required this.onChanged,
    this.placeholder = 'Pilih jawaban',
    this.errorText,
    this.isRequired = false,
  });

  void _showSelectionDialog(BuildContext context) {
    final tempSelected = List<String>.from(selectedValues);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              contentPadding: const EdgeInsets.only(top: 12),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final opt = options[index];
                    final isChecked = tempSelected.contains(opt.value);
                    return CheckboxListTile(
                      dense: true,
                      title: Text(opt.label, style: const TextStyle(fontSize: 14)),
                      value: isChecked,
                      activeColor: AppColors.primary,
                      onChanged: (bool? checked) {
                        setModalState(() {
                          if (checked == true) {
                            if (!tempSelected.contains(opt.value)) {
                              tempSelected.add(opt.value);
                            }
                          } else {
                            tempSelected.remove(opt.value);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    onChanged(tempSelected);
                  },
                  child: const Text('Pilih'),
                ),
              ],
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
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showSelectionDialog(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey.shade400,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedValues.isEmpty
                      ? Text(placeholder, style: TextStyle(color: Colors.grey.shade500, fontSize: 14))
                      : Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: selectedValues.map((val) {
                            final opt = options.firstWhere(
                              (o) => o.value == val,
                              orElse: () => DropdownOption(label: val, value: val),
                            );
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                opt.label,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}
