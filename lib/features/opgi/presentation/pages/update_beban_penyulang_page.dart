import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/input_container.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class UpdateBebanPenyulangPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateBebanPenyulangPage({
    super.key,
    required this.params,
  });

  @override
  State<UpdateBebanPenyulangPage> createState() => _UpdateBebanPenyulangPageState();
}

class _UpdateBebanPenyulangPageState extends State<UpdateBebanPenyulangPage> {
  final _bebanController = TextEditingController();
  File? _fotoFile;
  late DateTime _startTime;

  late int _bebanId;
  late double _iMax;
  late String _rel;
  late String _garduIndukNama;
  late int _periode;
  Map<String, dynamic>? _beforeItem;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _bebanId = p['bebanId'] is int ? p['bebanId'] as int : int.tryParse('${p['bebanId']}') ?? 0;
    _iMax = (p['iMax'] as num?)?.toDouble() ?? 0.0;
    _rel = p['rel']?.toString() ?? '-';
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _periode = p['periode'] is int ? p['periode'] as int : int.tryParse('${p['periode']}') ?? 0;

    _beforeItem = p['beforeItem'] is Map<String, dynamic> ? p['beforeItem'] as Map<String, dynamic> : null;
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
    final beforeBebanVal = (_beforeItem?['beban'] as num?)?.toDouble();
    if (beforeBebanVal != null && beforeBebanVal > 0 && bebanValue >= beforeBebanVal * 2) {
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
    final durasi = DateTime.now().difference(_startTime).inMilliseconds / 1000 / 60;

    final payload = {
      'beban': bebanValue.round(),
      'durasi': durasi,
      'timezone': 'Asia/Jakarta',
    };

    context.read<OpgiRealisasiCubit>().updateBebanPenyulangMobile(
          bebanId: _bebanId,
          file: _fotoFile!,
          data: payload,
        );
  }

  @override
  Widget build(BuildContext context) {
    final periodeStr = _periode.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Beban Penyulang'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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
                        margin: EdgeInsets.zero,
                        child: Text('$_iMax', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
