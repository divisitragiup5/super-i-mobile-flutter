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

class UpdateBebanTrafoPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateBebanTrafoPage({
    super.key,
    required this.params,
  });

  @override
  State<UpdateBebanTrafoPage> createState() => _UpdateBebanTrafoPageState();
}

class _UpdateBebanTrafoPageState extends State<UpdateBebanTrafoPage> {
  final _bebanController = TextEditingController();
  File? _fotoFile;
  late DateTime _startTime;

  late int _bebanId;
  late String _trafoNama;
  late double _iMax;
  late String _garduIndukNama;
  late int _periode;
  Map<String, dynamic>? _beforeItem;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _bebanId = p['bebanId'] is int ? p['bebanId'] as int : int.tryParse('${p['bebanId']}') ?? 0;
    _trafoNama = p['nama']?.toString() ?? '-';
    _iMax = (p['iMax'] as num?)?.toDouble() ?? 0.0;
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
          content: const Text('Beban melebihi I Max!'),
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
                _checkSecondValidationAndSend(bebanValue);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
      return;
    }

    _checkSecondValidationAndSend(bebanValue);
  }

  void _checkSecondValidationAndSend(double bebanValue) {
    // Validasi 2: Naik > 2x lipat dari beban sebelumnya
    if (_beforeItem != null && _beforeItem!['beban'] != null) {
      final double beforeBeban = (num.tryParse('${_beforeItem!['beban']}') ?? 0).toDouble();
      if (beforeBeban > 0 && bebanValue >= (2 * beforeBeban)) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Peringatan'),
            content: const Text('Beban naik lebih dari 2x lipat dari beban sebelumnya!'),
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
                  _sendUpdate(bebanValue);
                },
                child: const Text('Simpan'),
              ),
            ],
          ),
        );
        return;
      }
    }

    _sendUpdate(bebanValue);
  }

  void _sendUpdate(double bebanValue) {
    final diffMinutes = DateTime.now().difference(_startTime).inMilliseconds / 1000 / 60;

    final data = <String, dynamic>{
      'beban': bebanValue.round(),
      'durasi': diffMinutes,
      'timezone': 'Asia/Jakarta',
      'foto': {
        'date': DateTime.now().toIso8601String(),
      },
    };

    context.read<OpgiRealisasiCubit>().updateBebanTrafoMobile(
          bebanId: _bebanId,
          file: _fotoFile!,
          data: data,
        );
  }

  @override
  Widget build(BuildContext context) {
    final periodeFormatted = _periode.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Beban - $_trafoNama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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
                    label: 'FORM UPDATE',
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
                    onPressed: isLoading ? null : _onSubmit,
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
