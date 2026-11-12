import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../utils/beban_trafo_utils.dart';

/// Kartu item Beban Trafo identik dengan `TrafoItem` di React Native
class TrafoItemCard extends StatelessWidget {
  final BebanTrafoModel item;
  final List<TrafoMappedPeriod> mappedPeriods;
  final VoidCallback onView;
  final VoidCallback onInput;
  final ValueChanged<TrafoMappedPeriod>? onPeriodTap;
  final ValueChanged<TrafoMappedPeriod>? onPeriodLongPress;

  const TrafoItemCard({
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
          // Header: Nama Trafo + iMax badge
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
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                ),
                child: Text(
                  'iMax: ${item.iMax.toStringAsFixed(item.iMax.truncateToDouble() == item.iMax ? 0 : 1)} A',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                    final bool chipDisabled = period.isDone;
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
            // Tombol Aksi: Lihat & Input
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onView,
                    child: const Text(
                      'Lihat',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
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
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      disabledForegroundColor: const Color(0xFF94A3B8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isDone ? null : onInput,
                    child: const Text(
                      'Input',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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
