import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../data/models/kegiatan_sosial_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../cubit/kegiatan_sosial_cubit.dart';

class KegiatanSosialFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialDraft;
  final int? draftId;

  const KegiatanSosialFormPage({
    super.key,
    this.initialDraft,
    this.draftId,
  });

  @override
  State<KegiatanSosialFormPage> createState() => _KegiatanSosialFormPageState();
}

class _KegiatanSosialFormPageState extends State<KegiatanSosialFormPage> {
  TowerAssetModel? _selectedTower;

  String _jenisAktivitas = 'LAYANG-LAYANG';
  String _statusAktivitas = 'MASIH BERLANGSUNG';
  String _progresPenanganan = 'SWEEPING';
  String _tindakan = 'SUDAH DIEKSEKUSI';
  final TextEditingController _keteranganCtrl = TextEditingController();
  String _statusObjek = 'PERMANEN';
  final TextEditingController _pelakuAktivitasCtrl = TextEditingController();
  final TextEditingController _tanggapanCtrl = TextEditingController();

  String _temuan = 'TIDAK ADA TEMUAN';
  final TextEditingController _jumlahTemuanCtrl = TextEditingController();

  final TextEditingController _lokasiCtrl = TextEditingController();
  double _latitude = 0.0;
  double _longitude = 0.0;

  File? _dokumentasiSosialisasi;
  File? _dokumentasiAktivitasSosial;

  File? _ttdLineWalker;
  final TextEditingController _namaTTDLineWalkerCtrl = TextEditingController();

  File? _ttdTLGI;
  final TextEditingController _namaTTDTLGICtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<KegiatanSosialCubit>().loadTowers();
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
      _jenisAktivitas = d['jenisAktivitas'] ?? 'LAYANG-LAYANG';
      _statusAktivitas = d['statusAktivitas'] ?? 'MASIH BERLANGSUNG';
      _progresPenanganan = d['progresPenanganan'] ?? 'SWEEPING';
      _tindakan = d['tindakan'] ?? 'SUDAH DIEKSEKUSI';
      _keteranganCtrl.text = d['keterangan'] ?? '';
      _statusObjek = d['statusObjek'] ?? 'PERMANEN';
      _pelakuAktivitasCtrl.text = d['pelakuAktivitasSosial'] ?? '';
      _tanggapanCtrl.text = d['tanggapan'] ?? '';
      _temuan = d['temuan'] ?? 'TIDAK ADA TEMUAN';
      if (d['jumlahTemuan'] != null) _jumlahTemuanCtrl.text = d['jumlahTemuan'].toString();
      _lokasiCtrl.text = d['lokasi'] ?? '';
      _latitude = (d['latitude'] as num?)?.toDouble() ?? 0.0;
      _longitude = (d['longitude'] as num?)?.toDouble() ?? 0.0;

      if (d['dokumentasiSosialisasiPath'] != null) _dokumentasiSosialisasi = File(d['dokumentasiSosialisasiPath']);
      if (d['dokumentasiAktivitasSosialPath'] != null) _dokumentasiAktivitasSosial = File(d['dokumentasiAktivitasSosialPath']);

      if (d['ttdLineWalkerPath'] != null) _ttdLineWalker = File(d['ttdLineWalkerPath']);
      _namaTTDLineWalkerCtrl.text = d['namaTTDLineWalker'] ?? '';

