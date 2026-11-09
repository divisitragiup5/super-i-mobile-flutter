import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_label.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/field_signature_pad.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../../home/presentation/cubit/drafts_cubit.dart';
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

  String? _jenisAktivitas;
  String? _statusAktivitas;
  String? _progresPenanganan;
  String? _tindakan;
  final TextEditingController _keteranganCtrl = TextEditingController();
  String? _statusObjek;
  final TextEditingController _pelakuAktivitasCtrl = TextEditingController();
  final TextEditingController _tanggapanCtrl = TextEditingController();

  String? _temuan;
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

  String _identifier = '';
  bool _isPartialDisabled = false;

  @override
  void initState() {
    super.initState();
    final rawId = widget.initialDraft?['identifier']?.toString();
    _identifier = (rawId != null && rawId.isNotEmpty)
        ? rawId
        : 'sosial-${DateTime.now().millisecondsSinceEpoch}';
    _isPartialDisabled = widget.initialDraft?['partialDisabled'] == 'true' ||
        widget.initialDraft?['partialDisabled'] == true;

    _namaTTDTLGICtrl.addListener(_onFieldChanged);
    context.read<KegiatanSosialCubit>().loadTowers();
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
      _jenisAktivitas = d['jenisAktivitas']?.toString();
      _statusAktivitas = d['statusAktivitas']?.toString();
      _progresPenanganan = d['progresPenanganan']?.toString();
      _tindakan = d['tindakan']?.toString();
      _keteranganCtrl.text = d['keterangan'] ?? '';
      _statusObjek = d['statusObjek']?.toString();
      _pelakuAktivitasCtrl.text = d['pelakuAktivitasSosial'] ?? '';
      _tanggapanCtrl.text = d['tanggapan'] ?? '';
      _temuan = d['temuan']?.toString();
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
    _namaTTDTLGICtrl.removeListener(_onFieldChanged);
    _keteranganCtrl.dispose();
    _pelakuAktivitasCtrl.dispose();
    _tanggapanCtrl.dispose();
    _jumlahTemuanCtrl.dispose();
    _lokasiCtrl.dispose();
    _namaTTDLineWalkerCtrl.dispose();
    _namaTTDTLGICtrl.dispose();
    super.dispose();
  }

  KegiatanSosialInputModel _buildInputModel() {
    return KegiatanSosialInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      identifier: _identifier,
      jenisAktivitas: _jenisAktivitas ?? '',
      statusAktivitas: _statusAktivitas ?? '',
      progresPenanganan: _progresPenanganan ?? '',
      tindakan: _tindakan ?? '',
      keterangan: _keteranganCtrl.text.trim(),
      statusObjek: _statusObjek ?? '',
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
      temuan: _temuan ?? 'TIDAK ADA TEMUAN',
      jumlahTemuan: _temuan == 'ADA TEMUAN' ? int.tryParse(_jumlahTemuanCtrl.text.trim()) : null,
    );
  }

  String? _validateForm() {
    if (_selectedTower == null) {
      return 'Pilih objek tower terlebih dahulu';
    }
    if (_jenisAktivitas == null || _jenisAktivitas!.isEmpty) {
      return 'Pilih jenis aktivitas terlebih dahulu';
    }
    if (_statusAktivitas == null || _statusAktivitas!.isEmpty) {
      return 'Pilih status aktivitas terlebih dahulu';
    }
    if (_progresPenanganan == null || _progresPenanganan!.isEmpty) {
      return 'Pilih progres penanganan terlebih dahulu';
    }
    if (_tindakan == null || _tindakan!.isEmpty) {
      return 'Pilih tindakan terlebih dahulu';
    }
    if (_keteranganCtrl.text.trim().isEmpty) {
      return 'Keterangan aktivitas wajib diisi';
    }
    if (_statusObjek == null || _statusObjek!.isEmpty) {
      return 'Pilih status objek terlebih dahulu';
    }
    if (_pelakuAktivitasCtrl.text.trim().isEmpty) {
      return 'Pelaku aktivitas sosial wajib diisi';
    }
    if (_tanggapanCtrl.text.trim().isEmpty) {
      return 'Tanggapan wajib diisi';
    }
    if (_temuan == null || _temuan!.isEmpty) {
      return 'Pilih temuan terlebih dahulu';
    }
    if (_temuan == 'ADA TEMUAN' && _jumlahTemuanCtrl.text.trim().isEmpty) {
      return 'Jumlah temuan wajib diisi jika ada temuan';
    }
    if (_dokumentasiSosialisasi == null) {
      return 'Foto dokumentasi sosialisasi wajib diambil';
    }
    if (_dokumentasiAktivitasSosial == null) {
      return 'Foto dokumentasi aktivitas sosial wajib diambil';
    }
    if (_namaTTDLineWalkerCtrl.text.trim().isEmpty || _ttdLineWalker == null) {
      return 'Tanda tangan dan nama Line Walker wajib diisi';
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
    await context.read<KegiatanSosialCubit>().saveDraft(input);
    try {
      sl<DraftsCubit>().loadDrafts();
    } catch (_) {}
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        'Data kegiatan sosial berhasil disimpan sebagai draft offline',
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
    context.read<KegiatanSosialCubit>().submitKegiatanSosial(input, draftId: widget.draftId);
  }

  void _showError(String message) {
    AppSnackbar.showError(context, message);
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
            AppSnackbar.showSuccess(context, state.message);
            context.pop();
          } else if (state is KegiatanSosialSubmitFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is KegiatanSosialSubmitting;
          List<TowerAssetModel> towers = [];
          if (state is KegiatanSosialLoaded) {
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
                        Opacity(
                          opacity: _isPartialDisabled ? 0.7 : 1.0,
                          child: IgnorePointer(
                            ignoring: _isPartialDisabled,
                            child: SearchableDropdown<int>(
                              label: 'Tower',
                              hint: 'Pilih tower...',
                              isRequired: true,
                              isLoading: state is KegiatanSosialLoading || (towers.isEmpty && state is! KegiatanSosialLoaded),
                              value: _selectedTower?.id,
                              items: towerItems,
                              onChanged: (id) {
                                if (id != null) {
                                  final tower = towerItems.firstWhere((t) => t.value == id);
                                  setState(() => _selectedTower = TowerAssetModel(id: tower.value, nama: tower.label));
                                  context.read<KegiatanSosialCubit>().selectTower(TowerAssetModel(id: tower.value, nama: tower.label));
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _jenisAktivitas,
                          hint: const Text('Pilih jenis aktivitas'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Jenis Aktivitas', isRequired: true),
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
                            setState(() => _jenisAktivitas = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _statusAktivitas,
                          hint: const Text('Pilih status aktivitas'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Status Aktivitas', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'MASIH BERLANGSUNG', child: Text('Masih Berlangsung')),
                            DropdownMenuItem(value: 'BERHENTI SEMENTARA', child: Text('Berhenti Sementara')),
                            DropdownMenuItem(value: 'BERHENTI', child: Text('Berhenti')),
                          ],
                          onChanged: (val) {
                            setState(() => _statusAktivitas = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _progresPenanganan,
                          hint: const Text('Pilih progres penanganan'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Progres Penanganan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'SWEEPING', child: Text('Sweeping')),
                            DropdownMenuItem(value: 'SUDAH SOSIALISASI AWAL', child: Text('Sudah Sosialisasi Awal')),
                            DropdownMenuItem(value: 'BUTUH SOSIALISASI LANJUTAN', child: Text('Butuh Sosialisasi Lanjutan')),
                            DropdownMenuItem(value: 'BELUM TERSOSIALISASI', child: Text('Belum Tersosialisasi')),
                          ],
                          onChanged: (val) {
                            setState(() => _progresPenanganan = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _tindakan,
                          hint: const Text('Pilih tindakan'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Tindakan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'SUDAH DIEKSEKUSI', child: Text('Sudah Dieksekusi')),
                            DropdownMenuItem(value: 'BELUM DIEKSEKUSI', child: Text('Belum Dieksekusi')),
                          ],
                          onChanged: (val) {
                            setState(() => _tindakan = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _keteranganCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Keterangan Aktivitas', isRequired: true),
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
                          items: const [
                            DropdownMenuItem(value: 'PERMANEN', child: Text('Permanen')),
                            DropdownMenuItem(value: 'SEMENTARA', child: Text('Sementara')),
                            DropdownMenuItem(value: 'SELESAI', child: Text('Selesai')),
                          ],
                          onChanged: (val) {
                            setState(() => _statusObjek = val);
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _pelakuAktivitasCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Pelaku Aktivitas Sosial', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _tanggapanCtrl,
                          decoration: InputDecoration(
                            label: const AppInputLabel('Tanggapan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _temuan,
                          hint: const Text('Pilih temuan'),
                          decoration: InputDecoration(
                            label: const AppInputLabel('Temuan', isRequired: true),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'TIDAK ADA TEMUAN', child: Text('Tidak Ada Temuan')),
                            DropdownMenuItem(value: 'ADA TEMUAN', child: Text('Ada Temuan')),
                          ],
                          onChanged: (val) {
                            setState(() => _temuan = val);
                          },
                        ),
                        if (_temuan == 'ADA TEMUAN') ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _jumlahTemuanCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              label: const AppInputLabel('Jumlah Temuan', isRequired: true),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
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
                          isRequired: true,
                          forceLandscape: true,
                          pictureFile: _dokumentasiSosialisasi,
                          onChange: (f) => setState(() => _dokumentasiSosialisasi = f),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Dokumentasi Aktivitas Sosial',
                          placeholder: 'Ambil Foto Aktivitas Sosial',
                          isRequired: true,
                          forceLandscape: true,
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
}
