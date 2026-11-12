import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/storage/local_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/input_container.dart';
import '../constants/opgi_il1_constants.dart';
import '../cubit/opgi_il1_cubit.dart';
import '../widgets/il1_dropdown_field.dart';
import '../widgets/il1_multi_select_field.dart';

class InputIl1TrafoPsPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InputIl1TrafoPsPage({
    super.key,
    required this.params,
  });

  @override
  State<InputIl1TrafoPsPage> createState() => _InputIl1TrafoPsPageState();
}

class _InputIl1TrafoPsPageState extends State<InputIl1TrafoPsPage> {
  final _formKey = GlobalKey<FormState>();

  late int _trafoId;
  late String _trafoNama;
  late String _garduIndukNama;
  late int _garduIndukId;

  late DateTime _startTime;
  double _initialDurasi = 0.0;
  int? _existingDraftId;

  // Controllers
  final _merkController = TextEditingController();
  final _tahunPembuatanController = TextEditingController();
  final _noSeriController = TextEditingController();
  final _kapasitasController = TextEditingController();
  final _tapController = TextEditingController();

  String _jenisTrafo = 'INDOOR';
  List<String> _kebocoranBodyTrafo = [];
  List<String> _kondisiFisikTrafo = [];
  List<String> _kondisiRumahTrafo = [];

  File? _fotoBuktiInspeksi;
  String? _fotoBuktiInitialUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _trafoId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _trafoNama = p['nama']?.toString() ?? '-';
    _garduIndukNama = p['garduIndukNama']?.toString() ?? p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _merkController.text = p['merkTrafo']?.toString() ?? '';
    _tahunPembuatanController.text = p['tahunPembuatanTrafo']?.toString() ?? '';
    _noSeriController.text = p['noSeriTrafo']?.toString() ?? '';
    _kapasitasController.text = p['kapasitasTrafo']?.toString() ?? '';
    _tapController.text = p['tapTrafo']?.toString() ?? '';
    _jenisTrafo = p['jenisTrafo']?.toString() ?? 'INDOOR';

