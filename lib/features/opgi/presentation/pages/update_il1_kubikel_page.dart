import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/input_container.dart';
import '../constants/opgi_il1_constants.dart';
import '../cubit/opgi_il1_cubit.dart';
import '../widgets/il1_dropdown_field.dart';
import '../widgets/il1_multi_select_field.dart';

class UpdateIl1KubikelPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const UpdateIl1KubikelPage({super.key, required this.params});

  @override
  State<UpdateIl1KubikelPage> createState() => _UpdateIl1KubikelPageState();
}

class _UpdateIl1KubikelPageState extends State<UpdateIl1KubikelPage> {
  final _formKey = GlobalKey<FormState>();

  late int _id;
  late String _nama;
  late String _garduInduk;
  late int _garduIndukId;

  late DateTime _startTime;
  double _initialDurasi = 0.0;

  // Controllers
  final _merkController = TextEditingController();
  final _arusNetralController = TextEditingController(text: '0.0');
  final _teganganUfrController = TextEditingController(text: '0.0');
  final _anomaliDetailController = TextEditingController();

  int? _trafoId;
  String? _rel;
  List<Map<String, dynamic>> _trafoList = [];
  List<Map<String, dynamic>> _relList = [];

  String _statusPMT = 'CLOSE';
  String _rackPMT = 'RACK IN';
  List<String> _keteranganPMT = ['NORMAL'];
  String _kondisiSF6 = 'GOOD';
  String _indikatorPegas = 'CHARGE';

  String _bendaAsing = 'TIDAK';
  String _binatang = 'TIDAK';
  String _tetesanAir = 'TIDAK';
  String _desis = 'TIDAK';
  String _bau = 'TIDAK';
  String _kondisiLVPanel = 'BERSIH';
  String _lampuLVPanel = 'NYALA';

  String _indikatorPMTClose = 'NYALA';
  String _indikatorPMTOpen = 'TIDAK';
  String _indikatorTegangan = 'NYALA';

  String _tampilanLCDOCR = 'NORMAL';
  String _indikatorHealthyOCR = 'NYALA';

  String _keteranganRelayUFR = 'TIDAK ADA';
  String _tampilanLCDUFR = 'NORMAL';
  String _selectorUFR = '0';

  String _tampilanLCDKWH = 'NORMAL';
  String _tombolKWH = 'NORMAL';

  String _kondisiAlarm = 'ADA';

  String _keteranganAnomali = 'TIDAK ADA';

  File? _newFotoAnomali;
  String? _initialFotoAnomaliUrl;
  String? _fotoBuktiInspeksiUrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();

