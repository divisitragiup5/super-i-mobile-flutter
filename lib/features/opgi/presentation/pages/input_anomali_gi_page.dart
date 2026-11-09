import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_anomali_cubit.dart';

class InputAnomaliGiPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const InputAnomaliGiPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<InputAnomaliGiPage> createState() => _InputAnomaliGiPageState();
}

class _InputAnomaliGiPageState extends State<InputAnomaliGiPage> {
  final _formKey = GlobalKey<FormState>();

  String _jenisAsset = 'PENYULANG';
  final _assetIdController = TextEditingController(text: '1');
  final _assetNamaController = TextEditingController(text: 'Penyulang 1');
  String _entitas = 'KUBIKEL';
  String _urgensi = 'INVESTIGASI LANJUTAN';
  String _tindakan = 'ON PROGRES';
  final _keteranganController = TextEditingController();

  XFile? _fotoBukti;

  @override
  void dispose() {
    _assetIdController.dispose();
    _assetNamaController.dispose();
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

  Map<String, dynamic> _buildPayload() {
    return {
      'jenisAsset': _jenisAsset,
      'assetId': int.tryParse(_assetIdController.text) ?? 1,
      'assetNama': _assetNamaController.text,
      'entitas': _entitas,
      'urgensi': _urgensi,
      'tindakan': _tindakan,
      'keterangan': _keteranganController.text,
      'garduIndukId': widget.garduIndukId,
      'timezone': 'Asia/Jakarta',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Anomali GI'),
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
                        const Text('Informasi Aset', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _jenisAsset,
                          decoration: const InputDecoration(labelText: 'Jenis Aset', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'PENYULANG', child: Text('PENYULANG')),
                            DropdownMenuItem(value: 'TRAFO', child: Text('TRAFO')),
                          ],
                          onChanged: (v) => setState(() => _jenisAsset = v ?? _jenisAsset),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _assetNamaController,
                          decoration: const InputDecoration(labelText: 'Nama Aset *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _assetIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ID Aset *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _entitas,
                          decoration: const InputDecoration(labelText: 'Entitas', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'KUBIKEL', child: Text('KUBIKEL')),
                            DropdownMenuItem(value: 'KWH', child: Text('KWH')),
                            DropdownMenuItem(value: 'TRAFO', child: Text('TRAFO')),
                            DropdownMenuItem(value: 'RELAY', child: Text('RELAY')),
                          ],
                          onChanged: (v) => setState(() => _entitas = v ?? _entitas),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Klasifikasi Anomali', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _urgensi,
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
                          initialValue: _tindakan,
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
                            labelText: 'Keterangan Anomali *',
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
                        const Text('Foto Bukti Anomali', style: TextStyle(fontWeight: FontWeight.bold)),
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

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Simpan Draft'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final data = _buildPayload();
                            await context.read<OpgiAnomaliCubit>().saveDraft(
                              nama: '${_assetNamaController.text} - ${widget.garduIndukNama}',
                              date: DateTime.now().toIso8601String(),
                              data: data,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Draft anomali berhasil disimpan offline')),
                              );
                              Navigator.of(context).pop(true);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Kirim Laporan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final data = _buildPayload();
                            context.read<OpgiAnomaliCubit>().submitAnomali(
                              data: data,
                              imageFile: _fotoBukti,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
