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
import '../widgets/il1_multi_select_field.dart';

class UpdateIl1TrafoPsPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateIl1TrafoPsPage({
    super.key,
    required this.params,
  });

  @override
  State<UpdateIl1TrafoPsPage> createState() => _UpdateIl1TrafoPsPageState();
}

class _UpdateIl1TrafoPsPageState extends State<UpdateIl1TrafoPsPage> {
  final _formKey = GlobalKey<FormState>();

  late int _trafoId;
  late int _id; // inspection id
  late String _nama;

  late DateTime _startTime;
  double _initialDurasi = 0.0;

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

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _trafoId = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _nama = p['nama']?.toString() ?? '-';

    final rawData = p['data'];
    final data = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};
    _id = data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}') ?? 0;

    final trafoObj = data['trafo'] as Map<String, dynamic>?;

    _merkController.text = data['merkTrafo']?.toString() ?? trafoObj?['merkTrafo']?.toString() ?? '';
    _tahunPembuatanController.text = data['tahunPembuatanTrafo']?.toString() ?? trafoObj?['tahunPembuatanTrafo']?.toString() ?? '';
    _noSeriController.text = data['noSeriTrafo']?.toString() ?? trafoObj?['noSeriTrafo']?.toString() ?? '';
    _kapasitasController.text = data['kapasitasTrafo']?.toString() ?? trafoObj?['kapasitasTrafo']?.toString() ?? '';
    _tapController.text = data['tapTrafo']?.toString() ?? trafoObj?['tapTrafo']?.toString() ?? '';
    _jenisTrafo = data['jenisTrafo']?.toString() ?? trafoObj?['jenisTrafo']?.toString() ?? 'INDOOR';

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

  Future<void> _handleUpdate() async {
    final cubit = context.read<OpgiIl1Cubit>();
    setState(() => _isSubmitting = true);

    final durasiMenit = _initialDurasi + (DateTime.now().difference(_startTime).inMilliseconds / 60000.0);

    final payload = <String, dynamic>{
      'id': _id,
      'trafoId': _trafoId,
      'merkTrafo': _merkController.text.trim(),
      'tahunPembuatanTrafo': _tahunPembuatanController.text.trim(),
      'noSeriTrafo': _noSeriController.text.trim(),
      'kapasitasTrafo': _kapasitasController.text.trim(),
      'tapTrafo': _tapController.text.trim(),
      'jenisTrafo': _jenisTrafo,
      'kebocoranBodyTrafo': _kebocoranBodyTrafo,
      'kondisiFisikTrafo': _kondisiFisikTrafo,
      'kondisiRumahTrafo': _kondisiRumahTrafo,
      'durasi': durasiMenit,
      'timezone': 'Asia/Jakarta',
    };

    await cubit.updateTrafoPs(
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
        title: Text('Update IL1 Trafo PS - $_nama'),
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
                label: 'INFO',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(_nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

              // 2. KETERANGAN BODY TRAFO
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

              // 3. KONDISI FISIK TRAFO
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

              // 4. KONDISI RUMAH TRAFO
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
                onPressed: _isSubmitting ? null : _handleUpdate,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Update Inspeksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
