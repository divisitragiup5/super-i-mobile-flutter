import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../cubit/kegiatan_sosial_cubit.dart';

class UpdateKegiatanSosialPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const UpdateKegiatanSosialPage({
    super.key,
    required this.item,
  });

  @override
  State<UpdateKegiatanSosialPage> createState() => _UpdateKegiatanSosialPageState();
}

class _UpdateKegiatanSosialPageState extends State<UpdateKegiatanSosialPage> {
  File? _ttdTLGI;
  final TextEditingController _namaTTDTLGICtrl = TextEditingController();

  File? _ttdLineWalker;
  final TextEditingController _namaTTDLineWalkerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item['namaTTDTLGI'] != null) {
      _namaTTDTLGICtrl.text = widget.item['namaTTDTLGI'].toString();
    }
    if (widget.item['namaTTDLineWalker'] != null) {
      _namaTTDLineWalkerCtrl.text = widget.item['namaTTDLineWalker'].toString();
    }
  }

  @override
  void dispose() {
    _namaTTDTLGICtrl.dispose();
    _namaTTDLineWalkerCtrl.dispose();
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

    if (_ttdTLGI == null && _ttdLineWalker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan buat tanda tangan terlebih dahulu')),
      );
      return;
    }

    context.read<KegiatanSosialCubit>().updateKegiatanSosial(
      id: id,
      ttdTLGI: _ttdTLGI,
      namaTTDTLGI: _namaTTDTLGICtrl.text.isNotEmpty ? _namaTTDTLGICtrl.text.trim() : null,
      ttdLineWalker: _ttdLineWalker,
      namaTTDLineWalker: _namaTTDLineWalkerCtrl.text.isNotEmpty ? _namaTTDLineWalkerCtrl.text.trim() : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final towerName = widget.item['tower'] is Map ? widget.item['tower']['nama']?.toString() : 'Tower';
    final jenisAktivitas = widget.item['jenisAktivitas']?.toString() ?? '-';
    final statusAktivitas = widget.item['statusAktivitas']?.toString() ?? '-';
    final pelaku = widget.item['pelakuAktivitasSosial']?.toString() ?? '-';
    final keterangan = widget.item['keterangan']?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update TTD Kegiatan Sosial'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<KegiatanSosialCubit, KegiatanSosialState>(
        listener: (context, state) {
          if (state is KegiatanSosialSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
            context.pop(true);
          } else if (state is KegiatanSosialSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is KegiatanSosialSubmitting;

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
                          'INFORMASI KEGIATAN SOSIAL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text('Objek: $towerName', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Jenis Aktivitas: $jenisAktivitas'),
                        const SizedBox(height: 6),
                        Text('Status: $statusAktivitas'),
                        const SizedBox(height: 6),
                        Text('Pelaku: $pelaku'),
                        const SizedBox(height: 6),
                        Text('Keterangan: $keterangan'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // TL GI Signature Card
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
                            labelText: 'Nama Lengkap TL GI',
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
                          label: Text(_ttdTLGI != null ? 'Ubah Tanda Tangan TL GI' : 'Buka Kanvas TTD TL GI'),
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
