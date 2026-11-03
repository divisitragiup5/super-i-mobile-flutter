import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../data/models/riwayat_absen_model.dart';
import '../cubit/riwayat_absen_cubit.dart';
import '../cubit/riwayat_absen_state.dart';

class RiwayatAbsenUpdatePage extends StatefulWidget {
  final RiwayatAbsenItemModel item;

  const RiwayatAbsenUpdatePage({super.key, required this.item});

  @override
  State<RiwayatAbsenUpdatePage> createState() => _RiwayatAbsenUpdatePageState();
}

class _RiwayatAbsenUpdatePageState extends State<RiwayatAbsenUpdatePage> {
  File? _selectedFile;

  String _formatShiftTime(int? jam, int? menit) {
    if (jam == null && menit == null) return '--:--';
    final h = (jam ?? 0).toString().padLeft(2, '0');
    final m = (menit ?? 0).toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatDate(String? dateStr, String pattern) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat(pattern, 'id_ID').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<UploadDokumenCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unggah Dokumen Absensi'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.backgroundLight,
                ),
              ),
            ),
            BlocConsumer<UploadDokumenCubit, UploadDokumenState>(
              listener: (context, state) {
                if (state is UploadDokumenSuccess) {
                  AppSnackbar.showSuccess(context, state.message);
                  Navigator.pop(context, true);
                } else if (state is UploadDokumenError) {
                  AppSnackbar.showError(context, state.message);
                }
              },
              builder: (context, state) {
                final isLoading = state is UploadDokumenLoading;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INFORMASI ABSENSI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              'Tanggal',
                              _formatDate(widget.item.createdAt, 'dd MMMM yyyy'),
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(
                              'Keterangan',
                              widget.item.keterangan ?? '-',
                            ),
                            const Divider(height: 20),
                            _buildInfoRow(
                              'Shift',
                              '${_formatShiftTime(widget.item.jamMasuk, widget.item.menitMasuk)} - ${_formatShiftTime(widget.item.jamKeluar, widget.item.menitKeluar)}',
                            ),
                            const Divider(height: 20),
                            const Text(
                              'Petugas Yang Menggantikan:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (widget.item.digantikan.isEmpty)
                              const Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            else
                              ...widget.item.digantikan.map(
                                (d) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '• ${d.namaPetugas ?? 'Petugas'} (${_formatShiftTime(d.startHour, d.startMinute)} - ${_formatShiftTime(d.endHour, d.endMinute)})',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Document upload card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'UNGGAH DOKUMEN BUKTI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Silakan ambil atau pilih foto surat keterangan dokter / izin resmi.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            FieldPictInput(
                              label: 'Foto Dokumen',
                              placeholder: 'Pilih atau ambil foto dokumen',
                              isRequired: true,
                              pictureFile: _selectedFile,
                              onChange: (file) {
                                setState(() {
                                  _selectedFile = file;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      AppButton(
                        text: 'Simpan Dokumen',
                        isLoading: isLoading,
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_selectedFile == null) {
                                  AppSnackbar.showError(
                                    context,
                                    'Harap pilih foto dokumen terlebih dahulu',
                                  );
                                  return;
                                }

                                context.read<UploadDokumenCubit>().uploadDokumen(
                                      riwayatId: widget.item.id,
                                      file: _selectedFile!,
                                    );
                              },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
