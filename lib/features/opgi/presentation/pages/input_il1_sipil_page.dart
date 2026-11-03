import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_il1_cubit.dart';

class InputIl1SipilPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String gedung;
  final String gedungNama;

  const InputIl1SipilPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.gedung,
    required this.gedungNama,
  });

  @override
  State<InputIl1SipilPage> createState() => _InputIl1SipilPageState();
}

class _InputIl1SipilPageState extends State<InputIl1SipilPage> {
  final _formKey = GlobalKey<FormState>();

  // Penerangan
  String _kondisiLampu = 'BAIK';
  String _jenisLampu = 'LED';
  final _jumlahLampuController = TextEditingController(text: '8');
  final _jumlahLampuMatiController = TextEditingController(text: '0');
  final _keteranganLampuController = TextEditingController(text: 'Normal');

  // AC & Ruangan
  String _kondisiRuangan = 'TIDAK';
  final _jumlahAcNormalController = TextEditingController(text: '2');
  final _jumlahAcWindController = TextEditingController(text: '0');
  final _jumlahAcBocorController = TextEditingController(text: '0');
  final _keteranganAcController = TextEditingController(text: 'Dingin Normal');

  // Bangunan
  String _kondisiAtap = 'TIDAK';
  final _letakKebocoranController = TextEditingController();
  String _mainhole = 'TIDAK';
  String _powerSupplyAC = 'ADA';

  // DC / Baterai
  String _kebersihanDCBC = 'BERSIH';
  String _kebersihanRuangBaterai = 'BERSIH';
  final _suhuBateraiController = TextEditingController(text: '25.0');
  final _kelembabanBateraiController = TextEditingController(text: '60.0');
  String _kebersihanBaterai = 'BERSIH';
  String _kebocoranBaterai = 'TIDAK';
  String _exhaustFan = 'BERFUNGSI';
  String _kondisiRuangBaterai = 'TIDAK';
  final _teganganBebanController = TextEditingController(text: '110.0');
  final _arusBebanController = TextEditingController(text: '5.0');

  // Rectifier
  String _kondisiRectifier = 'BAIK';
  String _kebersihanRuangRectifier = 'BERSIH';
  final _suhuRectifierController = TextEditingController(text: '26.0');
  final _kelembabanRectifierController = TextEditingController(text: '55.0');
  String _kebersihanPanel = 'BERSIH';

  // Komunikasi
  String _kondisiMMI = 'BAIK';
  String _kondisiMouse = 'BAIK';
  String _kondisiKeyboard = 'BAIK';
  String _kondisiInternet = 'BAIK';
  String _kondisiRadio = 'BAIK';
  String _kondisiYealink = 'BAIK';

  XFile? _fotoInspeksi;

