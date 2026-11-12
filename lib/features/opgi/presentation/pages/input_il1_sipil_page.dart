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

class InputIl1SipilPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InputIl1SipilPage({
    super.key,
    required this.params,
  });

  @override
  State<InputIl1SipilPage> createState() => _InputIl1SipilPageState();
}

class _InputIl1SipilPageState extends State<InputIl1SipilPage> {
  final _formKey = GlobalKey<FormState>();

  late int _sipilId;
  late String _nama;
  late String _gedung;
  late String _garduIndukNama;
  late int _garduIndukId;

  late DateTime _startTime;
  double _initialDurasi = 0.0;
  int? _existingDraftId;

  // Controllers
  // 1. Lampu
  final _jumlahLampuController = TextEditingController(text: '0');
  final _jumlahLampuMatiController = TextEditingController(text: '0');
  final _keteranganLampuController = TextEditingController();

  // 2. AC
  final _jumlahAcNormalController = TextEditingController(text: '0');
  final _jumlahAcWindController = TextEditingController(text: '0');
  final _jumlahAcBocorController = TextEditingController(text: '0');
  final _keteranganAcController = TextEditingController();

  // 3. Atap
  final _letakKebocoranAtapController = TextEditingController();

  // 4. DC / Baterai
  final _suhuRuangBateraiController = TextEditingController(text: '0.0');
  final _kelembabanRuangBateraiController = TextEditingController(text: '0.0');
  final _teganganBebanController = TextEditingController(text: '0.0');
  final _arusBebanController = TextEditingController(text: '0.0');

  // 5. Rectifier
  final _suhuRuangRectifierController = TextEditingController(text: '0.0');
  final _kelembabanRuangRectifierController = TextEditingController(text: '0.0');

  // Dropdown States
  // Lampu
  String _kondisiLampu = 'BAIK';
  String _jenisLampu = 'LED';

  // AC
  String _kondisiRuangan = 'TIDAK';

  // Atap
  String _kondisiAtap = 'TIDAK';

  // Basement / Mainhole
  String _mainholeTergenangAir = 'TIDAK';

  // Power Supply AC
  String _powerSupplyAC = 'ADA';

  // Power Supply DC
  String _kebersihanPanelDCBC = 'BERSIH';
  String _kebersihanRuangBaterai = 'BERSIH';
  String _kebersihanBaterai = 'BERSIH';
  String _kebocoranBaterai = 'TIDAK';
  String _exhaustFan = 'BERFUNGSI';
  String _kondisiRuangBaterai = 'TIDAK';

  // Rectifier 110 V
  String _kondisiRectifier = 'BAIK';
  String _kebersihanRuangRectifier = 'BERSIH';
  String _kebersihanPanel = 'BERSIH';

  // Peralatan Komputer & Komunikasi
  String _kondisiMMI = 'BAIK';
  String _kondisiMouse = 'BAIK';
  String _kondisiKeyboard = 'BAIK';
  String _kondisiInternet = 'BAIK';
  String _kondisiRadio = 'BAIK';
  String _kondisiYealink = 'BAIK';

