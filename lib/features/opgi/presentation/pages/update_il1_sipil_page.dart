import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/input_container.dart';
import '../constants/opgi_il1_constants.dart';
import '../cubit/opgi_il1_cubit.dart';
import '../widgets/il1_dropdown_field.dart';

class UpdateIl1SipilPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateIl1SipilPage({
    super.key,
    required this.params,
  });

  @override
  State<UpdateIl1SipilPage> createState() => _UpdateIl1SipilPageState();
}

class _UpdateIl1SipilPageState extends State<UpdateIl1SipilPage> {
  final _formKey = GlobalKey<FormState>();

  late int _id; // inspection id
  late int _sipilId;
  late String _nama;
  late String _gedung;
  late String _garduInduk;

  late DateTime _startTime;
  double _initialDurasi = 0.0;

  // Controllers
  // 1. Lampu
  final _jumlahLampuController = TextEditingController();
  final _jumlahLampuMatiController = TextEditingController();
  final _keteranganLampuController = TextEditingController();

  // 2. AC
  final _jumlahAcNormalController = TextEditingController();
  final _jumlahAcWindController = TextEditingController();
  final _jumlahAcBocorController = TextEditingController();
  final _keteranganAcController = TextEditingController();

  // 3. Atap
  final _letakKebocoranAtapController = TextEditingController();

  // 4. DC / Baterai
  final _suhuRuangBateraiController = TextEditingController();
  final _kelembabanRuangBateraiController = TextEditingController();
  final _teganganBebanController = TextEditingController();
  final _arusBebanController = TextEditingController();

  // 5. Rectifier
  final _suhuRuangRectifierController = TextEditingController();
  final _kelembabanRuangRectifierController = TextEditingController();

  // Dropdown States
  String _kondisiLampu = 'BAIK';
  String _jenisLampu = 'LED';

  String _kondisiRuangan = 'TIDAK';

  String _kondisiAtap = 'TIDAK';

  String _mainholeTergenangAir = 'TIDAK';

  String _powerSupplyAC = 'ADA';

  String _kebersihanPanelDCBC = 'BERSIH';
  String _kebersihanRuangBaterai = 'BERSIH';
  String _kebersihanBaterai = 'BERSIH';
  String _kebocoranBaterai = 'TIDAK';
  String _exhaustFan = 'BERFUNGSI';
  String _kondisiRuangBaterai = 'TIDAK';

  String _kondisiRectifier = 'BAIK';
  String _kebersihanRuangRectifier = 'BERSIH';
  String _kebersihanPanel = 'BERSIH';

  String _kondisiMMI = 'BAIK';
  String _kondisiMouse = 'BAIK';
  String _kondisiKeyboard = 'BAIK';
  String _kondisiInternet = 'BAIK';
  String _kondisiRadio = 'BAIK';
  String _kondisiYealink = 'BAIK';

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _sipilId = p['sipilId'] is int
        ? p['sipilId'] as int
        : (p['id'] is int ? p['id'] as int : int.tryParse('${p['sipilId'] ?? p['id']}') ?? 0);
    _nama = p['nama']?.toString() ?? '-';
    _gedung = p['gedung']?.toString() ?? '-';
    _garduInduk = p['garduInduk']?.toString() ?? '-';

