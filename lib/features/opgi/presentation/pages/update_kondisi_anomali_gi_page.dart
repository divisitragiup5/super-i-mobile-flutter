import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_video_player.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_anomali_model.dart';
import '../cubit/opgi_anomali_cubit.dart';

class UpdateKondisiAnomaliGiPage extends StatefulWidget {
  final AnomaliReportModel anomaliData;
  final AnomaliKondisiModel kondisiItem;
  final String garduIndukNama;
  final int garduIndukId;
  final bool isLast;

  const UpdateKondisiAnomaliGiPage({
    super.key,
    required this.anomaliData,
    required this.kondisiItem,
    required this.garduIndukNama,
    required this.garduIndukId,
    this.isLast = true,
  });

  @override
  State<UpdateKondisiAnomaliGiPage> createState() =>
      _UpdateKondisiAnomaliGiPageState();
}

class _UpdateKondisiAnomaliGiPageState
    extends State<UpdateKondisiAnomaliGiPage> {
  final _formKey = GlobalKey<FormState>();

  late String _urgensi;
  late String _tindakan;
  late TextEditingController _keteranganController;

  @override
  void initState() {
    super.initState();
    _urgensi = widget.kondisiItem.urgensi;
    _tindakan = widget.kondisiItem.tindakan;
    _keteranganController =
        TextEditingController(text: widget.kondisiItem.keterangan);
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  void _showImageDialog(String fullUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Gagal memuat foto'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      'urgensi': _urgensi,
      'tindakan': _tindakan,
      'keterangan': _keteranganController.text,
      'timezone': AppTimeUtils.deviceTimezone,
    };

    context.read<OpgiAnomaliCubit>().updateAnomaliKondisi(
          kondisiId: widget.kondisiItem.id,
          data: payload,
        );
  }

  @override
  Widget build(BuildContext context) {
    final anomali = widget.anomaliData;
    final kondisi = widget.kondisiItem;

    final formattedDate = AppTimeUtils.formatDateTime(
      kondisi.createdAt,
      pattern: 'EEEE, d MMMM yyyy HH:mm',
    );

    final fullPhotoUrl = AppUrlUtils.resolveMediaUrl(kondisi.fotoBuktiUrl);
    final fullVideoUrl = AppUrlUtils.resolveMediaUrl(kondisi.videoBuktiUrl);

    // List pilihan tindakan: jika bukan kondisi terakhir, "SELESAI" disaring keluar
    final listTindakan = widget.isLast
        ? const ['TIDAK ADA', 'ON PROGRES', 'SELESAI']
        : const ['TIDAK ADA', 'ON PROGRES'];

    // Pastikan _tindakan terpilih valid dalam listTindakan
    if (!listTindakan.contains(_tindakan)) {
      _tindakan = listTindakan.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Kondisi Anomali'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: BlocListener<OpgiAnomaliCubit, OpgiAnomaliState>(
          listener: (context, state) {
            if (state is OpgiAnomaliSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context, true);
            } else if (state is OpgiAnomaliError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Read-only ANOMALI card
                  InputContainer(
                    label: 'ANOMALI',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputWithLabel(
                          label: 'Jenis Asset',
                          child: Text(anomali.jenisAsset),
                        ),
                        InputWithLabel(
                          label: 'Asset',
                          child: Text(anomali.assetNama),
                        ),
                        InputWithLabel(
                          label: 'Entitas',
                          child: Text(anomali.entitas),
                        ),
                        InputWithLabel(
                          label: 'Operator',
                          child: Text(anomali.namaPetugas ?? '-'),
                        ),
                        InputWithLabel(
                          label: 'Tanggal',
                          child: Text(formattedDate),
                        ),
                        InputWithLabel(
                          label: 'Foto Bukti',
                          child: fullPhotoUrl != null && fullPhotoUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () =>
                                        _showImageDialog(fullPhotoUrl),
                                    child: Image.network(
                                      fullPhotoUrl,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) =>
                                          Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        color: Colors.grey.shade100,
                                        child: const Text(
                                            'Foto tidak dapat dimuat'),
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Foto tidak tersedia',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                        InputWithLabel(
                          label: 'Vidio Bukti',
                          child: fullVideoUrl != null && fullVideoUrl.isNotEmpty
                              ? AppVideoPlayer(
                                  videoUrl: fullVideoUrl,
                                  height: 220,
                                  autoPlay: false,
                                  looping: true,
                                  startMuted: true,
                                )
                              : const Text(
                                  'Vidio tidak ditemukan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // 2. UPDATE Form Card
                  InputContainer(
                    label: 'UPDATE',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Urgensi Dropdown
                        InputWithLabel(
                          label: 'Urgensi',
                          child: DropdownButtonFormField<String>(
                            initialValue: _urgensi,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'BAHAYA', child: Text('BAHAYA')),
                              DropdownMenuItem(
                                  value: 'INVESTIGASI LANJUTAN',
                                  child: Text('INVESTIGASI LANJUTAN')),
                              DropdownMenuItem(
                                  value: 'AMAN', child: Text('AMAN')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _urgensi = val);
                            },
                          ),
                        ),

                        // Tindakan Dropdown
                        InputWithLabel(
                          label: 'Tindakan',
                          child: DropdownButtonFormField<String>(
                            initialValue: _tindakan,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                            items: listTindakan
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _tindakan = val);
                            },
                          ),
                        ),

                        // Keterangan
                        InputWithLabel(
                          label: 'Keterangan',
                          child: TextFormField(
                            controller: _keteranganController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Tulis jawaban / keterangan update',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Keterangan wajib diisi'
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tombol Simpan
                        BlocBuilder<OpgiAnomaliCubit, OpgiAnomaliState>(
                          builder: (context, state) {
                            final isLoading = state is OpgiAnomaliLoading;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: isLoading ? null : _submit,
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
