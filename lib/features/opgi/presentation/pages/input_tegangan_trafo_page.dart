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
import '../utils/tegangan_trafo_utils.dart';

class InputTeganganTrafoPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InputTeganganTrafoPage({
    super.key,
    required this.params,
  });

  @override
  State<InputTeganganTrafoPage> createState() => _InputTeganganTrafoPageState();
}

class _InputTeganganTrafoPageState extends State<InputTeganganTrafoPage> {
  final _mvController = TextEditingController();
  final _hvController = TextEditingController();
  File? _fotoMvFile;
  File? _fotoHvFile;
  int? _existingDraftId;
  double _initialDurasi = 0.0;
  late DateTime _startTime;

  // Extracted parameters
  late int _trafoId;
  late String _trafoNama;
  late String _garduIndukNama;
  late int _garduIndukId;
  late Map<String, dynamic> _lastPeriode;
  String? _scanValue;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _trafoId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _trafoNama = p['nama']?.toString() ?? '-';
    _garduIndukNama = p['garduInduk']?.toString() ?? p['garduIndukNama']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _lastPeriode = p['lastPeriode'] is Map<String, dynamic>
        ? p['lastPeriode'] as Map<String, dynamic>
        : {
            'periode': DateTime.now().hour,
            'tanggal': DateTime.now().day,
            'bulan': DateTime.now().month,
            'tahun': DateTime.now().year,
          };
    _scanValue = p['scanValue']?.toString();

