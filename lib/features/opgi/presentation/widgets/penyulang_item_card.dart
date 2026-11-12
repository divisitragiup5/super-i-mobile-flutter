import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../utils/beban_penyulang_utils.dart';

/// Kartu item Penyulang identik dengan `PenyulangItem` di React Native
class PenyulangItemCard extends StatelessWidget {
  final PenyulangModel item;
  final List<PenyulangMappedPeriod> mappedPeriods;
  final VoidCallback onView;
  final VoidCallback onInput;
  final ValueChanged<PenyulangMappedPeriod>? onPeriodTap;
  final ValueChanged<PenyulangMappedPeriod>? onPeriodLongPress;

  const PenyulangItemCard({
    super.key,
    required this.item,
    required this.mappedPeriods,
    required this.onView,
    required this.onInput,
    this.onPeriodTap,
    this.onPeriodLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = mappedPeriods.isEmpty;
    final bool isDone = mappedPeriods.isNotEmpty && mappedPeriods.every((p) => p.isDone);
    final bool isCbOff = item.statusCB.toUpperCase() == 'OFF';

    final Color statusCbColor = isCbOff ? const Color(0xFFEF4444) : const Color(0xFF22C55E);

    Color cardBg;
    if (isDisabled) {
      cardBg = const Color(0xFFE5E7EB); // gray-200 / 300
    } else if (isDone) {
      cardBg = const Color(0xFFDCFCE7); // green-100
    } else {
      cardBg = Colors.white;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Nama Penyulang + Status CB
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.garduIndukNama,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: statusCbColor, width: 1.2),
                ),
                child: Text(
                  item.statusCB,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusCbColor,
                  ),
                ),
              ),
            ],
          ),

          if (!isDisabled) ...[
            const SizedBox(height: 16),
            // Baris Chip Periode (00..23)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 38,
                child: Row(
                  children: mappedPeriods.map((period) {
                    final bool chipDisabled = period.isDone || isCbOff;
                    final bool isDraftNotDone = period.draft && !period.isDone;
                    final callback = onPeriodTap ?? onPeriodLongPress;

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: chipDisabled ? null : () => callback?.call(period),
                        onLongPress: chipDisabled ? null : () => callback?.call(period),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0.5),
                          decoration: BoxDecoration(
                            color: period.color,
                            border: isDraftNotDone
                                ? Border.all(color: const Color(0xFFEA580C), width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: Text(
                                period.periode.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDraftNotDone
                                      ? const Color(0xFFDC2626)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),
            // Action Buttons: Lihat & Input
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: onView,
                    child: const Text(
                      'Lihat',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isDone || isCbOff)
                          ? Colors.grey.shade400
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: (isDone || isCbOff) ? 0 : 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: (isDone || isCbOff) ? null : onInput,
                    child: const Text(
                      'Input',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
