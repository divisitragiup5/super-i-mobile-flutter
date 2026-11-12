import 'package:flutter/material.dart';
import '../constants/opgi_il1_constants.dart';

class Il1DropdownField extends StatelessWidget {
  final String label;
  final String placeholder;
  final List<DropdownOption> options;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool isRequired;

  const Il1DropdownField({
    super.key,
    required this.label,
    required this.options,
    String? selectedValue,
    String? value,
    required this.onChanged,
    this.placeholder = 'Pilih jawaban',
    this.errorText,
    this.isRequired = false,
  }) : selectedValue = selectedValue ?? value;

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
        DropdownButtonFormField<String>(
          initialValue: (selectedValue != null && selectedValue!.isNotEmpty && options.any((o) => o.value == selectedValue))
              ? selectedValue
              : null,
          decoration: InputDecoration(
            isDense: true,
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          items: options
              .map(
                (opt) => DropdownMenuItem(
                  value: opt.value,
                  child: Text(opt.label, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ],
      ],
    );
  }
}
