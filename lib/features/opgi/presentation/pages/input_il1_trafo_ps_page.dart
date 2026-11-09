import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_il1_cubit.dart';

class InputIl1TrafoPsPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final int trafoId;
  final String trafoNama;

  const InputIl1TrafoPsPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.trafoId,
    required this.trafoNama,
  });

  @override
  State<InputIl1TrafoPsPage> createState() => _InputIl1TrafoPsPageState();
}

class _InputIl1TrafoPsPageState extends State<InputIl1TrafoPsPage> {
  final _formKey = GlobalKey<FormState>();

  final _merkController = TextEditingController();
  final _noSeriController = TextEditingController();
  final _kapasitasController = TextEditingController();
  final _tahunController = TextEditingController();
  final _tapController = TextEditingController();

  String _jenisTrafo = 'INDOOR';
  String _kebocoranBody = 'TRAFO TIDAK ADA KEBOCORAN DI BODY TRAFO';
  String _kondisiFisik = 'MULUS BERSIH';
  String _kondisiRumah = 'ADA DAN BAIK';

  XFile? _fotoInspeksi;

  @override
  void dispose() {
    _merkController.dispose();
    _noSeriController.dispose();
    _kapasitasController.dispose();
    _tahunController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) setState(() => _fotoInspeksi = photo);
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'trafoId': widget.trafoId,
      'timezone': 'Asia/Jakarta',
      if (_merkController.text.isNotEmpty) 'merkTrafo': _merkController.text,
      if (_noSeriController.text.isNotEmpty) 'noSeriTrafo': _noSeriController.text,
      if (_kapasitasController.text.isNotEmpty)
        'kapasitasTrafo': int.tryParse(_kapasitasController.text),
      if (_tahunController.text.isNotEmpty)
        'tahunPembuatanTrafo': int.tryParse(_tahunController.text),
      if (_tapController.text.isNotEmpty)
        'tapTrafo': int.tryParse(_tapController.text),
      'jenisTrafo': _jenisTrafo,
      'kebocoranBodyTrafo': [_kebocoranBody],
      'kondisiFisikTrafo': [_kondisiFisik],
      'kondisiRumahTrafo': [_kondisiRumah],
      'durasi': 120,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IL1 Trafo PS - ${widget.trafoNama}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<OpgiIl1Cubit, OpgiIl1State>(
        listener: (context, state) {
          if (state is OpgiIl1Success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true);
          } else if (state is OpgiIl1Error) {
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
                // Spesifikasi Trafo
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Spesifikasi Trafo PS (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _jenisTrafo,
                          decoration: const InputDecoration(labelText: 'Tipe Penempatan', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'INDOOR', child: Text('INDOOR')),
                            DropdownMenuItem(value: 'OUTDOOR', child: Text('OUTDOOR')),
                          ],
                          onChanged: (v) => setState(() => _jenisTrafo = v ?? _jenisTrafo),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _merkController,
                          decoration: const InputDecoration(labelText: 'Merk Trafo', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _kapasitasController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Kapasitas (kVA)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _tapController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Tap Trafo', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kondisi Fisik & Lingkungan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Kondisi Visual Trafo', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _kebocoranBody,
                          decoration: const InputDecoration(labelText: 'Kebocoran Body Trafo', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(
                              value: 'TRAFO TIDAK ADA KEBOCORAN DI BODY TRAFO',
                              child: Text('TIDAK ADA KEBOCORAN'),
                            ),
                            DropdownMenuItem(
                              value: 'SALAH SATU PART ADA NODA REMBES TAPI TIDAK MENETES',
                              child: Text('REMBES TIDAK MENETES'),
                            ),
                            DropdownMenuItem(
                              value: 'BODY ADA REMBESAN DAN POTENSI MENETES LAMBAT',
                              child: Text('REMBES MENETES LAMBAT'),
                            ),
                            DropdownMenuItem(
                              value: 'BODY ADA REMBESAN DAN POTENSI MENETES CEPAT',
                              child: Text('REMBES MENETES CEPAT'),
                            ),
                          ],
                          onChanged: (v) => setState(() => _kebocoranBody = v ?? _kebocoranBody),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _kondisiFisik,
                          decoration: const InputDecoration(labelText: 'Kondisi Fisik Trafo', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'MULUS BERSIH', child: Text('MULUS BERSIH')),
                            DropdownMenuItem(value: 'MULUS KOTOR', child: Text('MULUS KOTOR')),
                            DropdownMenuItem(value: 'CACAT SIRIP MINOR', child: Text('CACAT SIRIP MINOR')),
                            DropdownMenuItem(value: 'CACAT SIRIP MAJOR', child: Text('CACAT SIRIP MAJOR')),
                            DropdownMenuItem(value: 'BENGKAK', child: Text('BENGKAK')),
                          ],
                          onChanged: (v) => setState(() => _kondisiFisik = v ?? _kondisiFisik),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _kondisiRumah,
                          decoration: const InputDecoration(labelText: 'Kondisi Rumah Trafo', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'ADA DAN BAIK', child: Text('ADA DAN BAIK')),
                            DropdownMenuItem(value: 'TIDAK ADA ATAP', child: Text('TIDAK ADA ATAP')),
                            DropdownMenuItem(value: 'PONDASI MIRING/TIDAK ADA PONDASI', child: Text('PONDASI RUSAK/MIRING')),
                            DropdownMenuItem(value: 'ADA POTENSI BINATANG', child: Text('POTENSI BINATANG')),
                          ],
                          onChanged: (v) => setState(() => _kondisiRumah = v ?? _kondisiRumah),
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
                        const Text('Foto Bukti Inspeksi Trafo PS *', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (_fotoInspeksi != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_fotoInspeksi!.path),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: Text(_fotoInspeksi == null ? 'Ambil Foto Bukti' : 'Foto Ulang'),
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
                          final data = _buildPayload();
                          await context.read<OpgiIl1Cubit>().saveDraft(
                            type: 'il1-trafo-ps',
                            nama: '${widget.trafoNama} - ${widget.garduIndukNama}',
                            date: DateTime.now().toIso8601String(),
                            data: data,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Draft berhasil disimpan offline')),
                            );
                            Navigator.of(context).pop(true);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Kirim ke Server'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_fotoInspeksi == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Foto bukti inspeksi wajib diambil'), backgroundColor: Colors.orange),
                            );
                            return;
                          }
                          if (_formKey.currentState?.validate() ?? false) {
                            final data = _buildPayload();
                            context.read<OpgiIl1Cubit>().submitTrafoPs(
                              data: data,
                              file: _fotoInspeksi!,
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
