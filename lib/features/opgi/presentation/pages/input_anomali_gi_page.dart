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
import '../../../../core/widgets/searchable_dropdown.dart';
import '../cubit/opgi_anomali_cubit.dart';

class InputAnomaliGiPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final Map<String, dynamic>? initialDraftData;

  const InputAnomaliGiPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    this.initialDraftData,
  });

  @override
  State<InputAnomaliGiPage> createState() => _InputAnomaliGiPageState();
}

class _InputAnomaliGiPageState extends State<InputAnomaliGiPage> {
  final _formKey = GlobalKey<FormState>();

  String _jenisAsset = 'PENYULANG';
  int? _assetId;
  String _entitas = 'KUBIKEL';
  String _urgensi = 'INVESTIGASI LANJUTAN';
  String _tindakan = 'ON PROGRES';
  final _keteranganController = TextEditingController();

  File? _fotoBukti;
  File? _videoBukti;
  int? _loadedDraftId;
  List<Map<String, dynamic>> _availableAssets = [];
  bool _isLoadingAssets = false;

  @override
  void initState() {
    super.initState();
    _loadInitialDraft();
    _fetchAssets();
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

    final draft = await context
        .read<OpgiAnomaliCubit>()
        .getAnomaliDraft(widget.garduIndukNama);
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
      if (data['jenisAsset'] != null) {
        _jenisAsset = data['jenisAsset'].toString();
      }
      if (data['assetId'] != null) {
        _assetId = int.tryParse(data['assetId'].toString());
      }
      if (data['entitas'] != null) {
        _entitas = data['entitas'].toString();
      }
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

  Future<void> _fetchAssets() async {
    setState(() => _isLoadingAssets = true);
    await context
        .read<OpgiAnomaliCubit>()
        .loadAssets(widget.garduIndukId, _jenisAsset);
    setState(() => _isLoadingAssets = false);
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'jenisAsset': _jenisAsset,
      'assetId': _assetId ?? 0,
      'entitas': _entitas,
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
    await context.read<OpgiAnomaliCubit>().saveAnomaliDraft(
          nama: widget.garduIndukNama,
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
    if (_assetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih aset terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
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
      'jenisAsset': _jenisAsset,
      'assetId': _assetId,
      'entitas': _entitas,
      'urgensi': _urgensi,
      'tindakan': _tindakan,
      'keterangan': _keteranganController.text,
      'timezone': AppTimeUtils.deviceTimezone,
    };

    context.read<OpgiAnomaliCubit>().submitAnomali(
          data: payload,
          imageFile: XFile(_fotoBukti!.path),
          videoFile: _videoBukti != null ? XFile(_videoBukti!.path) : null,
          draftId: _loadedDraftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Anomali GI'),
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
            if (state is OpgiAnomaliAssetsLoaded) {
              setState(() {
                _availableAssets = state.assets;
                if (_assetId != null &&
                    !_availableAssets.any((a) => a['id'] == _assetId)) {
                  _assetId = null;
                }
              });
            } else if (state is OpgiAnomaliSuccess) {
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
                  // 1. Info GI
                  InputContainer(
                    label: 'INFO',
                    child: InputWithLabel(
                      label: 'Gardu Induk',
                      child: Text(
                        widget.garduIndukNama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // 2. Input Fields
                  InputContainer(
                    label: 'INPUT',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Jenis Asset Dropdown
                        InputWithLabel(
                          label: 'Jenis Asset',
                          child: DropdownButtonFormField<String>(
                            initialValue: _jenisAsset,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'PENYULANG', child: Text('PENYULANG')),
                              DropdownMenuItem(
                                  value: 'TRAFO', child: Text('TRAFO')),
                            ],
                            onChanged: (val) {
                              if (val != null && val != _jenisAsset) {
                                setState(() {
                                  _jenisAsset = val;
                                  _assetId = null;
                                });
                                _fetchAssets();
                              }
                            },
                          ),
                        ),

                        // Asset Dropdown (Searchable)
                        InputWithLabel(
                          label: 'Asset',
                          child: SearchableDropdown<int>(
                            label: 'Pilih Asset',
                            hint: _isLoadingAssets
                                ? 'Memuat asset...'
                                : 'Pilih asset',
                            value: _assetId,
                            isLoading: _isLoadingAssets,
                            items: _availableAssets
                                .map((a) => DropdownItem<int>(
                                      value: a['id'] as int,
                                      label: a['nama']?.toString() ?? '-',
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() => _assetId = val);
                            },
                          ),
                        ),

                        // Entitas Dropdown
                        InputWithLabel(
                          label: 'Entitas',
                          child: DropdownButtonFormField<String>(
                            initialValue: _entitas,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'KUBIKEL', child: Text('KUBIKEL')),
                              DropdownMenuItem(
                                  value: 'KWH', child: Text('KWH')),
                              DropdownMenuItem(
                                  value: 'TRAFO', child: Text('TRAFO')),
                              DropdownMenuItem(
                                  value: 'RELAY', child: Text('RELAY')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _entitas = val);
                            },
                          ),
                        ),

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
                              hintText: 'Tulis jawaban / temuan anomali',
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
