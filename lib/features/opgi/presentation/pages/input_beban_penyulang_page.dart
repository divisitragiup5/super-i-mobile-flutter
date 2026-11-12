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

class InputBebanPenyulangPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InputBebanPenyulangPage({
    super.key,
    required this.params,
  });

  @override
  State<InputBebanPenyulangPage> createState() => _InputBebanPenyulangPageState();
}

class _InputBebanPenyulangPageState extends State<InputBebanPenyulangPage> {
  final _bebanController = TextEditingController();
  File? _fotoFile;
  int? _existingDraftId;
  double _initialDurasi = 0.0;
  late DateTime _startTime;

  // Extracted parameters
  late int _penyulangId;
  late String _penyulangNama;
  late double _iMax;
  late String _rel;
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
    _penyulangId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _penyulangNama = p['nama']?.toString() ?? '-';
    _iMax = (p['iMax'] as num?)?.toDouble() ?? 0.0;
    _rel = p['rel']?.toString() ?? '-';
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
      nama: '$_penyulangNama-$_garduIndukNama',
      periode: periodeInt,
      type: 'beban-penyulang',
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

    try {
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

      final draftData = {
        'id': _penyulangId,
        'garduIndukId': _garduIndukId,
        'periode': periodeInt,
        'tanggal': tanggalInt,
        'bulan': bulanInt,
        'tahun': tahunInt,
        'beban': rawText.isNotEmpty ? rawText : null,
        'foto': _fotoFile != null
            ? {
                'uri': _fotoFile!.path,
                'date': DateTime.now().toIso8601String(),
              }
            : null,
        'durasi': _calculateTotalDuration(),
        'startTime': _startTime.toIso8601String(),
      };

      await LocalDatabase.instance.insertUnfinishedItemGI({
        'nama': '$_penyulangNama-$_garduIndukNama',
        'date': DateFormat('dd-MMMM-yyyy').format(DateTime.now()),
        'type': 'beban-penyulang',
        'periode': periodeInt,
        'data': draftData,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simpan draft berhasil!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terdapat kesalahan saat menyimpan draft!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSubmit() {
    final rawText = _bebanController.text.trim();
    if (_fotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto wajib diambil'), backgroundColor: Colors.red),
      );
      return;
    }

    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai beban wajib diisi'), backgroundColor: Colors.red),
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

    final double bebanValue = double.parse(rawText);

    // Validasi 1: Melebihi iMax
    if (bebanValue > _iMax && _iMax > 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Beban melebihi iMax, yakin menyimpannya?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                _sendPayload(bebanValue);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      return;
    }

    // Validasi 2: Beban >= 2x beban sebelumnya
    final lastBebanVal = (_lastBeban?['beban'] as num?)?.toDouble();
    if (lastBebanVal != null && lastBebanVal > 0 && bebanValue >= lastBebanVal * 2) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Beban lebih atau sama dengan dua kali beban sebelumnya, yakin menyimpannya?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                _sendPayload(bebanValue);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      return;
    }

    _sendPayload(bebanValue);
  }

  void _sendPayload(double bebanValue) {
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

    final payload = {
      'penyulangId': _penyulangId,
      'beban': bebanValue.round(),
      'periode': periodeInt,
      'tanggal': tanggalInt,
      'bulan': bulanInt,
      'tahun': tahunInt,
      'durasi': _calculateTotalDuration(),
      'timezone': 'Asia/Jakarta',
      'garduIndukId': _garduIndukId,
    };

    context.read<OpgiRealisasiCubit>().submitBebanPenyulangSingle(
          file: _fotoFile!,
          data: payload,
          draftId: _existingDraftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    final periodeInt = _lastPeriode['periode'] is int
        ? _lastPeriode['periode'] as int
        : int.tryParse('${_lastPeriode['periode']}') ?? 0;
    final periodeStr = periodeInt.toString().padLeft(2, '0');

    final lastBebanPeriode = _lastBeban?['periode'] != null
        ? _lastBeban!['periode'].toString().padLeft(2, '0')
        : '-';
    final lastBebanVal = _lastBeban?['beban'] != null ? '${_lastBeban!['beban']}' : '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Beban Penyulang'),
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
        child: BlocListener<OpgiRealisasiCubit, OpgiRealisasiState>(
          listener: (context, state) {
            if (state is OpgiRealisasiSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop(true);
            } else if (state is OpgiRealisasiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card 1: INFO
                InputContainer(
                  label: 'INFO',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputWithLabel(
                        label: 'Gardu Induk',
                        child: Text(_garduIndukNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      InputWithLabel(
                        label: 'Rel',
                        child: Text(_rel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      InputWithLabel(
                        label: 'IMax',
                        child: Text('$_iMax', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      InputWithLabel(
                        label: 'Periode Terakhir',
                        child: Text(lastBebanPeriode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      InputWithLabel(
                        label: 'Beban Terakhir',
                        margin: EdgeInsets.zero,
                        child: Text(lastBebanVal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ],
                  ),
                ),

                // Card 2: INPUT BEBAN
                InputContainer(
                  label: 'INPUT BEBAN',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputWithLabel(
                        label: 'Periode',
                        child: Text(periodeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      FieldPictInput(
                        label: 'Foto',
                        placeholder: 'Ambil Foto',
                        pictureFile: _fotoFile,
                        isRequired: true,
                        onChange: (file) => setState(() => _fotoFile = file),
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Beban',
                        hint: 'Tulis beban',
                        controller: _bebanController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 20),
                      BlocBuilder<OpgiRealisasiCubit, OpgiRealisasiState>(
                        builder: (context, state) {
                          return AppButton(
                            text: 'Simpan',
                            isLoading: state is OpgiRealisasiLoading,
                            onPressed: _onSubmit,
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
    );
  }
}
