import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Dialog untuk memilih Bulan dan Tahun (misal untuk filter riwayat, shift, atau performa)
class MonthYearPickerDialog extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final int startYear;
  final int endYear;

  const MonthYearPickerDialog({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    this.startYear = 2020,
    this.endYear = 2030,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    int? initialMonth,
    int? initialYear,
  }) async {
    final now = DateTime.now();
    return showDialog<DateTime>(
      context: context,
      builder: (ctx) => MonthYearPickerDialog(
        initialMonth: initialMonth ?? now.month,
        initialYear: initialYear ?? now.year,
      ),
    );
  }

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _selectedMonth;
  late int _selectedYear;

  static const List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final years = List<int>.generate(
      widget.endYear - widget.startYear + 1,
      (index) => widget.startYear + index,
    );

    return AlertDialog(
      title: const Text(
        'Pilih Bulan & Tahun',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown Tahun
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tahun:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  items: years.map((y) {
                    return DropdownMenuItem<int>(
                      value: y,
                      child: Text(
                        y.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedYear = val);
                  },
                ),
              ],
            ),
            const Divider(height: 24),
            // Grid 12 Bulan
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNum = index + 1;
                final isSelected = monthNum == _selectedMonth;
                return InkWell(
                  onTap: () => setState(() => _selectedMonth = monthNum),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      _months[index].substring(0, 3),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context, DateTime(_selectedYear, _selectedMonth, 1));
          },
          child: const Text('Pilih'),
        ),
      ],
    );
  }
}
