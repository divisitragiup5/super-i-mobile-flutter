import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Dialog modern untuk memilih Bulan dan Tahun (misal untuk filter riwayat, shift, atau performa)
class MonthYearPickerDialog extends StatefulWidget {
  final int initialMonth; // 1-12
  final int initialYear;
  final int startYear;
  final int endYear;

  const MonthYearPickerDialog({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    this.startYear = 2011,
    this.endYear = 2035,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    int? initialMonth,
    int? initialYear,
    int startYear = 2011,
    int endYear = 2035,
    bool useRootNavigator = true,
  }) async {
    final now = DateTime.now();
    return showDialog<DateTime>(
      context: context,
      useRootNavigator: useRootNavigator,
      barrierDismissible: true,
      builder: (ctx) => MonthYearPickerDialog(
        initialMonth: initialMonth ?? now.month,
        initialYear: initialYear ?? now.year,
        startYear: startYear,
        endYear: endYear,
      ),
    );
  }

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int _selectedMonth;
  late int _selectedYear;

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Ags',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth.clamp(1, 12);
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Dialog
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pilih Bulan & Tahun',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Kontrol Tahun (< 2026 >)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 24),
                    color: _selectedYear > widget.startYear
                        ? AppColors.textPrimary
                        : Colors.grey.shade300,
                    onPressed: _selectedYear > widget.startYear
                        ? () => setState(() => _selectedYear--)
                        : null,
                  ),
                  Text(
                    '$_selectedYear',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 24),
                    color: _selectedYear < widget.endYear
                        ? AppColors.textPrimary
                        : Colors.grey.shade300,
                    onPressed: _selectedYear < widget.endYear
                        ? () => setState(() => _selectedYear++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid 12 Bulan (3 kolom x 4 baris)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.1,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final monthNum = index + 1;
                final isSelected = monthNum == _selectedMonth;
                final isCurrentMonth =
                    monthNum == now.month && _selectedYear == now.year;

                return InkWell(
                  onTap: () => setState(() => _selectedMonth = monthNum),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isCurrentMonth
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isCurrentMonth
                                ? AppColors.primary.withValues(alpha: 0.5)
                                : AppColors.border,
                        width: isSelected || isCurrentMonth ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Text(
                      _shortMonths[index],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : isCurrentMonth
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context,
                        DateTime(_selectedYear, _selectedMonth, 1),
                      );
                    },
                    child: const Text(
                      'Pilih',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
