import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../data/models/ppl_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../cubit/ppl_cubit.dart';

class PplFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialDraft;
  final int? draftId;

  const PplFormPage({
    super.key,
    this.initialDraft,
    this.draftId,
  });

  @override
  State<PplFormPage> createState() => _PplFormPageState();
}

class _PplFormPageState extends State<PplFormPage> {
  TowerAssetModel? _selectedTower;

  final TextEditingController _namaPekerjaanCtrl = TextEditingController();
  String _jenisObjek = 'Rumah';
  final TextEditingController _ketJenisObjekCtrl = TextEditingController();
  String _kategoriObjek = 'Aman';
  final TextEditingController _ketKategoriObjekCtrl = TextEditingController();
  String _statusObjek = 'Permanen';
  String _statusPekerjaan = 'Tidak Ada Aktifitas';
  final TextEditingController _progressPekerjaanCtrl = TextEditingController();
  final TextEditingController _pihakPelaksanaCtrl = TextEditingController();
  final TextEditingController _pjPekerjaanCtrl = TextEditingController();
  final TextEditingController _noTeleponPJCtrl = TextEditingController();
  final TextEditingController _tanggapanCtrl = TextEditingController();
  final TextEditingController _namaValidatorCtrl = TextEditingController();

  DateTime _suratSosialisasi = DateTime.now();
  final TextEditingController _lokasiCtrl = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  File? _dokumentasiPerwakilan;
  File? _dokumentasiObjek;
  File? _dokumentasiSekitar;

  File? _ttdLineWalker;
  final TextEditingController _namaTTDLineWalkerCtrl = TextEditingController();

  File? _ttdPJPekerjaan;
  final TextEditingController _namaTTDPJPekerjaanCtrl = TextEditingController();