  File? _fotoBuktiInspeksi;
  String? _fotoBuktiInitialUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _sipilId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _nama = p['nama']?.toString() ?? '-';
    _gedung = p['gedung']?.toString() ?? '-';
    _garduIndukNama = p['garduIndukNama']?.toString() ?? p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    _loadDraftOrLastData();
  }

  @override
  void dispose() {
    _jumlahLampuController.dispose();
    _jumlahLampuMatiController.dispose();
    _keteranganLampuController.dispose();
    _jumlahAcNormalController.dispose();
    _jumlahAcWindController.dispose();
    _jumlahAcBocorController.dispose();
    _keteranganAcController.dispose();
    _letakKebocoranAtapController.dispose();
    _suhuRuangBateraiController.dispose();
    _kelembabanRuangBateraiController.dispose();
    _teganganBebanController.dispose();
    _arusBebanController.dispose();
    _suhuRuangRectifierController.dispose();
    _kelembabanRuangRectifierController.dispose();
    super.dispose();
  }

  Future<void> _loadDraftOrLastData() async {
    // 1. Try draft
    try {
      final drafts = await LocalDatabase.instance.getUnfinishedItemsGI(
        nama: '$_gedung-$_nama',
        type: 'il1-sipil',
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
    final lastDataStr = widget.params['lastData']?.toString();

    if (lastStr != null && lastStr.isNotEmpty && lastStr != 'null') {
      try {
        final lastData = jsonDecode(lastStr) as Map<String, dynamic>;
        _applyValues(lastData);
        return;
      } catch (_) {}
    }

    if (lastDataStr != null && lastDataStr.isNotEmpty && lastDataStr != 'null') {
      try {
        final lastData = jsonDecode(lastDataStr) as Map<String, dynamic>;
        _applyValues(lastData);
      } catch (_) {}
    }
  }

  void _applyValues(Map<String, dynamic> data) {
    setState(() {
      if (data['kondisiLampuPenerangan'] != null) _kondisiLampu = data['kondisiLampuPenerangan'].toString();
      if (data['jenisLampuPenerangan'] != null) _jenisLampu = data['jenisLampuPenerangan'].toString();
      if (data['jumlahLampuPenerangan'] != null) _jumlahLampuController.text = data['jumlahLampuPenerangan'].toString();
      if (data['jumlahLampuPeneranganMati'] != null) {
        _jumlahLampuMatiController.text = data['jumlahLampuPeneranganMati'].toString();
      }
      if (data['keteranganLampuPenerangan'] != null) {
        _keteranganLampuController.text = data['keteranganLampuPenerangan'].toString();
      }

      if (data['kondisiRuangan'] != null) _kondisiRuangan = data['kondisiRuangan'].toString();
      if (data['jumlahACMenyalaNormal'] != null) _jumlahAcNormalController.text = data['jumlahACMenyalaNormal'].toString();
      if (data['jumlahACWindOnly'] != null) _jumlahAcWindController.text = data['jumlahACWindOnly'].toString();
      if (data['jumlahACBocor'] != null) _jumlahAcBocorController.text = data['jumlahACBocor'].toString();
      if (data['keteranganAc'] != null) _keteranganAcController.text = data['keteranganAc'].toString();

      if (data['kondisiAtap'] != null) _kondisiAtap = data['kondisiAtap'].toString();
      if (data['letakKebocoranAtap'] != null) _letakKebocoranAtapController.text = data['letakKebocoranAtap'].toString();

      if (data['mainholeTergenangAir'] != null) _mainholeTergenangAir = data['mainholeTergenangAir'].toString();
      if (data['powerSupplyAC'] != null) _powerSupplyAC = data['powerSupplyAC'].toString();

      if (data['kebersihanPanelDCBC'] != null) _kebersihanPanelDCBC = data['kebersihanPanelDCBC'].toString();
      if (data['kebersihanRuangBaterai'] != null) _kebersihanRuangBaterai = data['kebersihanRuangBaterai'].toString();
      if (data['suhuRuangBaterai'] != null) _suhuRuangBateraiController.text = data['suhuRuangBaterai'].toString();
      if (data['kelembabanRuangBaterai'] != null) {
        _kelembabanRuangBateraiController.text = data['kelembabanRuangBaterai'].toString();
      }
      if (data['kebersihanBaterai'] != null) _kebersihanBaterai = data['kebersihanBaterai'].toString();
      if (data['kebocoranBaterai'] != null) _kebocoranBaterai = data['kebocoranBaterai'].toString();
      if (data['exhaustFan'] != null) _exhaustFan = data['exhaustFan'].toString();
      if (data['kondisiRuangBaterai'] != null) _kondisiRuangBaterai = data['kondisiRuangBaterai'].toString();
      if (data['teganganBeban'] != null) _teganganBebanController.text = data['teganganBeban'].toString();
      if (data['arusBeban'] != null) _arusBebanController.text = data['arusBeban'].toString();

      if (data['kondisiRectifier'] != null) _kondisiRectifier = data['kondisiRectifier'].toString();
      if (data['kebersihanRuangRectifier'] != null) {
        _kebersihanRuangRectifier = data['kebersihanRuangRectifier'].toString();
      }
      if (data['suhuRuangRectifier'] != null) _suhuRuangRectifierController.text = data['suhuRuangRectifier'].toString();
      if (data['kelembabanRuangRectifier'] != null) {
        _kelembabanRuangRectifierController.text = data['kelembabanRuangRectifier'].toString();
      }
      if (data['kebersihanPanel'] != null) _kebersihanPanel = data['kebersihanPanel'].toString();

      if (data['kondisiMMI'] != null) _kondisiMMI = data['kondisiMMI'].toString();
      if (data['kondisiMouseKomputer'] != null) _kondisiMouse = data['kondisiMouseKomputer'].toString();
      if (data['kondisiKeyboardKomputer'] != null) _kondisiKeyboard = data['kondisiKeyboardKomputer'].toString();
      if (data['kondisiInternet'] != null) _kondisiInternet = data['kondisiInternet'].toString();
      if (data['kondisiRadio'] != null) _kondisiRadio = data['kondisiRadio'].toString();
      if (data['kondisiYealink'] != null) _kondisiYealink = data['kondisiYealink'].toString();

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
      'sipilId': _sipilId,
      'garduIndukId': _garduIndukId,
      'gedung': _gedung,
      'nama': _nama,
      'kondisiLampuPenerangan': _kondisiLampu,
      'jenisLampuPenerangan': _jenisLampu,
      'jumlahLampuPenerangan': int.tryParse(_jumlahLampuController.text.trim()) ?? 0,
      'jumlahLampuPeneranganMati': int.tryParse(_jumlahLampuMatiController.text.trim()) ?? 0,
      'keteranganLampuPenerangan': _keteranganLampuController.text.trim(),
      'kondisiRuangan': _kondisiRuangan,
      'jumlahACMenyalaNormal': int.tryParse(_jumlahAcNormalController.text.trim()) ?? 0,
      'jumlahACWindOnly': int.tryParse(_jumlahAcWindController.text.trim()) ?? 0,
      'jumlahACBocor': int.tryParse(_jumlahAcBocorController.text.trim()) ?? 0,
      'keteranganAc': _keteranganAcController.text.trim(),
      'kondisiAtap': _kondisiAtap,
      if (_kondisiAtap == 'BOCOR')
        'letakKebocoranAtap': _letakKebocoranAtapController.text.trim(),
      'mainholeTergenangAir': _mainholeTergenangAir,
      'powerSupplyAC': _powerSupplyAC,
      'kebersihanPanelDCBC': _kebersihanPanelDCBC,
      'kebersihanRuangBaterai': _kebersihanRuangBaterai,
      'suhuRuangBaterai': double.tryParse(_suhuRuangBateraiController.text.trim()) ?? 0.0,
      'kelembabanRuangBaterai': double.tryParse(_kelembabanRuangBateraiController.text.trim()) ?? 0.0,
      'kebersihanBaterai': _kebersihanBaterai,
      'kebocoranBaterai': _kebocoranBaterai,
      'exhaustFan': _exhaustFan,
      'kondisiRuangBaterai': _kondisiRuangBaterai,
      'teganganBeban': double.tryParse(_teganganBebanController.text.trim()) ?? 0.0,
      'arusBeban': double.tryParse(_arusBebanController.text.trim()) ?? 0.0,
      'kondisiRectifier': _kondisiRectifier,
      'kebersihanRuangRectifier': _kebersihanRuangRectifier,
      'suhuRuangRectifier': double.tryParse(_suhuRuangRectifierController.text.trim()) ?? 0.0,
      'kelembabanRuangRectifier': double.tryParse(_kelembabanRuangRectifierController.text.trim()) ?? 0.0,
      'kebersihanPanel': _kebersihanPanel,
      'kondisiMMI': _kondisiMMI,
      'kondisiMouseKomputer': _kondisiMouse,
      'kondisiKeyboardKomputer': _kondisiKeyboard,
      'kondisiInternet': _kondisiInternet,
      'kondisiRadio': _kondisiRadio,
      'kondisiYealink': _kondisiYealink,
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

    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<OpgiIl1Cubit>();

    try {
      await cubit.saveDraft(
        type: 'il1-sipil',
        nama: '$_gedung-$_nama',
        date: DateFormat('dd-MMMM-yyyy').format(DateTime.now()),
        data: payload,
      );

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Draft berhasil disimpan'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
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

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua field yang wajib'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = _collectPayload();

    await context.read<OpgiIl1Cubit>().submitSipilSingle(
      data: payload,
      fotoBuktiInspeksi: _fotoBuktiInspeksi,
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
        title: Text('IL1 Sipil - $_gedung'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Simpan Draft',
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
                title: 'INFO',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStaticRow('Gedung', _gedung),
                    const SizedBox(height: 12),
                    _buildStaticRow('Gardu Induk', _garduIndukNama),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. BUKTI INSPEKSI
              InputContainer(
                title: 'BUKTI INSPEKSI',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Foto Bukti Inspeksi *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    FieldPictInput(
                      label: 'Foto Bukti Inspeksi',
                      placeholder: 'Ambil Foto Bukti Inspeksi',
                      pictureFile: _fotoBuktiInspeksi,
                      initialUrl: _fotoBuktiInitialUrl,
                      isRequired: true,
                      onChange: (file) => setState(() => _fotoBuktiInspeksi = file),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. LAMPU PENERANGAN
              InputContainer(
                title: 'LAMPU PENERANGAN',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Kondisi Lampu Penerangan',
                      value: _kondisiLampu,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiLampu = val ?? _kondisiLampu),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Jenis Lampu Penerangan',
                      value: _jenisLampu,
                      options: OpgiIl1Constants.sipilJenisLampu,
                      onChanged: (val) => setState(() => _jenisLampu = val ?? _jenisLampu),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Jumlah Lampu Penerangan',
                      controller: _jumlahLampuController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Jumlah Lampu Penerangan Mati',
                      controller: _jumlahLampuMatiController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Keterangan Lampu Penerangan',
                      controller: _keteranganLampuController,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. AIR CONDITIONER
              InputContainer(
                title: 'AIR CONDITIONER',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Kondisi Ruangan',
                      value: _kondisiRuangan,
                      options: OpgiIl1Constants.sipilKondisiRuangan,
                      onChanged: (val) => setState(() => _kondisiRuangan = val ?? _kondisiRuangan),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Jumlah AC Menyala Normal',
                      controller: _jumlahAcNormalController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Jumlah AC Hanya Keluar Angin',
                      controller: _jumlahAcWindController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Jumlah AC Menetes/Bocor',
                      controller: _jumlahAcBocorController,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Keterangan AC',
                      controller: _keteranganAcController,
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. KEBOCORAN ATAP
              InputContainer(
                title: 'KEBOCORAN ATAP',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Kondisi Atap',
                      value: _kondisiAtap,
                      options: OpgiIl1Constants.sipilKondisiAtap,
                      onChanged: (val) => setState(() => _kondisiAtap = val ?? _kondisiAtap),
                    ),
                    if (_kondisiAtap == 'BOCOR') ...[
                      const SizedBox(height: 12),
                      _buildTextFormField(
                        label: 'Letak Kebocoran Atap',
                        controller: _letakKebocoranAtapController,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. COMPARTMEN MAINHOLE/BASEMENT
              InputContainer(
                title: 'COMPARTMEN MAINHOLE/BASEMENT',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Tergenang Air',
                      value: _mainholeTergenangAir,
                      options: OpgiIl1Constants.sipilYaTidak,
                      onChanged: (val) => setState(() => _mainholeTergenangAir = val ?? _mainholeTergenangAir),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 7. POWER SUPPLY AC
              InputContainer(
                title: 'POWER SUPPLY AC',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Power Supply AC',
                      value: _powerSupplyAC,
                      options: OpgiIl1Constants.sipilAdaTidak,
                      onChanged: (val) => setState(() => _powerSupplyAC = val ?? _powerSupplyAC),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 8. POWER SUPPLY DC
              InputContainer(
                title: 'POWER SUPPLY DC',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Kebersihan Panel DCBC',
                      value: _kebersihanPanelDCBC,
                      options: OpgiIl1Constants.sipilBersihTidak,
                      onChanged: (val) => setState(() => _kebersihanPanelDCBC = val ?? _kebersihanPanelDCBC),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kebersihan Ruang Baterai',
                      value: _kebersihanRuangBaterai,
                      options: OpgiIl1Constants.sipilBersihTidak,
                      onChanged: (val) => setState(() => _kebersihanRuangBaterai = val ?? _kebersihanRuangBaterai),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Suhu Ruang Baterai (°C)',
                      controller: _suhuRuangBateraiController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Kelembaban Ruang Baterai (%)',
                      controller: _kelembabanRuangBateraiController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kebersihan Baterai',
                      value: _kebersihanBaterai,
                      options: OpgiIl1Constants.sipilBersihTidak,
                      onChanged: (val) => setState(() => _kebersihanBaterai = val ?? _kebersihanBaterai),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kebocoran Baterai',
                      value: _kebocoranBaterai,
                      options: OpgiIl1Constants.sipilBocorTidak,
                      onChanged: (val) => setState(() => _kebocoranBaterai = val ?? _kebocoranBaterai),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Exhaust Fan',
                      value: _exhaustFan,
                      options: OpgiIl1Constants.sipilBerfungsiTidak,
                      onChanged: (val) => setState(() => _exhaustFan = val ?? _exhaustFan),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi Ruang Baterai',
                      value: _kondisiRuangBaterai,
                      options: OpgiIl1Constants.sipilBocorTidak,
                      onChanged: (val) => setState(() => _kondisiRuangBaterai = val ?? _kondisiRuangBaterai),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Tegangan Beban (V)',
                      controller: _teganganBebanController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Arus Beban (A)',
                      controller: _arusBebanController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 9. RECTIFIER 110 V
              InputContainer(
                title: 'RECTIFIER 110 V',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Kondisi Rectifier',
                      value: _kondisiRectifier,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiRectifier = val ?? _kondisiRectifier),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kebersihan Ruang Rectifier',
                      value: _kebersihanRuangRectifier,
                      options: OpgiIl1Constants.sipilBersihTidak,
                      onChanged: (val) => setState(() => _kebersihanRuangRectifier = val ?? _kebersihanRuangRectifier),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Suhu Ruang Rectifier (°C)',
                      controller: _suhuRuangRectifierController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    _buildTextFormField(
                      label: 'Kelembaban Ruang Rectifier (%)',
                      controller: _kelembabanRuangRectifierController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kebersihan Panel',
                      value: _kebersihanPanel,
                      options: OpgiIl1Constants.sipilBersihTidak,
                      onChanged: (val) => setState(() => _kebersihanPanel = val ?? _kebersihanPanel),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 10. PERALATAN KOMPUTER DAN KOMUNIKASI
              InputContainer(
                title: 'PERALATAN KOMPUTER DAN KOMUNIKASI',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Il1DropdownField(
                      label: 'Kondisi MMI',
                      value: _kondisiMMI,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiMMI = val ?? _kondisiMMI),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi Mouse Komputer',
                      value: _kondisiMouse,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiMouse = val ?? _kondisiMouse),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi Keyboard Komputer',
                      value: _kondisiKeyboard,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiKeyboard = val ?? _kondisiKeyboard),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi Internet',
                      value: _kondisiInternet,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiInternet = val ?? _kondisiInternet),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi Radio',
                      value: _kondisiRadio,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiRadio = val ?? _kondisiRadio),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi Yealink',
                      value: _kondisiYealink,
                      options: OpgiIl1Constants.sipilBaikTidak,
                      onChanged: (val) => setState(() => _kondisiYealink = val ?? _kondisiYealink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaticRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Tulis jawaban',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