    final p = widget.params;
    _id = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}') ?? 0;
    _nama = p['nama']?.toString() ?? '-';
    _garduInduk = p['garduInduk']?.toString() ?? '-';
    _garduIndukId = p['garduIndukId'] is int
        ? p['garduIndukId'] as int
        : int.tryParse('${p['garduIndukId']}') ?? 0;

    final rawData = p['data'];
    final data = rawData is Map<String, dynamic>
        ? rawData
        : <String, dynamic>{};

    _initFromData(data);
    _loadAuxiliary();
  }

  void _initFromData(Map<String, dynamic> data) {
    if (data['merkKubikel'] != null) {
      _merkController.text = data['merkKubikel'].toString();
    }
    if (data['trafoId'] != null) _trafoId = int.tryParse('${data['trafoId']}');
    if (data['rel'] != null) _rel = data['rel'].toString();

    if (data['statusPMT'] != null) _statusPMT = data['statusPMT'].toString();
    if (data['rackPMT'] != null) _rackPMT = data['rackPMT'].toString();
    if (data['keteranganPMT'] is List) {
      _keteranganPMT = (data['keteranganPMT'] as List)
          .map((e) => e.toString())
          .toList();
    }
    if (data['kondisiSF6PMT'] != null) {
      _kondisiSF6 = data['kondisiSF6PMT'].toString();
    }
    if (data['indikatorPegasMekanikPMT'] != null) {
      _indikatorPegas = data['indikatorPegasMekanikPMT'].toString();
    }

    if (data['bendaAsing'] != null) _bendaAsing = data['bendaAsing'].toString();
    if (data['binatang'] != null) _binatang = data['binatang'].toString();
    if (data['tetesanAir'] != null) _tetesanAir = data['tetesanAir'].toString();
    if (data['desis'] != null) _desis = data['desis'].toString();
    if (data['bau'] != null) _bau = data['bau'].toString();
    if (data['kondisiLVPanel'] != null) {
      _kondisiLVPanel = data['kondisiLVPanel'].toString();
    }
    if (data['lampuLVPanel'] != null) {
      _lampuLVPanel = data['lampuLVPanel'].toString();
    }

    if (data['indikatorPMTClose'] != null) {
      _indikatorPMTClose = data['indikatorPMTClose'].toString();
    }
    if (data['indikatorPMTOpen'] != null) {
      _indikatorPMTOpen = data['indikatorPMTOpen'].toString();
    }
    if (data['indikatorTeganganKubikel'] != null) {
      _indikatorTegangan = data['indikatorTeganganKubikel'].toString();
    }

    if (data['tampilanLCDRelayOCR'] != null) {
      _tampilanLCDOCR = data['tampilanLCDRelayOCR'].toString();
    }
    if (data['indikatorHealthyRelayOCR'] != null) {
      _indikatorHealthyOCR = data['indikatorHealthyRelayOCR'].toString();
    }
    if (data['pembacaanArusNetralRelayOCR'] != null) {
      _arusNetralController.text = data['pembacaanArusNetralRelayOCR']
          .toString();
    }

    if (data['keteranganRelayUFR'] != null) {
      _keteranganRelayUFR = data['keteranganRelayUFR'].toString();
    }
    if (data['tampilanLCDRelayUFR'] != null) {
      _tampilanLCDUFR = data['tampilanLCDRelayUFR'].toString();
    }
    if (data['pembacaanTeganganRelayUFR'] != null) {
      _teganganUfrController.text = data['pembacaanTeganganRelayUFR']
          .toString();
    }
    if (data['selectorUFR'] != null) {
      _selectorUFR = data['selectorUFR'].toString();
    }

    if (data['tampilanLCDKWHMeter'] != null) {
      _tampilanLCDKWH = data['tampilanLCDKWHMeter'].toString();
    }
    if (data['tombolKWHMeter'] != null) {
      _tombolKWH = data['tombolKWHMeter'].toString();
    }

    if (data['kondisiAlarm'] != null) {
      _kondisiAlarm = data['kondisiAlarm'].toString();
    }

    if (data['keteranganAnomali'] != null) {
      _keteranganAnomali = data['keteranganAnomali'].toString();
    }
    if (data['anomali'] != null) {
      _anomaliDetailController.text = data['anomali'].toString();
    }

    _initialDurasi = (data['durasi'] as num?)?.toDouble() ?? 0.0;

    final fotoBukti = data['fotoBuktiInspeksi'];
    if (fotoBukti is Map) {
      _fotoBuktiInspeksiUrl =
          fotoBukti['uri']?.toString() ?? fotoBukti['path']?.toString();
    } else if (fotoBukti is String) {
      _fotoBuktiInspeksiUrl = fotoBukti;
    }

    final fotoAnom = data['fotoAnomali'];
    if (fotoAnom is Map) {
      _initialFotoAnomaliUrl =
          fotoAnom['uri']?.toString() ?? fotoAnom['path']?.toString();
    } else if (fotoAnom is String) {
      _initialFotoAnomaliUrl = fotoAnom;
    }
  }

  Future<void> _loadAuxiliary() async {
    final cubit = context.read<OpgiIl1Cubit>();
    try {
      final trafos = await cubit.getTrafoList(_garduIndukId);
      final rels = await cubit.getRelList(_garduIndukId);
      if (mounted) {
        setState(() {
          _trafoList = trafos;
          _relList = rels;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _merkController.dispose();
    _arusNetralController.dispose();
    _teganganUfrController.dispose();
    _anomaliDetailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    setState(() => _isSubmitting = true);

    final durasiMenit =
        _initialDurasi +
        (DateTime.now().difference(_startTime).inMilliseconds / 60000.0);

    final payload = <String, dynamic>{
      'id': _id,
      'merkKubikel': _merkController.text.trim(),
      'trafoId': _trafoId,
      'rel': _rel,
      'statusPMT': _statusPMT,
      'rackPMT': _rackPMT,
      'keteranganPMT': _keteranganPMT,
      'kondisiSF6PMT': _kondisiSF6,
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
      'tampilanLCDRelayOCR': _tampilanLCDOCR,
      'indikatorHealthyRelayOCR': _indikatorHealthyOCR,
      'pembacaanArusNetralRelayOCR':
          double.tryParse(_arusNetralController.text.trim()) ?? 0.0,
      'keteranganRelayUFR': _keteranganRelayUFR,
      if (_keteranganRelayUFR == 'ADA') ...{
        'tampilanLCDRelayUFR': _tampilanLCDUFR,
        'pembacaanTeganganRelayUFR':
            double.tryParse(_teganganUfrController.text.trim()) ?? 0.0,
        'selectorUFR': int.tryParse(_selectorUFR) ?? 0,
      },
      'tampilanLCDKWHMeter': _tampilanLCDKWH,
      'tombolKWHMeter': _tombolKWH,
      'kondisiAlarm': _kondisiAlarm,
      'keteranganAnomali': _keteranganAnomali,
      if (_keteranganAnomali == 'ADA') ...{
        'anomali': _anomaliDetailController.text.trim(),
      },
      'durasi': durasiMenit,
      'timezone': 'Asia/Jakarta',
    };

    final cubit = context.read<OpgiIl1Cubit>();
    await cubit.updateKubikel(
      id: _id,
      data: payload,
      fotoAnomali: _newFotoAnomali?.path,
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
        title: Text('Update IL1 Kubikel - $_nama'),
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
                    Text(
                      'Nama',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gardu Induk',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _garduInduk,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _merkController,
                      decoration: const InputDecoration(
                        labelText: 'Merk Kubikel',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      initialValue: _trafoId,
                      decoration: const InputDecoration(
                        labelText: 'Trafo',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _trafoList.map((t) {
                        final id = t['id'] is int
                            ? t['id'] as int
                            : int.tryParse('${t['id']}') ?? 0;
                        final nama = t['nama']?.toString() ?? '-';
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text(nama),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _trafoId = val),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _rel,
                      decoration: const InputDecoration(
                        labelText: 'Rel',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: _relList.map((r) {
                        final relName =
                            r['rel']?.toString() ??
                            r['nama']?.toString() ??
                            '-';
                        return DropdownMenuItem<String>(
                          value: relName,
                          child: Text(relName),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _rel = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================
              // FOTO BUKTI INSPEKSI (Read-Only)
              // ==========================================
              if (_fotoBuktiInspeksiUrl != null &&
                  _fotoBuktiInspeksiUrl!.trim().isNotEmpty) ...[
                InputContainer(
                  label: 'FOTO BUKTI INSPEKSI',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      AppUrlUtils.getFullImageUrl(_fotoBuktiInspeksiUrl),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.grey,
                              size: 36,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Gagal memuat foto bukti inspeksi',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              // 2. KONDISI PMT
              InputContainer(
                label: 'KONDISI PMT',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Close/Open',
                      options: OpgiIl1Constants.kubikelCloseOpen,
                      selectedValue: _statusPMT,
                      onChanged: (val) =>
                          setState(() => _statusPMT = val ?? 'CLOSE'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Rack In/Rack Out',
                      options: OpgiIl1Constants.kubikelRackInOut,
                      selectedValue: _rackPMT,
                      onChanged: (val) =>
                          setState(() => _rackPMT = val ?? 'RACK IN'),
                    ),
                    const SizedBox(height: 12),
                    Il1MultiSelectField(
                      label: 'Keterangan PMT',
                      options: OpgiIl1Constants.kubikelKeteranganPMT,
                      selectedValues: _keteranganPMT,
                      onChanged: (vals) =>
                          setState(() => _keteranganPMT = vals),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi SF6',
                      options: OpgiIl1Constants.kubikelKondisiSF6,
                      selectedValue: _kondisiSF6,
                      onChanged: (val) =>
                          setState(() => _kondisiSF6 = val ?? 'GOOD'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Indikator Pegas Mekanik PMT',
                      options: OpgiIl1Constants.kubikelPegasMekanik,
                      selectedValue: _indikatorPegas,
                      onChanged: (val) =>
                          setState(() => _indikatorPegas = val ?? 'CHARGE'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. VISUAL MVCELL
              InputContainer(
                label: 'VISUAL MVCELL',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Benda Asing',
                      options: OpgiIl1Constants.adaTidak,
                      selectedValue: _bendaAsing,
                      onChanged: (val) =>
                          setState(() => _bendaAsing = val ?? 'TIDAK'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Binatang',
                      options: OpgiIl1Constants.adaTidak,
                      selectedValue: _binatang,
                      onChanged: (val) =>
                          setState(() => _binatang = val ?? 'TIDAK'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Tetesan Air',
                      options: OpgiIl1Constants.adaTidak,
                      selectedValue: _tetesanAir,
                      onChanged: (val) =>
                          setState(() => _tetesanAir = val ?? 'TIDAK'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Bunyi-bunyian/Desis',
                      options: OpgiIl1Constants.adaTidak,
                      selectedValue: _desis,
                      onChanged: (val) =>
                          setState(() => _desis = val ?? 'TIDAK'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Bau-bauan',
                      options: OpgiIl1Constants.adaTidak,
                      selectedValue: _bau,
                      onChanged: (val) => setState(() => _bau = val ?? 'TIDAK'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Kondisi LV Panel',
                      options: OpgiIl1Constants.bersihTidak,
                      selectedValue: _kondisiLVPanel,
                      onChanged: (val) =>
                          setState(() => _kondisiLVPanel = val ?? 'BERSIH'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Lampu LV Panel',
                      options: OpgiIl1Constants.nyalaTidak,
                      selectedValue: _lampuLVPanel,
                      onChanged: (val) =>
                          setState(() => _lampuLVPanel = val ?? 'NYALA'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. INDIKATOR MVCELL
              InputContainer(
                label: 'INDIKATOR MVCELL',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Indikator PMT Close',
                      options: OpgiIl1Constants.nyalaTidak,
                      selectedValue: _indikatorPMTClose,
                      onChanged: (val) =>
                          setState(() => _indikatorPMTClose = val ?? 'NYALA'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Indikator PMT Open',
                      options: OpgiIl1Constants.nyalaTidak,
                      selectedValue: _indikatorPMTOpen,
                      onChanged: (val) =>
                          setState(() => _indikatorPMTOpen = val ?? 'TIDAK'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Indikator Tegangan Kubikel',
                      options: OpgiIl1Constants.nyalaTidak,
                      selectedValue: _indikatorTegangan,
                      onChanged: (val) =>
                          setState(() => _indikatorTegangan = val ?? 'NYALA'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. RELAY OCR
              InputContainer(
                label: 'RELAY OCR',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Tampilan LCD',
                      options: OpgiIl1Constants.normalBlank,
                      selectedValue: _tampilanLCDOCR,
                      onChanged: (val) =>
                          setState(() => _tampilanLCDOCR = val ?? 'NORMAL'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Indikator Healthy',
                      options: OpgiIl1Constants.nyalaTidak,
                      selectedValue: _indikatorHealthyOCR,
                      onChanged: (val) =>
                          setState(() => _indikatorHealthyOCR = val ?? 'NYALA'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _arusNetralController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Pembacaan Arus Netral (A)',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 6. RELAY UFR
              InputContainer(
                label: 'RELAY UFR',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Keterangan Relay UFR',
                      options: OpgiIl1Constants.relayUfrKeterangan,
                      selectedValue: _keteranganRelayUFR,
                      onChanged: (val) => setState(
                        () => _keteranganRelayUFR = val ?? 'TIDAK ADA',
                      ),
                    ),
                    if (_keteranganRelayUFR == 'ADA') ...[
                      const SizedBox(height: 12),
                      Il1DropdownField(
                        label: 'Tampilan LCD',
                        options: OpgiIl1Constants.normalBlank,
                        selectedValue: _tampilanLCDUFR,
                        onChanged: (val) =>
                            setState(() => _tampilanLCDUFR = val ?? 'NORMAL'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _teganganUfrController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Pembacaan Tegangan (V)',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Il1DropdownField(
                        label: 'Selector UFR',
                        options: OpgiIl1Constants.selectorUfr,
                        selectedValue: _selectorUFR,
                        onChanged: (val) =>
                            setState(() => _selectorUFR = val ?? '0'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 7. KWH METER
              InputContainer(
                label: 'KWH METER',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Tampilan LCD',
                      options: OpgiIl1Constants.normalBlank,
                      selectedValue: _tampilanLCDKWH,
                      onChanged: (val) =>
                          setState(() => _tampilanLCDKWH = val ?? 'NORMAL'),
                    ),
                    const SizedBox(height: 12),
                    Il1DropdownField(
                      label: 'Tombol KWh Meter',
                      options: OpgiIl1Constants.kwhTombol,
                      selectedValue: _tombolKWH,
                      onChanged: (val) =>
                          setState(() => _tombolKWH = val ?? 'NORMAL'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 8. ALARM CELL
              InputContainer(
                label: 'ALARM CELL',
                child: Il1DropdownField(
                  label: 'Kondisi Alarm',
                  options: OpgiIl1Constants.alarmKondisi,
                  selectedValue: _kondisiAlarm,
                  onChanged: (val) =>
                      setState(() => _kondisiAlarm = val ?? 'ADA'),
                ),
              ),
              const SizedBox(height: 16),

              // 9. ANOMALI
              InputContainer(
                label: 'ANOMALI',
                child: Column(
                  children: [
                    Il1DropdownField(
                      label: 'Keterangan Anomali',
                      options: OpgiIl1Constants.anomaliKeterangan,
                      selectedValue: _keteranganAnomali,
                      onChanged: (val) => setState(
                        () => _keteranganAnomali = val ?? 'TIDAK ADA',
                      ),
                    ),
                    if (_keteranganAnomali == 'ADA') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _anomaliDetailController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Anomali',
                          hintText: 'Tuliskan deskripsi anomali...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FieldPictInput(
                        label: 'Update Foto Anomali',
                        placeholder: 'Ambil Foto Baru (Opsional)',
                        pictureFile: _newFotoAnomali,
                        initialUrl: _initialFotoAnomaliUrl,
                        onChange: (file) =>
                            setState(() => _newFotoAnomali = file),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // UPDATE BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleUpdate,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Update Inspeksi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