    _loadExistingDraft();
  }

  Future<void> _loadExistingDraft() async {
    final periodeInt = _lastPeriode['periode'] is int
        ? _lastPeriode['periode'] as int
        : int.tryParse('${_lastPeriode['periode']}');

    final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
      nama: '$_trafoNama-$_garduIndukNama',
      periode: periodeInt,
      type: 'tegangan-trafo',
    );

    if (drafts.isNotEmpty && mounted) {
      final draft = drafts.first;
      _existingDraftId = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}');

      final data = draft['data'] is Map<String, dynamic>
          ? draft['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (data['mv'] != null) {
        _mvController.text = data['mv'].toString();
      }
      if (data['hv'] != null) {
        _hvController.text = data['hv'].toString();
      }

      _initialDurasi = (data['durasi'] as num?)?.toDouble() ?? 0.0;

      final fotoMvData = data['fotoMV'];
      final fotoMvUri = fotoMvData is Map ? fotoMvData['uri'] as String? : (fotoMvData is String ? fotoMvData : null);
      if (fotoMvUri != null && _scanValue == null) {
        final file = File(fotoMvUri);
        if (file.existsSync()) {
          setState(() {
            _fotoMvFile = file;
          });
        }
      }

      final fotoHvData = data['fotoHV'];
      final fotoHvUri = fotoHvData is Map ? fotoHvData['uri'] as String? : (fotoHvData is String ? fotoHvData : null);
      if (fotoHvUri != null && _scanValue == null) {
        final file = File(fotoHvUri);
        if (file.existsSync()) {
          setState(() {
            _fotoHvFile = file;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _mvController.dispose();
    _hvController.dispose();
    super.dispose();
  }

  bool _isValidDecimal(String text) {
    if (text.contains(',')) return false;
    return double.tryParse(text) != null;
  }

  double _calculateTotalDuration() {
    final diffMinutes = DateTime.now().difference(_startTime).inMilliseconds / 1000 / 60;
    return _initialDurasi + diffMinutes;
  }

  Future<void> _saveAsDraft() async {
    final rawMv = _mvController.text.trim();
    final rawHv = _hvController.text.trim();

    if ((rawMv.isNotEmpty && !_isValidDecimal(rawMv)) || (rawHv.isNotEmpty && !_isValidDecimal(rawHv))) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Gunakan titik ( . ) sebagai pemisah nilai desimal'),
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

    final mvVal = rawMv.isNotEmpty ? double.tryParse(rawMv) : null;
    final hvVal = rawHv.isNotEmpty ? double.tryParse(rawHv) : null;
    final isPS = _trafoNama.contains('PS');

    if (mvVal != null && hvVal != null) {
      final warnings = checkTeganganThresholds(
        isPS: isPS,
        mv: mvVal,
        hv: hvVal,
      );
      if (warnings.isNotEmpty) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Peringatan'),
            content: Text(warnings.join('\n\n')),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  _doSaveDraft(rawMv, rawHv);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
        return;
      }
    }

    await _doSaveDraft(rawMv, rawHv);
  }

  Future<void> _doSaveDraft(String rawMv, String rawHv) async {
    final periodeInt = _lastPeriode['periode'] is int
        ? _lastPeriode['periode'] as int
        : int.tryParse('${_lastPeriode['periode']}') ?? 0;
    final tanggalInt = _lastPeriode['tanggal'] is int
        ? _lastPeriode['tanggal'] as int
        : int.tryParse('${_lastPeriode['tanggal']}') ?? DateTime.now().day;
    final bulanInt = _lastPeriode['bulan'] is int
        ? _lastPeriode['bulan'] as int
        : int.tryParse('${_lastPeriode['bulan']}') ?? DateTime.now().month;
    final tahunInt = _lastPeriode['tahun'] is int
        ? _lastPeriode['tahun'] as int
        : int.tryParse('${_lastPeriode['tahun']}') ?? DateTime.now().year;

    final draftPayload = {
      'id': _trafoId,
      'nama': _trafoNama,
      'garduIndukId': _garduIndukId,
      'periode': periodeInt,
      'tanggal': tanggalInt,
      'bulan': bulanInt,
      'tahun': tahunInt,
      'mv': rawMv.isNotEmpty ? double.tryParse(rawMv) : null,
      'hv': rawHv.isNotEmpty ? double.tryParse(rawHv) : null,
      'durasi': _calculateTotalDuration(),
      'fotoMV': _fotoMvFile != null
          ? {
              'uri': _fotoMvFile!.path,
              'date': DateTime.now().toIso8601String(),
            }
          : null,
      'fotoHV': _fotoHvFile != null
          ? {
              'uri': _fotoHvFile!.path,
              'date': DateTime.now().toIso8601String(),
            }
          : null,
    };

    final dateStr = DateFormat('dd-MMMM-yyyy').format(DateTime.now());

    await context.read<OpgiRealisasiCubit>().saveDraft(
          type: 'tegangan-trafo',
          nama: '$_trafoNama-$_garduIndukNama',
          date: dateStr,
          periode: periodeInt,
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
    final rawMv = _mvController.text.trim();
    final rawHv = _hvController.text.trim();

    if (_fotoMvFile == null || _fotoHvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto MV dan Foto HV wajib diambil'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (rawMv.isEmpty || rawHv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tegangan MV dan HV wajib diisi'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!_isValidDecimal(rawMv) || !_isValidDecimal(rawHv)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Gunakan titik ( . ) sebagai pemisah nilai desimal'),
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

    final mvNum = double.parse(rawMv);
    final hvNum = double.parse(rawHv);
    final isPS = _trafoNama.contains('PS');

    final warnings = checkTeganganThresholds(
      isPS: isPS,
      mv: mvNum,
      hv: hvNum,
    );

    if (warnings.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: Text(warnings.join('\n\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _sendPayload(mvNum, hvNum);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } else {
      _sendPayload(mvNum, hvNum);
    }
  }

  void _sendPayload(double mvNum, double hvNum) {
    final periodeInt = _lastPeriode['periode'] is int
        ? _lastPeriode['periode'] as int
        : int.tryParse('${_lastPeriode['periode']}') ?? 0;
    final tanggalInt = _lastPeriode['tanggal'] is int
        ? _lastPeriode['tanggal'] as int
        : int.tryParse('${_lastPeriode['tanggal']}') ?? DateTime.now().day;
    final bulanInt = _lastPeriode['bulan'] is int
        ? _lastPeriode['bulan'] as int
        : int.tryParse('${_lastPeriode['bulan']}') ?? DateTime.now().month;
    final tahunInt = _lastPeriode['tahun'] is int
        ? _lastPeriode['tahun'] as int
        : int.tryParse('${_lastPeriode['tahun']}') ?? DateTime.now().year;

    final cleanPayload = <String, dynamic>{
      'trafoId': _trafoId,
      'mv': mvNum,
      'hv': hvNum,
      'periode': periodeInt,
      'tanggal': tanggalInt,
      'bulan': bulanInt,
      'tahun': tahunInt,
      'durasi': _calculateTotalDuration(),
      'timezone': 'Asia/Jakarta',
      'garduIndukId': _garduIndukId,
      'fotoMV': {
        'date': DateTime.now().toIso8601String(),
      },
      'fotoHV': {
        'date': DateTime.now().toIso8601String(),
      },
    };

    context.read<OpgiRealisasiCubit>().submitTeganganTrafoSingle(
          fotoMV: _fotoMvFile!.path,
          fotoHV: _fotoHvFile!.path,
          data: cleanPayload,
          draftId: _existingDraftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isPS = _trafoNama.contains('PS');
    final periodeFormatted = (_lastPeriode['periode'] ?? 0).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Tegangan - $_trafoNama'),
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
              Navigator.pop(context);
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
                        _buildInfoRow('Trafo', _trafoNama),
                        const SizedBox(height: 8),
                        _buildInfoRow('Periode', periodeFormatted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Container
                  InputContainer(
                    label: 'FORM REALISASI',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldPictInput(
                          label: 'Foto MV',
                          placeholder: 'Ambil Foto MV',
                          pictureFile: _fotoMvFile,
                          isRequired: true,
                          onChange: (file) {
                            setState(() {
                              _fotoMvFile = file;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _mvController,
                          label: isPS ? 'Tegangan MV (V)' : 'Tegangan MV (kV)',
                          hint: 'Masukkan tegangan MV',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ambang batas normal tegangan MV: ${isPS ? "342 - 399" : "20.24 - 20.76"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FieldPictInput(
                          label: 'Foto HV',
                          placeholder: 'Ambil Foto HV',
                          pictureFile: _fotoHvFile,
                          isRequired: true,
                          onChange: (file) {
                            setState(() {
                              _fotoHvFile = file;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _hvController,
                          label: 'Tegangan HV (kV)',
                          hint: 'Masukkan tegangan HV',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ambang batas normal tegangan HV: ${isPS ? "20.24 - 20.76" : "142.5 - 157.5"}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

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
