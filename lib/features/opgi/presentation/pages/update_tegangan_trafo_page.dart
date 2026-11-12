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
import '../utils/tegangan_trafo_utils.dart';

class UpdateTeganganTrafoPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateTeganganTrafoPage({
    super.key,
    required this.params,
  });

  @override
  State<UpdateTeganganTrafoPage> createState() => _UpdateTeganganTrafoPageState();
}

class _UpdateTeganganTrafoPageState extends State<UpdateTeganganTrafoPage> {
  final _mvController = TextEditingController();
  final _hvController = TextEditingController();
  File? _fotoMvFile;
  File? _fotoHvFile;
  late DateTime _startTime;

  late int _teganganId;
  late String _trafoNama;
  late String _garduIndukNama;
  late int _periode;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _teganganId = p['teganganId'] is int ? p['teganganId'] as int : int.tryParse('${p['teganganId']}') ?? 0;
    _trafoNama = p['nama']?.toString() ?? '-';
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _periode = p['periode'] is int ? p['periode'] as int : int.tryParse('${p['periode']}') ?? 0;
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

  void _onSubmit() {
    final rawMv = _mvController.text.trim();
    final rawHv = _hvController.text.trim();

    if (_fotoMvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto MV wajib diambil'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_fotoHvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto HV wajib diambil'), backgroundColor: Colors.red),
      );
      return;
    }

    if (rawMv.isEmpty || rawHv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tegangan MV dan HV wajib diisi'), backgroundColor: Colors.red),
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

    final double mvValue = double.parse(rawMv);
    final double hvValue = double.parse(rawHv);
    final isPS = _trafoNama.contains('PS');

    final warnings = checkTeganganThresholds(
      isPS: isPS,
      mv: mvValue,
      hv: hvValue,
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
                _sendUpdate(mvValue, hvValue);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } else {
      _sendUpdate(mvValue, hvValue);
    }
  }

  void _sendUpdate(double mvValue, double hvValue) {
    final diffMinutes = DateTime.now().difference(_startTime).inMilliseconds / 1000 / 60;

    final data = <String, dynamic>{
      'mv': mvValue,
      'hv': hvValue,
      'durasi': diffMinutes,
      'timezone': 'Asia/Jakarta',
      'fotoMV': {
        'date': DateTime.now().toIso8601String(),
      },
      'fotoHV': {
        'date': DateTime.now().toIso8601String(),
      },
    };

    context.read<OpgiRealisasiCubit>().updateTeganganTrafoMobile(
          teganganId: _teganganId,
          fotoMV: _fotoMvFile!,
          fotoHV: _fotoHvFile!,
          data: data,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isPS = _trafoNama.contains('PS');
    final periodeFormatted = _periode.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(
        title: Text('Update Tegangan - $_trafoNama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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
                      _buildInfoRow('Trafo', _trafoNama),
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
