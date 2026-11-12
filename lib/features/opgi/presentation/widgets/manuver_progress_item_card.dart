import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_manuver_model.dart';

class ManuverProgressItemCard extends StatelessWidget {
  final ManuverProgressModel item;
  final bool isManuverClose;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final bool isDeleting;
  final bool isAdminSuper;

  const ManuverProgressItemCard({
    super.key,
    required this.item,
    required this.isManuverClose,
    required this.onUpdate,
    required this.onDelete,
    this.isDeleting = false,
    this.isAdminSuper = false,
  });

  String _formatDateTime(String? raw) {
    return AppTimeUtils.formatLocal(raw, pattern: 'dd MMMM yyyy HH:mm');
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text('Apakah Anda yakin ingin menghapus progress manuver?'),
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

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Text('Gagal memuat gambar'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = item.isDisabled;
    final isItemClose = item.isClose;
    final canUpdate = isAdminSuper || (!isManuverClose && !isDisabled);
    final canDelete = isAdminSuper || !isManuverClose;

    Color cardBg = Colors.white;
    if (isDisabled) {
      cardBg = const Color(0xFFE2E8F0);
    } else if (isItemClose) {
      cardBg = const Color(0xFFDCFCE7);
    }

    final imageUrl = AppUrlUtils.getFullImageUrl(item.dokumentasi?.uri);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputContainer(
            label: _formatDateTime(item.waktu),
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputWithLabel(
                  label: 'Objek',
                  child: Text(
                    item.objek,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                ),
                if (item.posisi != null && item.posisi!.isNotEmpty)
                  InputWithLabel(
                    label: 'Posisi',
                    child: Text(
                      item.posisi!,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                    ),
                  ),
                if (item.operasi != null && item.operasi!.isNotEmpty)
                  InputWithLabel(
                    label: 'Operasi',
                    child: Text(
                      item.operasi!,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                    ),
                  ),
                if (item.status != null && item.status!.isNotEmpty)
                  InputWithLabel(
                    label: 'Status',
                    child: Text(
                      item.status!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                  ),
                if (item.jenisGangguan.isNotEmpty)
                  InputWithLabel(
                    label: 'Jenis Gangguan',
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: item.jenisGangguan.map((jg) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Text(
                            jg,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (item.keteranganPekerjaan != null && item.keteranganPekerjaan!.isNotEmpty)
                  InputWithLabel(
                    label: 'Keterangan Pekerjaan',
                    child: Text(
                      item.keteranganPekerjaan!,
                      style: const TextStyle(color: Color(0xFF334155)),
                    ),
                  ),
                if (item.arus.isNotEmpty)
                  InputWithLabel(
                    label: 'Arus',
                    child: Column(
                      children: item.arus.map((arus) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Type', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  Text(arus.type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Value', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  Text('${arus.value ?? "-"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Satuan', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                                  Text(arus.satuan, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                if (item.operator?.namaLengkap != null && item.operator!.namaLengkap!.isNotEmpty)
                  InputWithLabel(
                    label: 'Operator',
                    child: Text(
                      item.operator!.namaLengkap!,
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                    ),
                  ),
                if (imageUrl.isNotEmpty)
                  InputWithLabel(
                    label: 'Dokumentasi',
                    child: GestureDetector(
                      onTap: () => _showImagePreview(context, imageUrl),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('Gagal memuat foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.fullscreen, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Perbesar', style: TextStyle(color: Colors.white, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Update',
                    variant: ButtonVariant.outlined,
                    height: 38,
                    onPressed: canUpdate ? onUpdate : null,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 44,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canDelete ? AppColors.danger : Colors.grey.shade300,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: canDelete && !isDeleting ? () => _confirmDelete(context) : null,
                    child: isDeleting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.delete, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
