import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/opgi_manuver_model.dart';

class ManuverItemCard extends StatelessWidget {
  final ManuverItemModel item;
  final VoidCallback onView;
  final VoidCallback onDelete;
  final bool isDeleting;
  final bool isAdminSuper;

  const ManuverItemCard({
    super.key,
    required this.item,
    required this.onView,
    required this.onDelete,
    this.isDeleting = false,
    this.isAdminSuper = false,
  });

  String _formatLastProgress() {
    if (item.progres.isEmpty) return '-';
    final p = item.progres.first;
    final isPekerjaan = item.tipeManuver == 'PEKERJAAN';

    final waktuStr = AppTimeUtils.formatLocal(
      p.waktu,
      pattern: 'EEE, dd MMMM yyyy HH:mm',
      fallback: '',
    );

    if (isPekerjaan) {
      final parts = <String>[
        p.objek,
        if (p.operasi != null && p.operasi!.isNotEmpty) p.operasi!,
        if (p.status != null && p.status!.isNotEmpty) p.status!,
        if (waktuStr.isNotEmpty) waktuStr,
      ];
      return parts.join(' - ');
    } else {
      final parts = <String>[
        p.objek,
        if (p.posisi != null && p.posisi!.isNotEmpty) p.posisi!,
        if (p.status != null && p.status!.isNotEmpty) p.status!,
        if (waktuStr.isNotEmpty) waktuStr,
      ];
      return parts.join(' - ');
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text('Apakah Anda yakin ingin menghapus manuver?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isClose = item.isClose;
    final cardColor = isClose ? const Color(0xFFDCFCE7) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.penyulang.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.tipeManuver,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Progress Terakhir: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        _formatLastProgress(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isClose)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade600),
                  ),
                  child: const Text(
                    'SELESAI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Lihat',
                  variant: ButtonVariant.outlined,
                  height: 38,
                  onPressed: onView,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 44,
                height: 38,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (isAdminSuper || !isClose) ? AppColors.danger : Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: (isAdminSuper || !isClose) && !isDeleting ? () => _confirmDelete(context) : null,
                  child: isDeleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.delete, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