  @override
  void dispose() {
    _jumlahLampuController.dispose();
    _jumlahLampuMatiController.dispose();
    _keteranganLampuController.dispose();
    _jumlahAcNormalController.dispose();
    _jumlahAcWindController.dispose();
    _jumlahAcBocorController.dispose();
    _keteranganAcController.dispose();
    _letakKebocoranController.dispose();
    _suhuBateraiController.dispose();
    _kelembabanBateraiController.dispose();
    _teganganBebanController.dispose();
    _arusBebanController.dispose();
    _suhuRectifierController.dispose();
    _kelembabanRectifierController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) setState(() => _fotoInspeksi = photo);
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'timezone': 'Asia/Jakarta',
      'garduIndukId': widget.garduIndukId,
      'gedung': widget.gedung,
      'kondisiLampuPenerangan': _kondisiLampu,
      'jenisLampuPenerangan': _jenisLampu,
      'jumlahLampuPenerangan': int.tryParse(_jumlahLampuController.text) ?? 0,
      'jumlahLampuPeneranganMati': int.tryParse(_jumlahLampuMatiController.text) ?? 0,
      'keteranganLampuPenerangan': _keteranganLampuController.text,
      'kondisiRuangan': _kondisiRuangan,
      'jumlahACMenyalaNormal': int.tryParse(_jumlahAcNormalController.text) ?? 0,
      'jumlahACWindOnly': int.tryParse(_jumlahAcWindController.text) ?? 0,
      'jumlahACBocor': int.tryParse(_jumlahAcBocorController.text) ?? 0,
      'keteranganAc': _keteranganAcController.text,
      'kondisiAtap': _kondisiAtap,
      if (_kondisiAtap == 'BOCOR')
        'letakKebocoranAtap': _letakKebocoranController.text,
      'mainholeTergenangAir': _mainhole,
      'powerSupplyAC': _powerSupplyAC,
      'kebersihanPanelDCBC': _kebersihanDCBC,
      'kebersihanRuangBaterai': _kebersihanRuangBaterai,
      'suhuRuangBaterai': double.tryParse(_suhuBateraiController.text) ?? 0.0,
      'kelembabanRuangBaterai': double.tryParse(_kelembabanBateraiController.text) ?? 0.0,
      'kebersihanBaterai': _kebersihanBaterai,
      'kebocoranBaterai': _kebocoranBaterai,
      'exhaustFan': _exhaustFan,
      'kondisiRuangBaterai': _kondisiRuangBaterai,
      'teganganBeban': double.tryParse(_teganganBebanController.text) ?? 0.0,
      'arusBeban': double.tryParse(_arusBebanController.text) ?? 0.0,
      'kondisiRectifier': _kondisiRectifier,
      'kebersihanRuangRectifier': _kebersihanRuangRectifier,
      'suhuRuangRectifier': double.tryParse(_suhuRectifierController.text) ?? 0.0,
      'kelembabanRuangRectifier': double.tryParse(_kelembabanRectifierController.text) ?? 0.0,
      'kebersihanPanel': _kebersihanPanel,
      'kondisiMMI': _kondisiMMI,
      'kondisiMouseKomputer': _kondisiMouse,
      'kondisiKeyboardKomputer': _kondisiKeyboard,
      'kondisiInternet': _kondisiInternet,
      'kondisiRadio': _kondisiRadio,
      'kondisiYealink': _kondisiYealink,
      'durasi': 180,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IL1 Sipil - ${widget.gedungNama}'),
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
                // 1. Lampu Penerangan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. Lampu Penerangan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _kondisiLampu,
                                decoration: const InputDecoration(labelText: 'Kondisi Lampu', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'BAIK', child: Text('BAIK')),
                                  DropdownMenuItem(value: 'TIDAK', child: Text('TIDAK BAIK')),
                                ],
                                onChanged: (v) => setState(() => _kondisiLampu = v ?? _kondisiLampu),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _jenisLampu,
                                decoration: const InputDecoration(labelText: 'Jenis Lampu', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'LED', child: Text('LED')),
                                  DropdownMenuItem(value: 'TL', child: Text('TL')),
                                ],
                                onChanged: (v) => setState(() => _jenisLampu = v ?? _jenisLampu),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _jumlahLampuController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Jumlah Total', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _jumlahLampuMatiController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Jumlah Mati', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _keteranganLampuController,
                          decoration: const InputDecoration(labelText: 'Keterangan Lampu', border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Pendingin & Ruangan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('2. Pendingin Udara (AC) & Ruangan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _kondisiRuangan,
                          decoration: const InputDecoration(labelText: 'Kondisi Ruangan Panas?', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'TIDAK', child: Text('TIDAK (NORMAL)')),
                            DropdownMenuItem(value: 'PANAS', child: Text('PANAS')),
                          ],
                          onChanged: (v) => setState(() => _kondisiRuangan = v ?? _kondisiRuangan),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _jumlahAcNormalController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'AC Normal', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _jumlahAcWindController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'AC Wind Only', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _jumlahAcBocorController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'AC Bocor', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. DC, Baterai, & Rectifier
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('3. Ruang DC, Baterai & Rectifier', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _suhuBateraiController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Suhu Baterai (°C)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _kelembabanBateraiController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Kelembaban (%)', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _teganganBebanController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Tegangan Beban (V)', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _arusBebanController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Arus Beban (A)', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Foto Bukti
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Foto Bukti Inspeksi Sipil *', style: TextStyle(fontWeight: FontWeight.bold)),
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

                // Buttons
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
                            type: 'il1-sipil',
                            nama: '${widget.gedungNama} - ${widget.garduIndukNama}',
                            date: DateTime.now().toIso8601String(),
                            data: data,
                          );
                          if (mounted) {
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
                            context.read<OpgiIl1Cubit>().submitSipil(
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
