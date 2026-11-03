import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_anomali_cubit.dart';

class InputKondisiAnomaliGiPage extends StatefulWidget {
  final int anomaliId;
  final String assetNama;

  const InputKondisiAnomaliGiPage({
    super.key,
    required this.anomaliId,
    required this.assetNama,
  });

  @override
  State<InputKondisiAnomaliGiPage> createState() => _InputKondisiAnomaliGiPageState();
}

class _InputKondisiAnomaliGiPageState extends State<InputKondisiAnomaliGiPage> {
  final _formKey = GlobalKey<FormState>();

  String _urgensi = 'INVESTIGASI LANJUTAN';
  String _tindakan = 'ON PROGRES';
  final _keteranganController = TextEditingController();
  XFile? _fotoBukti;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) {
      setState(() => _fotoBukti = photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Kondisi - ${widget.assetNama}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<OpgiAnomaliCubit, OpgiAnomaliState>(
        listener: (context, state) {
          if (state is OpgiAnomaliSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true);
          } else if (state is OpgiAnomaliError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Update Status & Urgensi', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _urgensi,
                          decoration: const InputDecoration(labelText: 'Tingkat Urgensi', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'AMAN', child: Text('AMAN')),
                            DropdownMenuItem(value: 'INVESTIGASI LANJUTAN', child: Text('INVESTIGASI LANJUTAN')),
                            DropdownMenuItem(value: 'BAHAYA', child: Text('BAHAYA')),
                          ],
                          onChanged: (v) => setState(() => _urgensi = v ?? _urgensi),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _tindakan,
                          decoration: const InputDecoration(labelText: 'Tindakan', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'TIDAK ADA', child: Text('TIDAK ADA')),
                            DropdownMenuItem(value: 'ON PROGRES', child: Text('ON PROGRES')),
                            DropdownMenuItem(value: 'SELESAI', child: Text('SELESAI')),
                          ],
                          onChanged: (v) => setState(() => _tindakan = v ?? _tindakan),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _keteranganController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Keterangan Perkembangan *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Keterangan wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Foto Bukti
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Foto Bukti Kondisi Terbaru', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (_fotoBukti != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_fotoBukti!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: Text(_fotoBukti == null ? 'Ambil Foto Bukti' : 'Foto Ulang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade100,
                            foregroundColor: Colors.black87,
                          ),
                          onPressed: _pickPhoto,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Kirim Update Kondisi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      context.read<OpgiAnomaliCubit>().submitAnomaliKondisi(
                        data: {
                          'anomaliId': widget.anomaliId,
                          'urgensi': _urgensi,
                          'tindakan': _tindakan,
                          'keterangan': _keteranganController.text,
                          'timezone': 'Asia/Jakarta',
                        },
                        imageFile: _fotoBukti,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