      if (d['ttdTLGIPath'] != null) _ttdTLGI = File(d['ttdTLGIPath']);
      _namaTTDTLGICtrl.text = d['namaTTDTLGI'] ?? '';
    }
  }

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    _pelakuAktivitasCtrl.dispose();
    _tanggapanCtrl.dispose();
    _jumlahTemuanCtrl.dispose();
    _lokasiCtrl.dispose();
    _namaTTDLineWalkerCtrl.dispose();
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

  KegiatanSosialInputModel _buildInputModel() {
    return KegiatanSosialInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      jenisAktivitas: _jenisAktivitas,
      statusAktivitas: _statusAktivitas,
      progresPenanganan: _progresPenanganan,
      tindakan: _tindakan,
      keterangan: _keteranganCtrl.text.trim(),
      statusObjek: _statusObjek,
      pelakuAktivitasSosial: _pelakuAktivitasCtrl.text.trim(),
      tanggapan: _tanggapanCtrl.text.trim(),
      lokasi: _lokasiCtrl.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      dokumentasiSosialisasi: _dokumentasiSosialisasi,
      dokumentasiAktivitasSosial: _dokumentasiAktivitasSosial,
      ttdLineWalker: _ttdLineWalker,
      namaTTDLineWalker: _namaTTDLineWalkerCtrl.text.trim(),
      ttdTLGI: _ttdTLGI,
      namaTTDTLGI: _namaTTDTLGICtrl.text.isNotEmpty ? _namaTTDTLGICtrl.text.trim() : null,
      temuan: _temuan,
      jumlahTemuan: int.tryParse(_jumlahTemuanCtrl.text),
    );
  }

  Future<void> _handleSaveDraft() async {
    final input = _buildInputModel();
    await context.read<KegiatanSosialCubit>().saveDraft(input);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data kegiatan sosial berhasil disimpan sebagai draft offline'),
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
    if (_keteranganCtrl.text.trim().isEmpty) {
      _showError('Keterangan aktivitas wajib diisi');
      return;
    }
    if (_pelakuAktivitasCtrl.text.trim().isEmpty) {
      _showError('Pelaku aktivitas sosial wajib diisi');
      return;
    }
    if (_tanggapanCtrl.text.trim().isEmpty) {
      _showError('Tanggapan wajib diisi');
      return;
    }
    if (_temuan == 'ADA TEMUAN' && _jumlahTemuanCtrl.text.trim().isEmpty) {
      _showError('Jumlah temuan wajib diisi');
      return;
    }
    if (_namaTTDLineWalkerCtrl.text.trim().isEmpty || _ttdLineWalker == null) {
      _showError('Tanda tangan dan nama Line Walker wajib diisi');
      return;
    }

    final input = _buildInputModel();
    context.read<KegiatanSosialCubit>().submitKegiatanSosial(input, draftId: widget.draftId);
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
        title: const Text('Input Kegiatan Sosial'),
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
      body: BlocConsumer<KegiatanSosialCubit, KegiatanSosialState>(
        listener: (context, state) {
          if (state is KegiatanSosialSubmitSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
            );
            context.pop();
          } else if (state is KegiatanSosialSubmitFailure) {
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
          final isSubmitting = state is KegiatanSosialSubmitting;
          List<TowerAssetModel> towers = [];
          if (state is KegiatanSosialLoaded) {
            towers = state.towers;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card 1: Objek Tower & Jenis Aktivitas
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATA KEGIATAN & OBJEK',
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
                              context.read<KegiatanSosialCubit>().selectTower(tower);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _jenisAktivitas,
                          decoration: InputDecoration(
                            labelText: 'Jenis Aktivitas',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'LAYANG-LAYANG', child: Text('Layang-layang')),
                            DropdownMenuItem(value: 'PEMANFAATAN HALAMAN TOWER', child: Text('Pemanfaatan Halaman Tower')),
                            DropdownMenuItem(value: 'PENGGUNAAN ALUMUNIUM FOIL', child: Text('Penggunaan Alumunium Foil')),
                            DropdownMenuItem(value: 'RAWAN KEBAKARAN', child: Text('Rawan Kebakaran')),
                            DropdownMenuItem(value: 'LAIN-LAIN', child: Text('Lain-lain')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _jenisAktivitas = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _statusAktivitas,
                          decoration: InputDecoration(
                            labelText: 'Status Aktivitas',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'MASIH BERLANGSUNG', child: Text('Masih Berlangsung')),
                            DropdownMenuItem(value: 'BERHENTI SEMENTARA', child: Text('Berhenti Sementara')),
                            DropdownMenuItem(value: 'BERHENTI', child: Text('Berhenti')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _statusAktivitas = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _progresPenanganan,
                          decoration: InputDecoration(
                            labelText: 'Progres Penanganan',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'SWEEPING', child: Text('Sweeping')),
                            DropdownMenuItem(value: 'SUDAH SOSIALISASI AWAL', child: Text('Sudah Sosialisasi Awal')),
                            DropdownMenuItem(value: 'BUTUH SOSIALISASI LANJUTAN', child: Text('Butuh Sosialisasi Lanjutan')),
                            DropdownMenuItem(value: 'BELUM TERSOSIALISASI', child: Text('Belum Tersosialisasi')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _progresPenanganan = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _tindakan,
                          decoration: InputDecoration(
                            labelText: 'Tindakan',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'SUDAH DIEKSEKUSI', child: Text('Sudah Dieksekusi')),
                            DropdownMenuItem(value: 'BELUM DIEKSEKUSI', child: Text('Belum Dieksekusi')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _tindakan = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _keteranganCtrl,
                          decoration: InputDecoration(
                            labelText: 'Keterangan Aktivitas *',
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
                          items: const [
                            DropdownMenuItem(value: 'PERMANEN', child: Text('Permanen')),
                            DropdownMenuItem(value: 'SEMENTARA', child: Text('Sementara')),
                            DropdownMenuItem(value: 'SELESAI', child: Text('Selesai')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _statusObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pelakuAktivitasCtrl,
                          decoration: InputDecoration(
                            labelText: 'Pelaku Aktivitas Sosial *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tanggapanCtrl,
                          decoration: InputDecoration(
                            labelText: 'Tanggapan *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _temuan,
                          decoration: InputDecoration(
                            labelText: 'Temuan',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'TIDAK ADA TEMUAN', child: Text('Tidak Ada Temuan')),
                            DropdownMenuItem(value: 'ADA TEMUAN', child: Text('Ada Temuan')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _temuan = val);
                          },
                        ),
                        if (_temuan == 'ADA TEMUAN') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _jumlahTemuanCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah Temuan *',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
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

                // Card 2: Dokumentasi Foto
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        FieldPictInput(
                          label: 'Dokumentasi Sosialisasi',
                          placeholder: 'Ambil Foto Sosialisasi',
                          pictureFile: _dokumentasiSosialisasi,
                          onChange: (f) => setState(() => _dokumentasiSosialisasi = f),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Dokumentasi Aktivitas Sosial',
                          placeholder: 'Ambil Foto Aktivitas Sosial',
                          pictureFile: _dokumentasiAktivitasSosial,
                          onChange: (f) => setState(() => _dokumentasiAktivitasSosial = f),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 3: Tanda Tangan
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
                          'Simpan Kegiatan Sosial',
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
