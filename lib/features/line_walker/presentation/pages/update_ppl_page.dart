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
import '../cubit/ppl_cubit.dart';
import '../widgets/history_detail_widgets.dart';

class UpdatePPLPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const UpdatePPLPage({
    super.key,
    required this.item,
  });

  @override
  State<UpdatePPLPage> createState() => _UpdatePPLPageState();
}

class _UpdatePPLPageState extends State<UpdatePPLPage> {
  File? _ttdTLGI;
  final TextEditingController _namaTTDTLGICtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.roles.contains(AppRoles.teamLeaderGi)) {
        _namaTTDTLGICtrl.text = authState.user.namaLengkap;
      }
    }

    if (widget.item['namaTTDTLGI'] != null && widget.item['namaTTDTLGI'].toString().isNotEmpty) {
      _namaTTDTLGICtrl.text = widget.item['namaTTDTLGI'].toString();
    }
  }

  @override
  void dispose() {
    _namaTTDTLGICtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final int id = widget.item['id'] is int
        ? widget.item['id']
        : int.tryParse('${widget.item['id']}') ?? 0;

    if (_ttdTLGI == null && (widget.item['ttdTLGI'] == null || widget.item['ttdTLGI'].toString().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan buat tanda tangan Team Leader GI terlebih dahulu')),
      );
      return;
    }

    if (_namaTTDTLGICtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap Team Leader GI wajib diisi')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah anda yakin ingin menyimpan data PPL ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<PplCubit>().updatePpl(
                id: id,
                ttdTLGI: _ttdTLGI,
                namaTTDTLGI: _namaTTDTLGICtrl.text.trim(),
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
    final namaPekerjaan = widget.item['namaPekerjaan']?.toString() ?? '-';
    final statusPekerjaan = widget.item['statusPekerjaan']?.toString() ?? '-';
    final kategoriObjek = widget.item['kategoriObjek']?.toString() ?? '-';
    final pihakPelaksana = widget.item['pihakPelaksana']?.toString() ?? '-';
    final pjPekerjaan = widget.item['pjPekerjaan']?.toString() ?? '-';
    final noTelp = widget.item['noTeleponPJPekerjaan']?.toString() ?? '-';
    final lokasi = widget.item['lokasi']?.toString() ?? '-';

    final dokObj = widget.item['dokumentasiObjek'];
    String? dokUri;
    if (dokObj is Map) {
      dokUri = dokObj['uri']?.toString();
    } else if (dokObj != null) {
      dokUri = dokObj.toString();
    }

    final hasExistingTtdTLGI = widget.item['ttdTLGI'] != null &&
        widget.item['ttdTLGI'].toString().isNotEmpty &&
        widget.item['namaTTDTLGI'] != null &&
        widget.item['namaTTDTLGI'].toString().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi PPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: BlocConsumer<PplCubit, PplState>(
          listener: (context, state) {
            if (state is PplSubmitSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
              );
              context.pop(true);
            } else if (state is PplSubmitFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is PplSubmitting;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HistoryInputContainer(
                    label: 'INFORMASI PPL',
                    children: [
                      HistoryInputWithLabel(
                        label: 'Objek',
                        isFirst: true,
                        child: Text(towerName, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Nama Pekerjaan',
                        child: Text(namaPekerjaan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Status Pekerjaan',
                        child: Text(statusPekerjaan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Kategori Objek',
                        child: Text(kategoriObjek, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Pihak Pelaksana',
                        child: Text(pihakPelaksana, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'Penanggung Jawab Pekerjaan',
                        child: Text(pjPekerjaan, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                      ),
                      HistoryInputWithLabel(
                        label: 'No Telepon Penanggung Jawab Pekerjaan',
                        child: Text(noTelp, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
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
                      if (dokUri != null && dokUri.isNotEmpty)
                        HistoryInputWithLabel(
                          label: 'Dokumentasi Objek',
                          child: HistoryImageDisplay(url: dokUri),
                        ),
                    ],
                  ),

                  HistoryInputContainer(
                    label: 'TANDA TANGAN',
                    children: [
                      HistoryInputWithLabel(
                        label: 'Line Walker',
                        isFirst: true,
                        child: HistorySignatureDisplay(
                          url: widget.item['ttdLineWalker']?.toString(),
                          label: widget.item['namaTTDLineWalker']?.toString(),
                        ),
                      ),
                      HistoryInputWithLabel(
                        label: 'Penanggung Jawab Pekerjaan',
                        child: HistorySignatureDisplay(
                          url: widget.item['ttdPJPekerjaan']?.toString(),
                          label: widget.item['namaTTDPJPekerjaan']?.toString(),
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
                                isRequired: true,
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

                  if (!hasExistingTtdTLGI)
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
