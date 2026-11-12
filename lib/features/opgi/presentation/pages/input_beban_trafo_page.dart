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

class InputBebanTrafoPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InputBebanTrafoPage({
    super.key,
    required this.params,
  });

  @override
  State<InputBebanTrafoPage> createState() => _InputBebanTrafoPageState();
}

class _InputBebanTrafoPageState extends State<InputBebanTrafoPage> {
  final _bebanController = TextEditingController();
  File? _fotoFile;
  int? _existingDraftId;
  double _initialDurasi = 0.0;
  late DateTime _startTime;

  // Extracted parameters
  late int _trafoId;
  late String _trafoNama;
  late double _iMax;
  late String _garduIndukNama;
  late int _garduIndukId;
  Map<String, dynamic>? _lastBeban;
  late Map<String, dynamic> _lastPeriode;
  String? _scanValue;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _trafoId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _trafoNama = p['nama']?.toString() ?? '-';
    _iMax = (p['iMax'] as num?)?.toDouble() ?? 0.0;
    _garduIndukNama = p['garduInduk']?.toString() ?? p['garduIndukNama']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _lastBeban = p['last'] is Map<String, dynamic> ? p['last'] as Map<String, dynamic> : null;
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
      type: 'beban-trafo',
    );

    if (drafts.isNotEmpty && mounted) {
      final draft = drafts.first;
      _existingDraftId = draft['id'] is int ? draft['id'] as int : int.tryParse('${draft['id']}');

      final data = draft['data'] is Map<String, dynamic>
          ? draft['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      if (data['beban'] != null) {
        _bebanController.text = data['beban'].toString();
      }

      _initialDurasi = (data['durasi'] as num?)?.toDouble() ?? 0.0;

      final fotoData = data['foto'];
      final fotoUri = fotoData is Map ? fotoData['uri'] as String? : (fotoData is String ? fotoData : null);

      if (fotoUri != null && _scanValue == null) {
        final file = File(fotoUri);
        if (file.existsSync()) {
          setState(() {
            _fotoFile = file;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _bebanController.dispose();
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
    final rawText = _bebanController.text.trim();
    if (rawText.isNotEmpty && !_isValidDecimal(rawText)) {
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
      'beban': rawText.isNotEmpty ? double.tryParse(rawText) : null,
      'durasi': _calculateTotalDuration(),
      'foto': _fotoFile != null
          ? {
              'uri': _fotoFile!.path,
              'date': DateTime.now().toIso8601String(),
            }
          : null,
    };

    final dateStr = DateFormat('dd-MMMM-yyyy').format(DateTime.now());

    await context.read<OpgiRealisasiCubit>().saveDraft(
          type: 'beban-trafo',
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
    final rawText = _bebanController.text.trim();
    if (_fotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto wajib diambil terlebih dahulu'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nilai beban wajib diisi'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!_isValidDecimal(rawText)) {
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

    final bebanNum = double.parse(rawText);
    final warnings = <String>[];

    if (bebanNum > _iMax) {
      warnings.add('Beban melebihi I Max!');
    }

    if (_lastBeban != null && _lastBeban!['beban'] != null) {
      final lastB = (num.tryParse('${_lastBeban!['beban']}') ?? 0).toDouble();
      if (lastB > 0 && bebanNum >= 2 * lastB) {
        warnings.add('Beban naik lebih dari 2x lipat dari beban sebelumnya!');
      }
    }

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
                _sendPayload(bebanNum);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } else {
      _sendPayload(bebanNum);
    }
  }

  void _sendPayload(double bebanNum) {
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
      'beban': bebanNum.round(),
      'periode': periodeInt,
      'tanggal': tanggalInt,
      'bulan': bulanInt,
      'tahun': tahunInt,
      'durasi': _calculateTotalDuration(),
      'timezone': 'Asia/Jakarta',
      'garduIndukId': _garduIndukId,
      'foto': {
        'date': DateTime.now().toIso8601String(),
      },
    };

    context.read<OpgiRealisasiCubit>().submitBebanTrafoSingle(
          file: _fotoFile!.path,
          data: cleanPayload,
          draftId: _existingDraftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final periodeFormatted = (_lastPeriode['periode'] ?? 0).toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Beban - $_trafoNama'),
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
                        _buildInfoRow('iMax', '${_iMax.toStringAsFixed(_iMax.truncateToDouble() == _iMax ? 0 : 1)} A'),
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
                          label: 'Foto Beban Trafo',
                          placeholder: 'Ambil Foto',
                          pictureFile: _fotoFile,
                          isRequired: true,
                          onChange: (file) {
                            setState(() {
                              _fotoFile = file;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _bebanController,
                          label: 'Beban (A)',
                          hint: 'Masukkan nilai beban',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
