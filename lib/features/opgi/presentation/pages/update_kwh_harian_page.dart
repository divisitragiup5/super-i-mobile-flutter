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

class UpdateKwhHarianPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateKwhHarianPage({
    super.key,
    required this.params,
  });

  @override
  State<UpdateKwhHarianPage> createState() => _UpdateKwhHarianPageState();
}

class _UpdateKwhHarianPageState extends State<UpdateKwhHarianPage> {
  final _standController = TextEditingController();
  final _keteranganController = TextEditingController();
  File? _fotoFile;
  late DateTime _startTime;

  late int _id;
  late String _garduIndukNama;
  late String _kelompok;
  late String _jenis;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _id = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _garduIndukNama = p['garduInduk']?.toString() ?? '-';
    _kelompok = p['kelompok']?.toString() ?? '-';

    final item = p['item'] is Map<String, dynamic>
        ? p['item'] as Map<String, dynamic>
        : (p['item'] is Map ? Map<String, dynamic>.from(p['item'] as Map) : <String, dynamic>{});

    _jenis = item['jenis']?.toString() ?? '-';
  }

  @override
  void dispose() {
    _standController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  bool _isValidDecimal(String text) {
    if (text.contains(',')) return false;
    return double.tryParse(text) != null;
  }

  void _onSubmit() {
    final rawStand = _standController.text.trim();
    if (_fotoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto wajib diambil'), backgroundColor: Colors.red),
      );
      return;
    }

    if (rawStand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nilai stand wajib diisi'), backgroundColor: Colors.red),
      );
      return;
    }

    if (!_isValidDecimal(rawStand)) {
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

    final double standValue = double.parse(rawStand);
    final diffMinutes = DateTime.now().difference(_startTime).inMilliseconds / 1000 / 60;
    final ket = _keteranganController.text.trim();

    final data = <String, dynamic>{
      'stand': standValue,
      if (ket.isNotEmpty) 'keterangan': ket,
      'durasi': diffMinutes,
      'timezone': 'Asia/Jakarta',
      'fotoStand': {
        'date': DateTime.now().toIso8601String(),
      },
    };

    context.read<OpgiRealisasiCubit>().updateKwhHarianMobile(
          id: _id,
          file: _fotoFile!.path,
          data: data,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update kWh - $_jenis'),
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
                        _buildInfoRow('Kelompok', _kelompok),
                        const SizedBox(height: 8),
                        _buildInfoRow('Jenis Stand', _jenis),
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
                          label: 'Foto Stand $_jenis',
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
                          controller: _standController,
                          label: 'Stand',
                          hint: 'Masukkan nilai stand',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _keteranganController,
                          label: 'Keterangan (Opsional)',
                          hint: 'Masukkan keterangan',
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
