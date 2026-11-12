import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/field_video_input.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_anomali_model.dart';
import '../cubit/opgi_anomali_cubit.dart';

class InputKondisiAnomaliGiPage extends StatefulWidget {
  final int anomaliId;
  final String garduIndukNama;
  final int garduIndukId;
  final AnomaliReportModel? anomaliData;
  final String assetNama;
  final Map<String, dynamic>? initialDraftData;

  const InputKondisiAnomaliGiPage({
    super.key,
    required this.anomaliId,
    this.garduIndukNama = '-',
    this.garduIndukId = 0,
    this.anomaliData,
    this.assetNama = '-',
    this.initialDraftData,
  });

  @override
  State<InputKondisiAnomaliGiPage> createState() =>
      _InputKondisiAnomaliGiPageState();
}

class _InputKondisiAnomaliGiPageState extends State<InputKondisiAnomaliGiPage> {
  final _formKey = GlobalKey<FormState>();

  String _urgensi = 'INVESTIGASI LANJUTAN';
  String _tindakan = 'ON PROGRES';
  final _keteranganController = TextEditingController();

  File? _fotoBukti;
  File? _videoBukti;
  int? _loadedDraftId;

  String get _draftKey {
    final asset = widget.anomaliData?.assetNama ?? widget.assetNama;
    return '$asset-${widget.garduIndukNama}';
  }

  @override
  void initState() {
    super.initState();
    _loadInitialDraft();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialDraft() async {
    if (widget.initialDraftData != null) {
      _applyDraft(widget.initialDraftData!);
      return;
    }

    final draft =
        await context.read<OpgiAnomaliCubit>().getKondisiDraft(_draftKey);
    if (draft != null && mounted) {
      _loadedDraftId = draft['id'] as int?;
      final data = draft['data'];
      if (data is Map<String, dynamic>) {
        _applyDraft(data);
      }
    }
  }

  void _applyDraft(Map<String, dynamic> data) {
    setState(() {
      if (data['urgensi'] != null) {
        _urgensi = data['urgensi'].toString();
      }
      if (data['tindakan'] != null) {
        _tindakan = data['tindakan'].toString();
      }
      if (data['keterangan'] != null) {
        _keteranganController.text = data['keterangan'].toString();
      }
      if (data['fotoBuktiPath'] != null) {
        final f = File(data['fotoBuktiPath'].toString());
        if (f.existsSync()) _fotoBukti = f;
      }
      if (data['videoBuktiPath'] != null) {
        final v = File(data['videoBuktiPath'].toString());
        if (v.existsSync()) _videoBukti = v;
      }
    });
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'anomaliId': widget.anomaliId,
      'urgensi': _urgensi,
      'tindakan': _tindakan,
      'keterangan': _keteranganController.text,
      'timezone': AppTimeUtils.deviceTimezone,
      if (_fotoBukti != null) 'fotoBuktiPath': _fotoBukti!.path,
      if (_videoBukti != null) 'videoBuktiPath': _videoBukti!.path,
    };
  }

  Future<void> _saveDraft() async {
    final payload = _buildPayload();
    await context.read<OpgiAnomaliCubit>().saveKondisiDraft(
          nama: _draftKey,
          data: payload,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Simpan draft berhasil!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_fotoBukti == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto bukti wajib diambil'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final payload = {
      'anomaliId': widget.anomaliId,
      'urgensi': _urgensi,
      'tindakan': _tindakan,
      'keterangan': _keteranganController.text,
      'timezone': AppTimeUtils.deviceTimezone,
    };

    context.read<OpgiAnomaliCubit>().submitAnomaliKondisi(
          data: payload,
          imageFile: XFile(_fotoBukti!.path),
          videoFile: _videoBukti != null ? XFile(_videoBukti!.path) : null,
          draftId: _loadedDraftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.anomaliData;

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Kondisi - ${widget.assetNama}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Simpan Draft',
            onPressed: _saveDraft,
          ),
        ],
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
              final isSelesai =
                  state.extra is Map && state.extra['isSelesai'] == true;
              Navigator.pop(context, isSelesai);
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
                  // 1. Info Card
                  if (info != null)
                    InputContainer(
                      label: 'INFO',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputWithLabel(
                            label: 'Gardu Induk',
                            child: Text(
                              widget.garduIndukNama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          InputWithLabel(
                            label: 'Jenis Asset',
                            child: Text(info.jenisAsset),
                          ),
                          InputWithLabel(
                            label: 'Asset',
                            child: Text(info.assetNama),
                          ),
                          InputWithLabel(
                            label: 'Entitas',
                            child: Text(info.entitas),
                          ),
                          InputWithLabel(
                            label: 'Operator',
                            child: Text(info.namaPetugas ?? '-'),
                          ),
                        ],
                      ),
                    ),

                  // 2. Input Kondisi Form Card
                  InputContainer(
                    label: 'INPUT KONDISI',
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
                            items: const [
                              DropdownMenuItem(
                                  value: 'TIDAK ADA', child: Text('TIDAK ADA')),
                              DropdownMenuItem(
                                  value: 'ON PROGRES',
                                  child: Text('ON PROGRES')),
                              DropdownMenuItem(
                                  value: 'SELESAI', child: Text('SELESAI')),
                            ],
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
                              hintText: 'Tulis jawaban / keterangan kondisi',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.all(12),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Keterangan wajib diisi'
                                : null,
                          ),
                        ),

                        // Foto Bukti
                        FieldPictInput(
                          label: 'Foto Bukti',
                          placeholder: 'Ambil Foto',
                          pictureFile: _fotoBukti,
                          isRequired: true,
                          onChange: (file) {
                            setState(() => _fotoBukti = file);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Video Bukti
                        FieldVideoInput(
                          label: 'Vidio Bukti (Opsional)',
                          placeholder: 'Ambil video (Maks 10 Detik)',
                          videoFile: _videoBukti,
                          maxDuration: 10,
                          onChange: (file) {
                            setState(() => _videoBukti = file);
                          },
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
