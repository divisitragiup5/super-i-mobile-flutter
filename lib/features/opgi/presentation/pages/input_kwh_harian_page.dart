import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/local_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/input_container.dart';
import '../cubit/opgi_realisasi_cubit.dart';
import '../utils/kwh_harian_utils.dart';

class _StandItemInputState {
  final TextEditingController standController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  File? fotoFile;

  void dispose() {
    standController.dispose();
    keteranganController.dispose();
  }
}

class InputKwhHarianPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InputKwhHarianPage({
    super.key,
    required this.params,
  });

  @override
  State<InputKwhHarianPage> createState() => _InputKwhHarianPageState();
}

class _InputKwhHarianPageState extends State<InputKwhHarianPage> {
  final Map<String, _StandItemInputState> _stands = {};
  int? _existingDraftId;
  double _initialDurasi = 0.0;
  late DateTime _startTime;

  // Parameters
  late int _objectId;
  late String _nama;
  late String _type;
  late String _kelompok;
  late String _garduIndukNama;
  late int _garduIndukId;
  late List<String> _jenisList;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _objectId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _nama = p['nama']?.toString() ?? '-';
    _type = p['type']?.toString() ?? 'PENYULANG';
    _kelompok = p['kelompok']?.toString() ?? 'FEEDER';
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _jenisList = kJenisKelompokKwh[_kelompok] ?? ['H', 'L1', 'L2'];
    for (final jenis in _jenisList) {
      _stands[jenis] = _StandItemInputState();
    }

    _loadExistingDraft();
  }

  Future<void> _loadExistingDraft() async {
    final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
      nama: '$_nama-$_kelompok-$_garduIndukNama',
      type: 'kwh-harian',
    );

    if (drafts.isNotEmpty && mounted) {
      final draft = drafts.first;
      _existingDraftId = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}');

      final data = draft['data'] is Map<String, dynamic>
          ? draft['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      _initialDurasi = (data['durasi'] as num?)?.toDouble() ?? 0.0;

      final rawDataList = data['data'];
      if (rawDataList is List) {
        for (final item in rawDataList) {
          if (item is Map) {
            final jenis = item['jenis']?.toString();
            if (jenis != null && _stands.containsKey(jenis)) {
              final state = _stands[jenis]!;
              if (item['stand'] != null) {
                state.standController.text = item['stand'].toString();
              }
              if (item['keterangan'] != null) {
                state.keteranganController.text = item['keterangan'].toString();
              }

              final foto = item['fotoStand'];
              final uri = foto is Map ? foto['uri']?.toString() : (foto is String ? foto : null);
              if (uri != null) {
                final file = File(uri);
                if (file.existsSync()) {
                  state.fotoFile = file;
                }
              }
            }
          }
        }
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    for (final state in _stands.values) {
      state.dispose();
    }
    super.dispose();
  }

  double _calculateTotalDuration() {
    final diffMinutes = DateTime.now().difference(_startTime).inMilliseconds / 1000 / 60;
    return _initialDurasi + diffMinutes;
  }

  bool _isValidDecimal(String text) {
    if (text.contains(',')) return false;
    return double.tryParse(text) != null;
  }

  Future<void> _saveAsDraft() async {
    // Validasi format desimal
    for (final entry in _stands.entries) {
      final rawText = entry.value.standController.text.trim();
      if (rawText.isNotEmpty && !_isValidDecimal(rawText)) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Peringatan'),
            content: Text('Gunakan titik ( . ) sebagai pemisah nilai desimal pada stand ${entry.key}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
        return;
      }
    }

    final dataList = _jenisList.map((jenis) {
      final state = _stands[jenis]!;
      final rawText = state.standController.text.trim();
      return {
        'jenis': jenis,
        'stand': rawText.isNotEmpty ? double.tryParse(rawText) : null,
        'keterangan': state.keteranganController.text.trim().isNotEmpty
            ? state.keteranganController.text.trim()
            : null,
        'fotoStand': state.fotoFile != null
            ? {
                'uri': state.fotoFile!.path,
                'date': DateTime.now().toIso8601String(),
              }
            : null,
      };
    }).toList();

    final draftPayload = {
      'objectId': _objectId,
      'type': _type,
      'kelompok': _kelompok,
      'garduIndukId': _garduIndukId,
      'durasi': _calculateTotalDuration(),
      'data': dataList,
    };

    final dateStr = DateFormat('dd-MMMM-yyyy').format(DateTime.now());

    await context.read<OpgiRealisasiCubit>().saveDraft(
          type: 'kwh-harian',
          nama: '$_nama-$_kelompok-$_garduIndukNama',
          date: dateStr,
          periode: 0,
          data: draftPayload,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Draft berhasil disimpan'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _submit() {
    for (final jenis in _jenisList) {
      final state = _stands[jenis]!;
      final rawStand = state.standController.text.trim();

      if (state.fotoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto wajib diambil untuk jenis $jenis'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      if (rawStand.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stand wajib diisi untuk jenis $jenis'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      if (!_isValidDecimal(rawStand)) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Peringatan'),
            content: Text('Gunakan titik ( . ) sebagai pemisah nilai desimal pada stand $jenis'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Tutup'),
              ),
            ],
          ),
        );
        return;
      }
    }

    final totalDurasi = _calculateTotalDuration();
    final filesWithJenis = <Map<String, dynamic>>[];
    final dtoList = <Map<String, dynamic>>[];

    for (final jenis in _jenisList) {
      final state = _stands[jenis]!;
      final standNum = double.parse(state.standController.text.trim());
      final ket = state.keteranganController.text.trim();

      filesWithJenis.add({
        'jenis': jenis,
        'file': state.fotoFile!.path,
      });

      dtoList.add({
        'jenis': jenis,
        'stand': standNum,
        if (ket.isNotEmpty) 'keterangan': ket,
        'durasi': totalDurasi,
        'fotoStand': {
          'date': DateTime.now().toIso8601String(),
        },
      });
    }

    final cleanPayload = <String, dynamic>{
      'objectId': _objectId,
      'type': _type,
      'kelompok': _kelompok,
      'timezone': 'Asia/Jakarta',
      'data': dtoList,
    };

    context.read<OpgiRealisasiCubit>().submitKwhHarianSingle(
          filesWithJenis: filesWithJenis,
          data: cleanPayload,
          draftId: _existingDraftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input kWh - $_nama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Simpan Draft',
            onPressed: _saveAsDraft,
          ),
        ],
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiRealisasiCubit, OpgiRealisasiState>(
          listener: (context, state) {
            if (state is OpgiRealisasiSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            } else if (state is OpgiRealisasiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is OpgiRealisasiLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Info Container
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Gardu Induk', _garduIndukNama),
                        const SizedBox(height: 8),
                        _buildInfoRow('Nama', _nama),
                        const SizedBox(height: 8),
                        _buildInfoRow('Kelompok', _kelompok),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stand inputs per jenis
                  ..._jenisList.map((jenis) {
                    final state = _stands[jenis]!;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InputContainer(
                        label: 'JENIS: $jenis',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FieldPictInput(
                              label: 'Foto Stand $jenis',
                              placeholder: 'Ambil Foto',
                              pictureFile: state.fotoFile,
                              isRequired: true,
                              onChange: (file) {
                                setState(() {
                                  state.fotoFile = file;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: state.standController,
                              label: 'Stand ($jenis)',
                              hint: 'Masukkan nilai stand',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: state.keteranganController,
                              label: 'Keterangan (Opsional)',
                              hint: 'Masukkan keterangan',
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 8),
                  AppButton(
                    text: 'Simpan',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }
}
