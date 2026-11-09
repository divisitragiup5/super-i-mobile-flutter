import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/role_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../cubit/kegiatan_sosial_cubit.dart';
import '../widgets/history_detail_widgets.dart';

class UpdateKegiatanSosialPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const UpdateKegiatanSosialPage({
    super.key,
    required this.item,
  });

  @override
  State<UpdateKegiatanSosialPage> createState() => _UpdateKegiatanSosialPageState();
}

class _UpdateKegiatanSosialPageState extends State<UpdateKegiatanSosialPage> {
  File? _ttdTLGI;
  final TextEditingController _namaTTDTLGICtrl = TextEditingController();

  File? _ttdLineWalker;
  final TextEditingController _namaTTDLineWalkerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final roles = authState.user.roles;
      if (roles.contains(AppRoles.teamLeaderGi)) {
        _namaTTDTLGICtrl.text = authState.user.namaLengkap;
      }
      if (roles.contains(AppRoles.petugasLineWalker) || roles.contains(AppRoles.koordinatorLineWalker)) {
        _namaTTDLineWalkerCtrl.text = authState.user.namaLengkap;
      }
    }

    if (widget.item['namaTTDTLGI'] != null && widget.item['namaTTDTLGI'].toString().isNotEmpty) {
      _namaTTDTLGICtrl.text = widget.item['namaTTDTLGI'].toString();
    }
    if (widget.item['namaTTDLineWalker'] != null && widget.item['namaTTDLineWalker'].toString().isNotEmpty) {
      _namaTTDLineWalkerCtrl.text = widget.item['namaTTDLineWalker'].toString();
    }
  }

  @override
  void dispose() {
    _namaTTDTLGICtrl.dispose();
    _namaTTDLineWalkerCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final int id = widget.item['id'] is int
        ? widget.item['id']
        : int.tryParse('${widget.item['id']}') ?? 0;

    final isTtdLWFilled = _ttdLineWalker != null;
    final isNamaLWFilled = _namaTTDLineWalkerCtrl.text.trim().isNotEmpty;

    if (isTtdLWFilled && !isNamaLWFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama TTD Line Walker wajib diisi')),
      );
      return;
    }
    if (!isTtdLWFilled && isNamaLWFilled && (widget.item['ttdLineWalker'] == null || widget.item['ttdLineWalker'].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TTD Line Walker wajib diisi')),
      );
      return;
    }

    final isTtdTLGIFilled = _ttdTLGI != null;
    final isNamaTLGIFilled = _namaTTDTLGICtrl.text.trim().isNotEmpty;

    if (isTtdTLGIFilled && !isNamaTLGIFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama TTD Team Leader GI wajib diisi')),
      );
      return;
    }
    if (!isTtdTLGIFilled && isNamaTLGIFilled && (widget.item['ttdTLGI'] == null || widget.item['ttdTLGI'].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('TTD Team Leader GI wajib diisi')),
      );
      return;
    }

    if (!isTtdLWFilled && !isTtdTLGIFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi tanda tangan terlebih dahulu')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah anda yakin ingin menyimpan data kegiatan sosial ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<KegiatanSosialCubit>().updateKegiatanSosial(
                id: id,
                ttdTLGI: _ttdTLGI,
                namaTTDTLGI: isNamaTLGIFilled ? _namaTTDTLGICtrl.text.trim() : null,
                ttdLineWalker: _ttdLineWalker,
                namaTTDLineWalker: isNamaLWFilled ? _namaTTDLineWalkerCtrl.text.trim() : null,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tower = widget.item['tower'];
    final towerName = (tower is Map ? tower['nama'] : null) ?? widget.item['namaTower'] ?? '-';
    final jenisAktivitas = widget.item['jenisAktivitas']?.toString() ?? '-';
    final statusAktivitas = widget.item['statusAktivitas']?.toString() ?? '-';
    final progresPenanganan = widget.item['progresPenanganan']?.toString() ?? '-';
    final kategoriAktivitas = widget.item['kategoriAktivitas']?.toString() ?? '-';
    final tindakan = widget.item['tindakan']?.toString() ?? '-';
    final statusObjek = widget.item['statusObjek']?.toString() ?? '-';
    final keterangan = widget.item['keterangan']?.toString() ?? '-';
    final temuan = widget.item['temuan']?.toString() ?? '-';
    final jumlahTemuan = widget.item['jumlahTemuan']?.toString() ?? '0';
    final tanggapan = widget.item['tanggapan']?.toString() ?? '-';
    final lokasi = widget.item['lokasi']?.toString() ?? '-';

    final dokSosObj = widget.item['dokumentasiSosialisasi'];
    String? dokSosUri;
    if (dokSosObj is Map) {
      dokSosUri = dokSosObj['uri']?.toString();
    } else if (dokSosObj != null) {
      dokSosUri = dokSosObj.toString();
    }

    final hasExistingTtdLineWalker = widget.item['ttdLineWalker'] != null &&
        widget.item['ttdLineWalker'].toString().isNotEmpty &&
        widget.item['namaTTDLineWalker'] != null &&
        widget.item['namaTTDLineWalker'].toString().isNotEmpty;

    final hasExistingTtdTLGI = widget.item['ttdTLGI'] != null &&
        widget.item['ttdTLGI'].toString().isNotEmpty &&
        widget.item['namaTTDTLGI'] != null &&
        widget.item['namaTTDTLGI'].toString().isNotEmpty;

    final allSigned = hasExistingTtdLineWalker && hasExistingTtdTLGI;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Kegiatan Sosial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: BlocConsumer<KegiatanSosialCubit, KegiatanSosialState>(
          listener: (context, state) {
            if (state is KegiatanSosialSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
              context.pop(true);
            } else if (state is KegiatanSosialSubmitFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is KegiatanSosialSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HistoryInputContainer(
                    label: 'INFORMASI KEGIATAN SOSIAL',
                    children: [
                      HistoryInputWithLabel(
                        label: 'Objek',
                        isFirst: true,
                        child: Text(towerName, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Jenis Aktivitas',
                        child: Text(jenisAktivitas, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Status Aktivitas',
                        child: Text(statusAktivitas, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Progres Penanganan',
                        child: Text(progresPenanganan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Kategori Aktivitas',
                        child: Text(kategoriAktivitas, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Tindakan',
                        child: Text(tindakan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Status Objek',
                        child: Text(statusObjek, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Keterangan Aktivitas',
                        child: Text(keterangan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Temuan',
                        child: Text(temuan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Jumlah Temuan',
                        child: Text(jumlahTemuan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Tanggapan',
                        child: Text(tanggapan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Lokasi',
                        child: Text(lokasi, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Tanggal',
                        child: Text(
                          formatHistoryDate(widget.item['createdAt'], 'dd/MM/yyyy'),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                        ),
                      ),
                      if (dokSosUri != null && dokSosUri.isNotEmpty)
                        HistoryInputWithLabel(
                          label: 'Dokumentasi Objek',
                          child: HistoryImageDisplay(url: dokSosUri),
                        ),
                    ],
                  ),

                  HistoryInputContainer(
                    label: 'TANDA TANGAN',
                    children: [
                      HistoryInputWithLabel(
                        label: 'Line Walker',
                        isFirst: true,
                        child: hasExistingTtdLineWalker
                            ? HistorySignatureDisplay(
                                url: widget.item['ttdLineWalker']?.toString(),
                                label: widget.item['namaTTDLineWalker']?.toString(),
                              )
                            : FieldSignatureInput(
                                label: 'TTD Line Walker',
                                isRequired: false,
                                signatureFile: _ttdLineWalker,
                                signatureUrl: widget.item['ttdLineWalker']?.toString(),
                                signerName: _namaTTDLineWalkerCtrl.text,
                                onSignatureChanged: (file) => setState(() => _ttdLineWalker = file),
                                onNameChanged: (name) => setState(() => _namaTTDLineWalkerCtrl.text = name),
                              ),
                      ),
                      HistoryInputWithLabel(
                        label: 'Team Leader GI',
                        child: hasExistingTtdTLGI
                            ? HistorySignatureDisplay(
                                url: widget.item['ttdTLGI']?.toString(),
                                label: widget.item['namaTTDTLGI']?.toString(),
                              )
                            : FieldSignatureInput(
                                label: 'TTD Team Leader GI',
                                isRequired: false,
                                signatureFile: _ttdTLGI,
                                signatureUrl: widget.item['ttdTLGI']?.toString(),
                                signerName: _namaTTDTLGICtrl.text,
                                onSignatureChanged: (file) => setState(() => _ttdTLGI = file),
                                onNameChanged: (name) => setState(() => _namaTTDTLGICtrl.text = name),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (!allSigned)
                    ElevatedButton(
                      onPressed: isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