    final rawData = p['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    _id = data['id'] is int
        ? data['id'] as int
        : (p['id'] is int ? p['id'] as int : int.tryParse('${data['id'] ?? p['id']}') ?? 0);

    // Populate data
    _kondisiLampu = data['kondisiLampuPenerangan']?.toString() ?? 'BAIK';
    _jenisLampu = data['jenisLampuPenerangan']?.toString() ?? 'LED';
    _jumlahLampuController.text = data['jumlahLampuPenerangan']?.toString() ?? '0';
    _jumlahLampuMatiController.text = data['jumlahLampuPeneranganMati']?.toString() ?? '0';
    _keteranganLampuController.text = data['keteranganLampuPenerangan']?.toString() ?? '';

    _kondisiRuangan = data['kondisiRuangan']?.toString() ?? 'TIDAK';
    _jumlahAcNormalController.text = data['jumlahACMenyalaNormal']?.toString() ?? '0';
    _jumlahAcWindController.text = data['jumlahACWindOnly']?.toString() ?? '0';
    _jumlahAcBocorController.text = data['jumlahACBocor']?.toString() ?? '0';
    _keteranganAcController.text = data['keteranganAc']?.toString() ?? '';

    _kondisiAtap = data['kondisiAtap']?.toString() ?? 'TIDAK';
    _letakKebocoranAtapController.text = data['letakKebocoranAtap']?.toString() ?? '';

    _mainholeTergenangAir = data['mainholeTergenangAir']?.toString() ?? 'TIDAK';
    _powerSupplyAC = data['powerSupplyAC']?.toString() ?? 'ADA';

    _kebersihanPanelDCBC = data['kebersihanPanelDCBC']?.toString() ?? 'BERSIH';
    _kebersihanRuangBaterai = data['kebersihanRuangBaterai']?.toString() ?? 'BERSIH';
    _suhuRuangBateraiController.text = data['suhuRuangBaterai']?.toString() ?? '0.0';
    _kelembabanRuangBateraiController.text = data['kelembabanRuangBaterai']?.toString() ?? '0.0';
    _kebersihanBaterai = data['kebersihanBaterai']?.toString() ?? 'BERSIH';
    _kebocoranBaterai = data['kebocoranBaterai']?.toString() ?? 'TIDAK';
    _exhaustFan = data['exhaustFan']?.toString() ?? 'BERFUNGSI';
    _kondisiRuangBaterai = data['kondisiRuangBaterai']?.toString() ?? 'TIDAK';
    _teganganBebanController.text = data['teganganBeban']?.toString() ?? '0.0';
    _arusBebanController.text = data['arusBeban']?.toString() ?? '0.0';

    _kondisiRectifier = data['kondisiRectifier']?.toString() ?? 'BAIK';
    _kebersihanRuangRectifier = data['kebersihanRuangRectifier']?.toString() ?? 'BERSIH';
    _suhuRuangRectifierController.text = data['suhuRuangRectifier']?.toString() ?? '0.0';
    _kelembabanRuangRectifierController.text = data['kelembabanRuangRectifier']?.toString() ?? '0.0';
    _kebersihanPanel = data['kebersihanPanel']?.toString() ?? 'BERSIH';

    _kondisiMMI = data['kondisiMMI']?.toString() ?? 'BAIK';
    _kondisiMouse = data['kondisiMouseKomputer']?.toString() ?? 'BAIK';
    _kondisiKeyboard = data['kondisiKeyboardKomputer']?.toString() ?? 'BAIK';
    _kondisiInternet = data['kondisiInternet']?.toString() ?? 'BAIK';
    _kondisiRadio = data['kondisiRadio']?.toString() ?? 'BAIK';
    _kondisiYealink = data['kondisiYealink']?.toString() ?? 'BAIK';

    _initialDurasi = (data['durasi'] as num?)?.toDouble() ?? 0.0;
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

  Future<void> _handleUpdate() async {
    final cubit = context.read<OpgiIl1Cubit>();
    setState(() => _isSubmitting = true);

    final durasiMenit = _initialDurasi + (DateTime.now().difference(_startTime).inMilliseconds / 60000.0);

    final payload = <String, dynamic>{
      'id': _id,
      'sipilId': _sipilId,
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
      'durasi': durasiMenit,
      'timezone': 'Asia/Jakarta',
    };

    await cubit.updateSipil(
      id: _id,
      data: payload,
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
        title: Text('Update IL1 Sipil - $_gedung'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
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
                    _buildStaticRow('Gardu Induk', _garduInduk),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. LAMPU PENERANGAN
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

              // 3. AIR CONDITIONER
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

              // 4. KEBOCORAN ATAP
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

              // 5. COMPARTMEN MAINHOLE/BASEMENT
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

              // 6. POWER SUPPLY AC
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

              // 7. POWER SUPPLY DC
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

              // 8. RECTIFIER 110 V
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

              // 9. PERALATAN KOMPUTER DAN KOMUNIKASI
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
                onPressed: _isSubmitting ? null : _handleUpdate,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