    _loadDraftOrLastData();
  }

  @override
  void dispose() {
    _merkController.dispose();
    _tahunPembuatanController.dispose();
    _noSeriController.dispose();
    _kapasitasController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _loadDraftOrLastData() async {
    // 1. Try draft
    try {
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        nama: '$_trafoNama-$_garduIndukNama',
        type: 'il1-trafo-ps',
      );

      if (drafts.isNotEmpty && mounted) {
        final draft = drafts.first;
        _existingDraftId = draft['id'] as int?;
        final data = draft['data'] is Map<String, dynamic>
            ? draft['data'] as Map<String, dynamic>
            : <String, dynamic>{};

        _applyValues(data);
        return;
      }
    } catch (_) {}

    // 2. Fallback to last data
    final lastStr = widget.params['last']?.toString();
    if (lastStr != null && lastStr.isNotEmpty && lastStr != 'null') {
      try {
        final lastData = jsonDecode(lastStr) as Map<String, dynamic>;
        _applyValues(lastData);
      } catch (_) {}
    }
  }

  void _applyValues(Map<String, dynamic> data) {
    setState(() {
      if (data['merkTrafo'] != null) _merkController.text = data['merkTrafo'].toString();
      if (data['tahunPembuatanTrafo'] != null) _tahunPembuatanController.text = data['tahunPembuatanTrafo'].toString();
      if (data['noSeriTrafo'] != null) _noSeriController.text = data['noSeriTrafo'].toString();
      if (data['kapasitasTrafo'] != null) _kapasitasController.text = data['kapasitasTrafo'].toString();
      if (data['tapTrafo'] != null) _tapController.text = data['tapTrafo'].toString();
      if (data['jenisTrafo'] != null) _jenisTrafo = data['jenisTrafo'].toString();

      if (data['kebocoranBodyTrafo'] is List) {
        _kebocoranBodyTrafo = (data['kebocoranBodyTrafo'] as List).map((e) => e.toString()).toList();
      }
      if (data['kondisiFisikTrafo'] is List) {
        _kondisiFisikTrafo = (data['kondisiFisikTrafo'] as List).map((e) => e.toString()).toList();
      }
      if (data['kondisiRumahTrafo'] is List) {
        _kondisiRumahTrafo = (data['kondisiRumahTrafo'] as List).map((e) => e.toString()).toList();
      }

      _initialDurasi = (data['durasi'] as num?)?.toDouble() ?? 0.0;

      final fotoBukti = data['fotoBuktiInspeksi'];
      if (fotoBukti is Map) {
        final p = fotoBukti['uri']?.toString() ?? fotoBukti['path']?.toString();
        if (p != null && File(p).existsSync()) {
          _fotoBuktiInspeksi = File(p);
        } else if (p != null) {
          _fotoBuktiInitialUrl = p;
        }
      } else if (fotoBukti is String) {
        if (File(fotoBukti).existsSync()) {
          _fotoBuktiInspeksi = File(fotoBukti);
        } else {
          _fotoBuktiInitialUrl = fotoBukti;
        }
      }
    });
  }

  Map<String, dynamic> _collectPayload() {
    final currentDurasi = _initialDurasi + (DateTime.now().difference(_startTime).inMilliseconds / 60000.0);

    return {
      'trafoId': _trafoId,
      'garduIndukId': _garduIndukId,
      'merkTrafo': _merkController.text.trim(),
      'tahunPembuatanTrafo': _tahunPembuatanController.text.trim(),
      'noSeriTrafo': _noSeriController.text.trim(),
      'kapasitasTrafo': _kapasitasController.text.trim(),
      'tapTrafo': _tapController.text.trim(),
      'jenisTrafo': _jenisTrafo,
      'kebocoranBodyTrafo': _kebocoranBodyTrafo,
      'kondisiFisikTrafo': _kondisiFisikTrafo,
      'kondisiRumahTrafo': _kondisiRumahTrafo,
      'durasi': currentDurasi,
      'timezone': 'Asia/Jakarta',
      'startTime': _startTime.toIso8601String(),
    };
  }

  Future<void> _handleSaveDraft() async {
    final payload = _collectPayload();
    if (_fotoBuktiInspeksi != null) {
      payload['fotoBuktiInspeksi'] = {'uri': _fotoBuktiInspeksi!.path};
    }

    try {
      await context.read<OpgiIl1Cubit>().saveDraft(
        type: 'il1-trafo-ps',
        nama: '$_trafoNama-$_garduIndukNama',
        date: DateFormat('dd-MMMM-yyyy').format(DateTime.now()),
        data: payload,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft berhasil disimpan'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan draft: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (_fotoBuktiInspeksi == null && (_fotoBuktiInitialUrl == null || _fotoBuktiInitialUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto bukti inspeksi wajib diambil'), backgroundColor: Colors.red),
      );
      return;
    }

    final cubit = context.read<OpgiIl1Cubit>();
    setState(() => _isSubmitting = true);

    final payload = _collectPayload();
    await cubit.submitTrafoPsSingle(
      data: payload,
      fotoBuktiInspeksi: _fotoBuktiInspeksi?.path ?? _fotoBuktiInitialUrl,
      draftId: _existingDraftId,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input IL1 Trafo PS - $_trafoNama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Simpan sebagai Draft',
            onPressed: _handleSaveDraft,
          ),
        ],
      ),
      body: AppBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. INFO
              InputContainer(
                label: 'INFO',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(_trafoNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Text('Gardu Induk', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(_garduIndukNama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _merkController,
                      decoration: const InputDecoration(
                        labelText: 'Merk Trafo',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _tahunPembuatanController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tahun Pembuatan',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _noSeriController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Seri',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _kapasitasController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kapasitas Trafo (kVA)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _tapController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tap Trafo',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Il1DropdownField(
                      label: 'Jenis Trafo',
                      options: OpgiIl1Constants.trafoPsJenisTrafo,
                      selectedValue: _jenisTrafo,
                      onChanged: (val) => setState(() => _jenisTrafo = val ?? 'INDOOR'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. BUKTI INSPEKSI
              InputContainer(
                label: 'BUKTI INSPEKSI',
                child: FieldPictInput(
                  label: 'Foto Bukti Inspeksi',
                  placeholder: 'Ambil Foto Bukti Inspeksi',
                  pictureFile: _fotoBuktiInspeksi,
                  initialUrl: _fotoBuktiInitialUrl,
                  isRequired: true,
                  onChange: (file) => setState(() => _fotoBuktiInspeksi = file),
                ),
              ),
              const SizedBox(height: 16),

              // 3. KETERANGAN BODY TRAFO
              InputContainer(
                label: 'KETERANGAN BODY TRAFO',
                child: Il1MultiSelectField(
                  label: 'Kebocoran Body Trafo',
                  options: OpgiIl1Constants.trafoPsKebocoranBody,
                  selectedValues: _kebocoranBodyTrafo,
                  onChanged: (vals) => setState(() => _kebocoranBodyTrafo = vals),
                ),
              ),
              const SizedBox(height: 16),

              // 4. KONDISI FISIK TRAFO
              InputContainer(
                label: 'KONDISI FISIK TRAFO',
                child: Il1MultiSelectField(
                  label: 'Kondisi Fisik Trafo',
                  options: OpgiIl1Constants.trafoPsKondisiFisik,
                  selectedValues: _kondisiFisikTrafo,
                  onChanged: (vals) => setState(() => _kondisiFisikTrafo = vals),
                ),
              ),
              const SizedBox(height: 16),

              // 5. KONDISI RUMAH TRAFO
              InputContainer(
                label: 'KONDISI RUMAH TRAFO',
                child: Il1MultiSelectField(
                  label: 'Kondisi Rumah Trafo',
                  options: OpgiIl1Constants.trafoPsKondisiRumah,
                  selectedValues: _kondisiRumahTrafo,
                  onChanged: (vals) => setState(() => _kondisiRumahTrafo = vals),
                ),
              ),
              const SizedBox(height: 24),

              // SUBMIT BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan Inspeksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