  File? _ttdTLGI;
  final TextEditingController _namaTTDTLGICtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PplCubit>().loadTowers();
    _fetchCurrentLocation();
    _loadInitialDraft();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition();
      setState(() {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        if (_lokasiCtrl.text.isEmpty) {
          _lokasiCtrl.text = 'Lat: ${_latitude.toStringAsFixed(6)}, Long: ${_longitude.toStringAsFixed(6)}';
        }
      });
    } catch (_) {}
  }

  void _loadInitialDraft() {
    if (widget.initialDraft != null) {
      final d = widget.initialDraft!;
      if (d['towerId'] != null) {
        _selectedTower = TowerAssetModel(
          id: d['towerId'] as int,
          nama: d['namaTower']?.toString() ?? 'Tower',
        );
      }
      _namaPekerjaanCtrl.text = d['namaPekerjaan'] ?? '';
      _jenisObjek = d['jenisObjek'] ?? 'Rumah';
      _ketJenisObjekCtrl.text = d['keteranganJenisObjek'] ?? '';
      _kategoriObjek = d['kategoriObjek'] ?? 'Aman';
      _ketKategoriObjekCtrl.text = d['keteranganKategoriObjek'] ?? '';
      _statusObjek = d['statusObjek'] ?? 'Permanen';
      _statusPekerjaan = d['statusPekerjaan'] ?? 'Tidak Ada Aktifitas';
      _progressPekerjaanCtrl.text = d['progressPekerjaan'] ?? '';
      _pihakPelaksanaCtrl.text = d['pihakPelaksana'] ?? '';
      _pjPekerjaanCtrl.text = d['pjPekerjaan'] ?? '';
      _noTeleponPJCtrl.text = d['noTeleponPJPekerjaan'] ?? '';
      _tanggapanCtrl.text = d['tanggapan'] ?? '';
      _namaValidatorCtrl.text = d['namaValidator'] ?? '';
      if (d['suratSosialisasi'] != null) {
        _suratSosialisasi = DateTime.tryParse(d['suratSosialisasi']) ?? DateTime.now();
      }
      _lokasiCtrl.text = d['lokasi'] ?? '';
      _latitude = (d['latitude'] as num?)?.toDouble() ?? 0.0;
      _longitude = (d['longitude'] as num?)?.toDouble() ?? 0.0;

      if (d['dokumentasiPerwakilanPath'] != null) _dokumentasiPerwakilan = File(d['dokumentasiPerwakilanPath']);
      if (d['dokumentasiObjekPath'] != null) _dokumentasiObjek = File(d['dokumentasiObjekPath']);
      if (d['dokumentasiSekitarPath'] != null) _dokumentasiSekitar = File(d['dokumentasiSekitarPath']);

      if (d['ttdLineWalkerPath'] != null) _ttdLineWalker = File(d['ttdLineWalkerPath']);
      _namaTTDLineWalkerCtrl.text = d['namaTTDLineWalker'] ?? '';

      if (d['ttdPJPekerjaanPath'] != null) _ttdPJPekerjaan = File(d['ttdPJPekerjaanPath']);
      _namaTTDPJPekerjaanCtrl.text = d['namaTTDPJPekerjaan'] ?? '';

      if (d['ttdTLGIPath'] != null) _ttdTLGI = File(d['ttdTLGIPath']);
      _namaTTDTLGICtrl.text = d['namaTTDTLGI'] ?? '';
    }
  }

  @override
  void dispose() {
    _namaPekerjaanCtrl.dispose();
    _ketJenisObjekCtrl.dispose();
    _ketKategoriObjekCtrl.dispose();
    _progressPekerjaanCtrl.dispose();
    _pihakPelaksanaCtrl.dispose();
    _pjPekerjaanCtrl.dispose();
    _noTeleponPJCtrl.dispose();
    _tanggapanCtrl.dispose();
    _namaValidatorCtrl.dispose();
    _lokasiCtrl.dispose();
    _namaTTDLineWalkerCtrl.dispose();
    _namaTTDPJPekerjaanCtrl.dispose();
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

  PPLInputModel _buildInputModel() {
    return PPLInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      namaPekerjaan: _namaPekerjaanCtrl.text.trim(),
      jenisObjek: _jenisObjek,
      keteranganJenisObjek: _ketJenisObjekCtrl.text.trim(),
      kategoriObjek: _kategoriObjek,
      keteranganKategoriObjek: _ketKategoriObjekCtrl.text.trim(),
      statusObjek: _statusObjek,
      statusPekerjaan: _statusPekerjaan,
      progressPekerjaan: _progressPekerjaanCtrl.text.trim(),
      pihakPelaksana: _pihakPelaksanaCtrl.text.trim(),
      pjPekerjaan: _pjPekerjaanCtrl.text.trim(),
      noTeleponPJPekerjaan: _noTeleponPJCtrl.text.trim(),
      tanggapan: _tanggapanCtrl.text.trim(),
      namaValidator: _namaValidatorCtrl.text.trim(),
      suratSosialisasi: _suratSosialisasi,
      lokasi: _lokasiCtrl.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      dokumentasiPerwakilan: _dokumentasiPerwakilan,
      dokumentasiObjek: _dokumentasiObjek,
      dokumentasiSekitar: _dokumentasiSekitar,
      ttdLineWalker: _ttdLineWalker,
      namaTTDLineWalker: _namaTTDLineWalkerCtrl.text.trim(),
      ttdPJPekerjaan: _ttdPJPekerjaan,
      namaTTDPJPekerjaan: _namaTTDPJPekerjaanCtrl.text.trim(),
      ttdTLGI: _ttdTLGI,
      namaTTDTLGI: _namaTTDTLGICtrl.text.isNotEmpty ? _namaTTDTLGICtrl.text.trim() : null,
    );
  }

  Future<void> _handleSaveDraft() async {
    final input = _buildInputModel();
    await context.read<PplCubit>().saveDraft(input);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data PPL berhasil disimpan sebagai draft offline'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  void _handleSubmit() {
    if (_selectedTower == null) {
      _showError('Pilih objek tower terlebih dahulu');
      return;
    }
    if (_namaPekerjaanCtrl.text.trim().isEmpty) {
      _showError('Nama pekerjaan wajib diisi');
      return;
    }
    if (_pihakPelaksanaCtrl.text.trim().isEmpty) {
      _showError('Pihak pelaksana wajib diisi');
      return;
    }
    if (_pjPekerjaanCtrl.text.trim().isEmpty) {
      _showError('Penanggung jawab pekerjaan wajib diisi');
      return;
    }
    if (_noTeleponPJCtrl.text.trim().isEmpty) {
      _showError('Nomor telepon penanggung jawab wajib diisi');
      return;
    }
    if (_namaTTDLineWalkerCtrl.text.trim().isEmpty || _ttdLineWalker == null) {
      _showError('Tanda tangan dan nama Line Walker wajib diisi');
      return;
    }
    if (_namaTTDPJPekerjaanCtrl.text.trim().isEmpty || _ttdPJPekerjaan == null) {
      _showError('Tanda tangan dan nama PJ Pekerjaan wajib diisi');
      return;
    }

    final input = _buildInputModel();
    context.read<PplCubit>().submitPpl(input, draftId: widget.draftId);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input PPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Simpan Draft',
            icon: const Icon(Icons.save_outlined),
            onPressed: _handleSaveDraft,
          ),
        ],
      ),
      body: BlocConsumer<PplCubit, PplState>(
        listener: (context, state) {
          if (state is PplSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
            context.pop();
          } else if (state is PplSubmitFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger,
                action: SnackBarAction(
                  label: 'Simpan Offline',
                  textColor: Colors.white,
                  onPressed: _handleSaveDraft,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PplSubmitting;
          List<TowerAssetModel> towers = [];
          if (state is PplLoaded) {
            towers = state.towers;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section 1: Objek Tower & Identitas
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATA PEKERJAAN & OBJEK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SearchableDropdown<int>(
                          label: 'Tower',
                          hint: 'Pilih tower...',
                          isRequired: true,
                          value: _selectedTower?.id,
                          items: towers
                              .map((t) => DropdownItem<int>(value: t.id, label: t.nama))
                              .toList(),
                          onChanged: (id) {
                            if (id != null) {
                              final tower = towers.firstWhere((t) => t.id == id);
                              setState(() => _selectedTower = tower);
                              context.read<PplCubit>().selectTower(tower);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _namaPekerjaanCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nama Pekerjaan *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _jenisObjek,
                          decoration: InputDecoration(
                            labelText: 'Jenis Objek',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: [
                            'Rumah', 'Gedung', 'Bangunan', 'Kegiatan', 'Pekerjaan', 'Proyek', 'Lain-lain'
                          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _jenisObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ketJenisObjekCtrl,
                          decoration: InputDecoration(
                            labelText: 'Keterangan Jenis Objek',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _kategoriObjek,
                          decoration: InputDecoration(
                            labelText: 'Kategori Objek',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Aman', 'Bahaya', 'Waspada', 'Kritis']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _kategoriObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ketKategoriObjekCtrl,
                          decoration: InputDecoration(
                            labelText: 'Keterangan Kategori Objek',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _statusObjek,
                          decoration: InputDecoration(
                            labelText: 'Status Objek',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Permanen', 'Sementara', 'Sedang Berjalan']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _statusObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _statusPekerjaan,
                          decoration: InputDecoration(
                            labelText: 'Status Pekerjaan',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Tidak Ada Aktifitas', 'In Progess', 'Selesai']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _statusPekerjaan = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _progressPekerjaanCtrl,
                          decoration: InputDecoration(
                            labelText: 'Progress Pekerjaan',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section 2: Pelaksana & Penanggung Jawab
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PELAKSANA & PENANGGUNG JAWAB',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pihakPelaksanaCtrl,
                          decoration: InputDecoration(
                            labelText: 'Pihak Pelaksana *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pjPekerjaanCtrl,
                          decoration: InputDecoration(
                            labelText: 'PJ Pekerjaan *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noTeleponPJCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'No. Telepon PJ Pekerjaan *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tanggapanCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Tanggapan',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _namaValidatorCtrl,
                          decoration: InputDecoration(
                            labelText: 'Nama Validator',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Surat Sosialisasi'),
                          subtitle: Text(DateFormat('dd MMMM yyyy').format(_suratSosialisasi)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _suratSosialisasi,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setState(() => _suratSosialisasi = picked);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _lokasiCtrl,
                          decoration: InputDecoration(
                            labelText: 'Lokasi',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section 3: Dokumentasi Foto
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        FieldPictInput(
                          label: 'Dokumentasi Perwakilan',
                          placeholder: 'Ambil Foto Perwakilan',
                          pictureFile: _dokumentasiPerwakilan,
                          onChange: (f) => setState(() => _dokumentasiPerwakilan = f),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Dokumentasi Objek',
                          placeholder: 'Ambil Foto Objek',
                          pictureFile: _dokumentasiObjek,
                          onChange: (f) => setState(() => _dokumentasiObjek = f),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Dokumentasi Sekitar',
                          placeholder: 'Ambil Foto Sekitar Objek',
                          pictureFile: _dokumentasiSekitar,
                          onChange: (f) => setState(() => _dokumentasiSekitar = f),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Section 4: Tanda Tangan
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TANDA TANGAN DIGITAL',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // TTD Line Walker
                        _buildSignatureSection(
                          title: 'Tanda Tangan Line Walker *',
                          file: _ttdLineWalker,
                          nameCtrl: _namaTTDLineWalkerCtrl,
                          nameLabel: 'Nama Lengkap Line Walker *',
                          onSign: () async {
                            final base64 = await FieldSignaturePad.show(
                              context,
                              title: 'TTD Line Walker',
                              signerName: _namaTTDLineWalkerCtrl.text,
                            );
                            if (base64 != null) {
                              final f = await _base64ToFile(base64, 'ttdLineWalker');
                              setState(() => _ttdLineWalker = f);
                            }
                          },
                        ),
                        const Divider(height: 32),

                        // TTD PJ Pekerjaan
                        _buildSignatureSection(
                          title: 'Tanda Tangan PJ Pekerjaan *',
                          file: _ttdPJPekerjaan,
                          nameCtrl: _namaTTDPJPekerjaanCtrl,
                          nameLabel: 'Nama Lengkap PJ Pekerjaan *',
                          onSign: () async {
                            final base64 = await FieldSignaturePad.show(
                              context,
                              title: 'TTD PJ Pekerjaan',
                              signerName: _namaTTDPJPekerjaanCtrl.text,
                            );
                            if (base64 != null) {
                              final f = await _base64ToFile(base64, 'ttdPJPekerjaan');
                              setState(() => _ttdPJPekerjaan = f);
                            }
                          },
                        ),
                        const Divider(height: 32),

                        // TTD TL GI (Opsional)
                        _buildSignatureSection(
                          title: 'Tanda Tangan TL GI (Opsional)',
                          file: _ttdTLGI,
                          nameCtrl: _namaTTDTLGICtrl,
                          nameLabel: 'Nama Lengkap TL GI',
                          onSign: () async {
                            final base64 = await FieldSignaturePad.show(
                              context,
                              title: 'TTD TL GI',
                              signerName: _namaTTDTLGICtrl.text,
                            );
                            if (base64 != null) {
                              final f = await _base64ToFile(base64, 'ttdTLGI');
                              setState(() => _ttdTLGI = f);
                            }
                          },
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
                          'Simpan PPL',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignatureSection({
    required String title,
    required File? file,
    required TextEditingController nameCtrl,
    required String nameLabel,
    required VoidCallback onSign,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: nameLabel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        if (file != null) ...[
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Image.file(file, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: onSign,
          icon: const Icon(Icons.draw_outlined),
          label: Text(file != null ? 'Ubah Tanda Tangan' : 'Buat Tanda Tangan'),
        ),
      ],
    );
  }
}
