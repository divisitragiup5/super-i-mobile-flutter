import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_il1_cubit.dart';

class InputIl1KubikelPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final int penyulangId;
  final String penyulangNama;

  const InputIl1KubikelPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.penyulangId,
    required this.penyulangNama,
  });

  @override
  State<InputIl1KubikelPage> createState() => _InputIl1KubikelPageState();
}

class _InputIl1KubikelPageState extends State<InputIl1KubikelPage> {
  final _formKey = GlobalKey<FormState>();

  String _statusPMT = 'CLOSE';
  String _rackPMT = 'RACK IN';
  String _kondisiSF6PMT = 'GOOD';
  String _indikatorPegas = 'CHARGE';
  String _bendaAsing = 'TIDAK';
  String _binatang = 'TIDAK';
  String _tetesanAir = 'TIDAK';
  String _desis = 'TIDAK';
  String _bau = 'TIDAK';
  final String _kondisiLVPanel = 'BERSIH';
  final String _lampuLVPanel = 'NYALA';
  final String _indikatorPMTClose = 'NYALA';
  final String _indikatorPMTOpen = 'TIDAK';
  final String _indikatorTegangan = 'NYALA';
  String _tampilanRelayOCR = 'NORMAL';
  final String _indikatorHealthyOCR = 'NYALA';
  final _arusNetralOCRController = TextEditingController(text: '0.0');
  final String _keteranganRelayUFR = 'TIDAK ADA';
  String _tampilanLCDKWH = 'NORMAL';
  final String _tombolKWH = 'NORMAL';
  final String _kondisiAlarm = 'ADA';
  String _keteranganAnomali = 'TIDAK ADA';
  final _anomaliDetailController = TextEditingController();

  XFile? _fotoInspeksi;
  XFile? _fotoAnomali;

  @override
  void dispose() {
    _arusNetralOCRController.dispose();
    _anomaliDetailController.dispose();
    super.dispose();
  }

