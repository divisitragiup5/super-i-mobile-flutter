import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../cubit/ppl_cubit.dart';

class UpdatePPLPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const UpdatePPLPage({
    super.key,
    required this.item,
  });

  @override
  State<UpdatePPLPage> createState() => _UpdatePPLPageState();
}

class _UpdatePPLPageState extends State<UpdatePPLPage> {
  File? _ttdTLGI;
  final TextEditingController _namaTTDTLGICtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item['namaTTDTLGI'] != null) {
      _namaTTDTLGICtrl.text = widget.item['namaTTDTLGI'].toString();
    }
  }

  @override
  void dispose() {
    _namaTTDTLGICtrl.dispose();
    super.dispose();
  }

  Future<File> _base64ToFile(String base64Str, String name) async {
    final cleanBase64 = base64Str.contains(',') ? base64Str.split(',')[1] : base64Str;
    final bytes = base64Decode(cleanBase64);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${name}_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file;
  }

  void _handleSubmit() {
    final int id = widget.item['id'] is int
        ? widget.item['id']
        : int.tryParse('${widget.item['id']}') ?? 0;

    if (_ttdTLGI == null && widget.item['ttdTLGI'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan buat tanda tangan Team Leader GI terlebih dahulu')),
      );
      return;
    }

    if (_namaTTDTLGICtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama lengkap Team Leader GI wajib diisi')),
      );
      return;
    }

    context.read<PplCubit>().updatePpl(
      id: id,
      ttdTLGI: _ttdTLGI,
      namaTTDTLGI: _namaTTDTLGICtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final towerName = widget.item['tower'] is Map ? widget.item['tower']['nama']?.toString() : 'Tower';
    final namaPekerjaan = widget.item['namaPekerjaan']?.toString() ?? '-';
    final pihakPelaksana = widget.item['pihakPelaksana']?.toString() ?? '-';
    final pjPekerjaan = widget.item['pjPekerjaan']?.toString() ?? '-';
    final noTelp = widget.item['noTeleponPJPekerjaan']?.toString() ?? '-';
    final statusPekerjaan = widget.item['statusPekerjaan']?.toString() ?? '-';
    final existingTtdTLGI = widget.item['ttdTLGI']?.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Tanda Tangan PPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<PplCubit, PplState>(
        listener: (context, state) {
          if (state is PplSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
            context.pop(true);
          } else if (state is PplSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PplSubmitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INFORMASI PPL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Objek: $towerName', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Nama Pekerjaan: $namaPekerjaan'),
                        const SizedBox(height: 6),
                        Text('Status Pekerjaan: $statusPekerjaan'),
                        const SizedBox(height: 6),
                        Text('Pelaksana: $pihakPelaksana'),
                        const SizedBox(height: 6),
                        Text('Penanggung Jawab: $pjPekerjaan ($noTelp)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Signature Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TANDA TANGAN TEAM LEADER GI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _namaTTDTLGICtrl,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap Team Leader GI *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_ttdTLGI != null) ...[
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.file(_ttdTLGI!, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),
                        ] else if (existingTtdTLGI != null && existingTtdTLGI.isNotEmpty) ...[
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.network(existingTtdTLGI, fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 8),
                        ],
                        OutlinedButton.icon(
                          onPressed: () async {
                            final base64 = await FieldSignaturePad.show(
                              context,
                              title: 'Tanda Tangan Team Leader GI',
                              signerName: _namaTTDTLGICtrl.text,
                            );
                            if (base64 != null) {
                              final f = await _base64ToFile(base64, 'ttdTLGI');
                              setState(() => _ttdTLGI = f);
                            }
                          },
                          icon: const Icon(Icons.draw_outlined),
                          label: Text(_ttdTLGI != null || existingTtdTLGI != null
                              ? 'Ubah Tanda Tangan'
                              : 'Buka Kanvas Tanda Tangan'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Pembaruan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
