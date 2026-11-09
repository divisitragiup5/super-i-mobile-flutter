import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_label.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../../home/presentation/cubit/drafts_cubit.dart';
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
  String? _jenisObjek;
  final TextEditingController _ketJenisObjekCtrl = TextEditingController();
  String? _kategoriObjek;
  final TextEditingController _ketKategoriObjekCtrl = TextEditingController();
  String? _statusObjek;
  String? _statusPekerjaan;
  final TextEditingController _progressPekerjaanCtrl = TextEditingController();
  final TextEditingController _pihakPelaksanaCtrl = TextEditingController();
  final TextEditingController _pjPekerjaanCtrl = TextEditingController();
  final TextEditingController _noTeleponPJCtrl = TextEditingController();
  final TextEditingController _tanggapanCtrl = TextEditingController();
  final TextEditingController _namaValidatorCtrl = TextEditingController();

  DateTime? _suratSosialisasi;
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

  String _identifier = '';
  bool _isPartialDisabled = false;

  @override
  void initState() {
    super.initState();
    final rawId = widget.initialDraft?['identifier']?.toString();
    _identifier = (rawId != null && rawId.isNotEmpty)
        ? rawId
        : 'ppl-${DateTime.now().millisecondsSinceEpoch}';
    _isPartialDisabled = widget.initialDraft?['partialDisabled'] == 'true' ||
        widget.initialDraft?['partialDisabled'] == true;

    _namaTTDTLGICtrl.addListener(_onFieldChanged);
    context.read<PplCubit>().loadTowers();
    _fetchCurrentLocation();
    _loadInitialDraft();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
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
      if (d['towerId'] != null || d['tower'] != null || d['namaTower'] != null) {
        final tId = d['towerId'] ?? (d['tower'] is Map ? d['tower']['id'] : null);
        final tNama = d['namaTower'] ?? (d['tower'] is Map ? d['tower']['nama'] : null) ?? 'Tower';
        if (tId != null) {
          final parsedId = tId is int ? tId : int.tryParse('$tId') ?? 0;
          _selectedTower = TowerAssetModel(
            id: parsedId,
            nama: tNama.toString(),
          );
        }
      }
      _namaPekerjaanCtrl.text = d['namaPekerjaan'] ?? '';
      _jenisObjek = d['jenisObjek']?.toString();
      _ketJenisObjekCtrl.text = d['keteranganJenisObjek'] ?? '';
      _kategoriObjek = d['kategoriObjek']?.toString();
      _ketKategoriObjekCtrl.text = d['keteranganKategoriObjek'] ?? '';
      _statusObjek = d['statusObjek']?.toString();
      _statusPekerjaan = d['statusPekerjaan']?.toString();
      _progressPekerjaanCtrl.text = d['progressPekerjaan'] ?? '';
      _pihakPelaksanaCtrl.text = d['pihakPelaksana'] ?? '';
      _pjPekerjaanCtrl.text = d['pjPekerjaan'] ?? '';
      _noTeleponPJCtrl.text = d['noTeleponPJPekerjaan'] ?? '';
      _tanggapanCtrl.text = d['tanggapan'] ?? '';
      _namaValidatorCtrl.text = d['namaValidator'] ?? '';
      if (d['suratSosialisasi'] != null) {
        _suratSosialisasi = DateTime.tryParse(d['suratSosialisasi'].toString());
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
    _namaTTDTLGICtrl.removeListener(_onFieldChanged);
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

  PPLInputModel _buildInputModel() {
    return PPLInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      identifier: _identifier,
      namaPekerjaan: _namaPekerjaanCtrl.text.trim(),
      jenisObjek: _jenisObjek ?? '',
      keteranganJenisObjek: _ketJenisObjekCtrl.text.trim(),
      kategoriObjek: _kategoriObjek ?? '',
      keteranganKategoriObjek: _ketKategoriObjekCtrl.text.trim(),
      statusObjek: _statusObjek ?? '',
      statusPekerjaan: _statusPekerjaan ?? '',
      progressPekerjaan: _progressPekerjaanCtrl.text.trim(),
      pihakPelaksana: _pihakPelaksanaCtrl.text.trim(),
      pjPekerjaan: _pjPekerjaanCtrl.text.trim(),
      noTeleponPJPekerjaan: _noTeleponPJCtrl.text.trim(),
      tanggapan: _tanggapanCtrl.text.trim(),
      namaValidator: _namaValidatorCtrl.text.trim(),
      suratSosialisasi: _suratSosialisasi ?? DateTime.now(),
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

  String? _validateForm() {
    if (_selectedTower == null) {
      return 'Pilih objek tower terlebih dahulu';
    }
    if (_namaPekerjaanCtrl.text.trim().isEmpty) {
      return 'Nama pekerjaan wajib diisi';
    }
    if (_jenisObjek == null || _jenisObjek!.isEmpty) {
      return 'Pilih jenis objek terlebih dahulu';
    }
    if (_ketJenisObjekCtrl.text.trim().isEmpty) {
      return 'Keterangan jenis objek wajib diisi';
    }
    if (_kategoriObjek == null || _kategoriObjek!.isEmpty) {
      return 'Pilih kategori objek terlebih dahulu';
    }
    if (_ketKategoriObjekCtrl.text.trim().isEmpty) {
      return 'Keterangan kategori objek wajib diisi';
    }
    if (_statusObjek == null || _statusObjek!.isEmpty) {
      return 'Pilih status objek terlebih dahulu';
    }
    if (_statusPekerjaan == null || _statusPekerjaan!.isEmpty) {
      return 'Pilih status pekerjaan terlebih dahulu';
    }
    if (_progressPekerjaanCtrl.text.trim().isEmpty) {
      return 'Progress pekerjaan wajib diisi';
    }
    if (_pihakPelaksanaCtrl.text.trim().isEmpty) {
      return 'Pihak pelaksana wajib diisi';
    }
    if (_pjPekerjaanCtrl.text.trim().isEmpty) {
      return 'Penanggung jawab pekerjaan wajib diisi';
    }
    if (_noTeleponPJCtrl.text.trim().isEmpty) {
      return 'Nomor telepon penanggung jawab wajib diisi';
    }
    if (_tanggapanCtrl.text.trim().isEmpty) {
      return 'Tanggapan wajib diisi';
    }
    if (_namaValidatorCtrl.text.trim().isEmpty) {
      return 'Nama validator wajib diisi';
    }
    if (_suratSosialisasi == null) {
      return 'Pilih tanggal surat sosialisasi terlebih dahulu';
    }
    if (_dokumentasiPerwakilan == null) {
      return 'Foto dokumentasi perwakilan wajib diambil';
    }
    if (_dokumentasiObjek == null) {
      return 'Foto dokumentasi objek wajib diambil';
    }
    if (_dokumentasiSekitar == null) {
      return 'Foto dokumentasi sekitar wajib diambil';
    }
    if (_namaTTDLineWalkerCtrl.text.trim().isEmpty || _ttdLineWalker == null) {
      return 'Tanda tangan dan nama Line Walker wajib diisi';
    }
    if (_namaTTDPJPekerjaanCtrl.text.trim().isEmpty || _ttdPJPekerjaan == null) {
      return 'Tanda tangan dan nama PJ Pekerjaan wajib diisi';
    }
    if ((_ttdTLGI != null && _namaTTDTLGICtrl.text.trim().isEmpty) ||
        (_ttdTLGI == null && _namaTTDTLGICtrl.text.trim().isNotEmpty)) {
      return 'Lengkapi tanda tangan dan nama Team Leader GI jika diisi';
    }
    return null;
  }

  Future<void> _handleSaveDraft() async {
    final error = _validateForm();
    if (error != null) {
      _showError(error);
      return;
    }

    final input = _buildInputModel();
    await context.read<PplCubit>().saveDraft(input);
    try {
      sl<DraftsCubit>().loadDrafts();
    } catch (_) {}
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        'Data PPL berhasil disimpan sebagai draft offline',
      );
      context.pop();
    }
  }

  void _handleSubmit() {
    final error = _validateForm();
    if (error != null) {
      _showError(error);
      return;
    }

    final input = _buildInputModel();
    context.read<PplCubit>().submitPpl(input, draftId: widget.draftId);
  }

  void _showError(String message) {
    AppSnackbar.showError(context, message);
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
            AppSnackbar.showSuccess(context, state.message);
            context.pop();
          } else if (state is PplSubmitFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PplSubmitting;
          List<TowerAssetModel> towers = [];
          if (state is PplLoaded) {
            towers = state.towers;
            if (_selectedTower != null && (_selectedTower!.nama == 'Tower' || _selectedTower!.nama.isEmpty)) {
              final matching = towers.where((t) => t.id == _selectedTower!.id).firstOrNull;
              if (matching != null) {
                _selectedTower = matching;
              }
            }
          }

          final List<DropdownItem<int>> towerItems = towers
              .map((t) => DropdownItem<int>(value: t.id, label: t.nama))
              .toList();

          if (_selectedTower != null &&
              !towerItems.any((it) => it.value == _selectedTower!.id)) {
            towerItems.insert(
              0,
              DropdownItem<int>(
                value: _selectedTower!.id,
                label: _selectedTower!.nama,
              ),
            );
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
                        Opacity(
                          opacity: _isPartialDisabled ? 0.7 : 1.0,
                          child: IgnorePointer(
                            ignoring: _isPartialDisabled,
                            child: SearchableDropdown<int>(
                              label: 'Tower',
                              hint: 'Pilih tower...',
                              isRequired: true,
                              isLoading: state is PplLoading || (towers.isEmpty && state is! PplLoaded),
                              value: _selectedTower?.id,
                              items: towerItems,
                              onChanged: (id) {
                                if (id != null) {
                                  final tower = towerItems.firstWhere((t) => t.value == id);
                                  setState(() => _selectedTower = TowerAssetModel(id: tower.value, nama: tower.label));
                                  context.read<PplCubit>().selectTower(TowerAssetModel(id: tower.value, nama: tower.label));
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _namaPekerjaanCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Nama Pekerjaan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _jenisObjek,
                          hint: const Text('Pilih jenis objek'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Jenis Objek', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: [
                            'Rumah', 'Gedung', 'Bangunan', 'Kegiatan', 'Pekerjaan', 'Proyek', 'Lain-lain'
                          ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          onChanged: (val) {
                            setState(() => _jenisObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ketJenisObjekCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Keterangan Jenis Objek', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _kategoriObjek,
                          hint: const Text('Pilih kategori objek'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Kategori Objek', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Aman', 'Bahaya', 'Waspada', 'Kritis']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _kategoriObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ketKategoriObjekCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Keterangan Kategori Objek', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _statusObjek,
                          hint: const Text('Pilih status objek'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Status Objek', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Permanen', 'Sementara', 'Sedang Berjalan']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _statusObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _statusPekerjaan,
                          hint: const Text('Pilih status pekerjaan'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Status Pekerjaan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: ['Tidak Ada Aktifitas', 'In Progess', 'Selesai']
                              .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: (val) {
                            setState(() => _statusPekerjaan = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _progressPekerjaanCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Progress Pekerjaan', isRequired: true),
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
                            label: const AppInputLabel('Pihak Pelaksana', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pjPekerjaanCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('PJ Pekerjaan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _noTeleponPJCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            label: const AppInputLabel('No. Telepon PJ Pekerjaan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tanggapanCtrl,
                          maxLines: 2,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Tanggapan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _namaValidatorCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Nama Validator', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const AppInputLabel('Surat Sosialisasi', isRequired: true),
                          subtitle: Text(
                            _suratSosialisasi != null
                                ? DateFormat('dd MMMM yyyy').format(_suratSosialisasi!)
                                : 'Pilih tanggal surat sosialisasi',
                            style: TextStyle(
                              color: _suratSosialisasi != null ? Colors.black87 : Colors.grey.shade600,
                            ),
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _suratSosialisasi ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) setState(() => _suratSosialisasi = picked);
                          },
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
                          isRequired: true,
                          forceLandscape: true,
                          pictureFile: _dokumentasiPerwakilan,
                          onChange: (f) => setState(() => _dokumentasiPerwakilan = f),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Dokumentasi Objek',
                          placeholder: 'Ambil Foto Objek',
                          isRequired: true,
                          forceLandscape: true,
                          pictureFile: _dokumentasiObjek,
                          onChange: (f) => setState(() => _dokumentasiObjek = f),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Dokumentasi Sekitar',
                          placeholder: 'Ambil Foto Sekitar Objek',
                          isRequired: true,
                          forceLandscape: true,
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
                        FieldSignatureInput(
                          label: 'Tanda Tangan Line Walker',
                          isRequired: true,
                          signatureFile: _ttdLineWalker,
                          signerName: _namaTTDLineWalkerCtrl.text,
                          onSignatureChanged: (file) => setState(() => _ttdLineWalker = file),
                          onNameChanged: (name) => setState(() => _namaTTDLineWalkerCtrl.text = name),
                        ),
                        const Divider(height: 32),

                        // TTD PJ Pekerjaan
                        FieldSignatureInput(
                          label: 'Tanda Tangan PJ Pekerjaan',
                          isRequired: true,
                          signatureFile: _ttdPJPekerjaan,
                          signerName: _namaTTDPJPekerjaanCtrl.text,
                          onSignatureChanged: (file) => setState(() => _ttdPJPekerjaan = file),
                          onNameChanged: (name) => setState(() => _namaTTDPJPekerjaanCtrl.text = name),
                        ),
                        const Divider(height: 32),

                        // TTD TL GI (Opsional)
                        FieldSignatureInput(
                          label: 'Tanda Tangan TL GI (Opsional)',
                          isRequired: false,
                          signatureFile: _ttdTLGI,
                          signerName: _namaTTDTLGICtrl.text,
                          onSignatureChanged: (file) => setState(() => _ttdTLGI = file),
                          onNameChanged: (name) => setState(() => _namaTTDTLGICtrl.text = name),
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
}