  Future<void> _pickInspeksiPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) setState(() => _fotoInspeksi = photo);
  }

  Future<void> _pickAnomaliPhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (photo != null) setState(() => _fotoAnomali = photo);
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'penyulangId': widget.penyulangId,
      'timezone': 'Asia/Jakarta',
      'statusPMT': _statusPMT,
      'rackPMT': _rackPMT,
      'keteranganPMT': ['NORMAL'],
      'kondisiSF6PMT': _kondisiSF6PMT,
      'indikatorPegasMekanikPMT': _indikatorPegas,
      'bendaAsing': _bendaAsing,
      'binatang': _binatang,
      'tetesanAir': _tetesanAir,
      'desis': _desis,
      'bau': _bau,
      'kondisiLVPanel': _kondisiLVPanel,
      'lampuLVPanel': _lampuLVPanel,
      'indikatorPMTClose': _indikatorPMTClose,
      'indikatorPMTOpen': _indikatorPMTOpen,
      'indikatorTeganganKubikel': _indikatorTegangan,
      'tampilanLCDRelayOCR': _tampilanRelayOCR,
      'indikatorHealthyRelayOCR': _indikatorHealthyOCR,
      'pembacaanArusNetralRelayOCR': double.tryParse(_arusNetralOCRController.text) ?? 0.0,
      'keteranganRelayUFR': _keteranganRelayUFR,
      'tampilanLCDKWHMeter': _tampilanLCDKWH,
      'tombolKWHMeter': _tombolKWH,
      'kondisiAlarm': _kondisiAlarm,
      'keteranganAnomali': _keteranganAnomali,
      if (_keteranganAnomali == 'ADA')
        'anomali': _anomaliDetailController.text,
      'durasi': 120,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IL1 Kubikel - ${widget.penyulangNama}'),
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
                // 1. Kondisi PMT
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. Status & Mekanik PMT', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _statusPMT,
                          decoration: const InputDecoration(labelText: 'Status PMT', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'CLOSE', child: Text('CLOSE')),
                            DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                          ],
                          onChanged: (v) => setState(() => _statusPMT = v ?? _statusPMT),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _rackPMT,
                          decoration: const InputDecoration(labelText: 'Rack PMT', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'RACK IN', child: Text('RACK IN')),
                            DropdownMenuItem(value: 'RACK OUT', child: Text('RACK OUT')),
                          ],
                          onChanged: (v) => setState(() => _rackPMT = v ?? _rackPMT),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _kondisiSF6PMT,
                          decoration: const InputDecoration(labelText: 'Kondisi Gas SF6 PMT', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'GOOD', child: Text('GOOD')),
                            DropdownMenuItem(value: 'WARNING', child: Text('WARNING')),
                            DropdownMenuItem(value: 'NOT GOOD', child: Text('NOT GOOD')),
                          ],
                          onChanged: (v) => setState(() => _kondisiSF6PMT = v ?? _kondisiSF6PMT),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _indikatorPegas,
                          decoration: const InputDecoration(labelText: 'Indikator Pegas Mekanik PMT', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'CHARGE', child: Text('CHARGE')),
                            DropdownMenuItem(value: 'DISCHARGE', child: Text('DISCHARGE')),
                          ],
                          onChanged: (v) => setState(() => _indikatorPegas = v ?? _indikatorPegas),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Kebersihan & Lingkungan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('2. Kebersihan & Lingkungan Kubikel', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildChoice('Benda Asing', _bendaAsing, ['ADA', 'TIDAK'], (v) => setState(() => _bendaAsing = v)),
                        _buildChoice('Binatang', _binatang, ['ADA', 'TIDAK'], (v) => setState(() => _binatang = v)),
                        _buildChoice('Tetesan Air', _tetesanAir, ['ADA', 'TIDAK'], (v) => setState(() => _tetesanAir = v)),
                        _buildChoice('Desis / Corona', _desis, ['ADA', 'TIDAK'], (v) => setState(() => _desis = v)),
                        _buildChoice('Bau Gosong / Asing', _bau, ['ADA', 'TIDAK'], (v) => setState(() => _bau = v)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Relay & KWH Meter
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('3. Relay Proteksi & KWH Meter', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _tampilanRelayOCR,
                          decoration: const InputDecoration(labelText: 'Tampilan LCD Relay OCR', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'NORMAL', child: Text('NORMAL')),
                            DropdownMenuItem(value: 'BLANK', child: Text('BLANK')),
                          ],
                          onChanged: (v) => setState(() => _tampilanRelayOCR = v ?? _tampilanRelayOCR),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _arusNetralOCRController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Arus Netral Relay OCR (A)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _tampilanLCDKWH,
                          decoration: const InputDecoration(labelText: 'Tampilan LCD KWH Meter', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'NORMAL', child: Text('NORMAL')),
                            DropdownMenuItem(value: 'BLANK', child: Text('BLANK')),
                          ],
                          onChanged: (v) => setState(() => _tampilanLCDKWH = v ?? _tampilanLCDKWH),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Anomali
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('4. Anomali', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _keteranganAnomali,
                          decoration: const InputDecoration(labelText: 'Keterangan Anomali', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'TIDAK ADA', child: Text('TIDAK ADA')),
                            DropdownMenuItem(value: 'ADA', child: Text('ADA')),
                          ],
                          onChanged: (v) => setState(() => _keteranganAnomali = v ?? _keteranganAnomali),
                        ),
                        if (_keteranganAnomali == 'ADA') ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _anomaliDetailController,
                            decoration: const InputDecoration(labelText: 'Deskripsi Anomali *', border: OutlineInputBorder()),
                            validator: (v) => _keteranganAnomali == 'ADA' && (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: Text(_fotoAnomali == null ? 'Foto Bukti Anomali' : 'Foto Ulang Anomali'),
                            onPressed: _pickAnomaliPhoto,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Foto Bukti Inspeksi
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('5. Foto Bukti Inspeksi Kubikel *', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          onPressed: _pickInspeksiPhoto,
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
                            type: 'il1-kubikel',
                            nama: '${widget.penyulangNama} - ${widget.garduIndukNama}',
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
                          if (_formKey.currentState?.validate() ?? false) {
                            final files = <XFile>[];
                            if (_fotoInspeksi != null) files.add(_fotoInspeksi!);
                            if (_fotoAnomali != null) files.add(_fotoAnomali!);

                            final data = _buildPayload();
                            context.read<OpgiIl1Cubit>().submitKubikel(
                              data: data,
                              files: files,
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

  Widget _buildChoice(String label, String currentVal, List<String> options, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Row(
            children: options.map((opt) {
              final isSelected = currentVal == opt;
              return Padding(
                padding: const EdgeInsets.only(left: 6),
                child: ChoiceChip(
                  label: Text(opt, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  onSelected: (_) => onChanged(opt),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
