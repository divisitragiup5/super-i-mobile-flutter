import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_camera_widget.dart';
import '../../data/models/sutm_form_constants.dart';
import '../cubit/inspeksi_form_cubit.dart';

class DetailSutmPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const DetailSutmPage({
    super.key,
    required this.params,
  });

  @override
  State<DetailSutmPage> createState() => _DetailSutmPageState();
}

class _DetailSutmPageState extends State<DetailSutmPage> {
  late String _workOrderSutmItemId;
  late String _sutmId;
  late String _idAsset;
  late String _nama;
  late String _feederName;
  late double _latitude;
  late double _longitude;

  late DateTime _startTime;
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _workOrderSutmItemId = widget.params['workOrderSutmItemId']?.toString() ?? '0';
    _sutmId = widget.params['sutmId']?.toString() ?? '0';
    _idAsset = widget.params['idAsset']?.toString() ?? '-';
    _nama = widget.params['nama']?.toString() ?? widget.params['name']?.toString() ?? '-';
    _feederName = widget.params['feederName']?.toString() ?? '-';
    _latitude = double.tryParse(widget.params['latitude']?.toString() ?? '0') ?? 0.0;
    _longitude = double.tryParse(widget.params['longitude']?.toString() ?? '0') ?? 0.0;

    _startTime = DateTime.now();

    context.read<InspeksiFormCubit>().initForm(_workOrderSutmItemId);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
        context.read<InspeksiFormCubit>().updateTimer(_seconds, _workOrderSutmItemId);
      }
    });

    _resolveCurrentLocation();
  }

  Future<void> _resolveCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _latitude = pos.latitude;
          _longitude = pos.longitude;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _openCamera(String attachmentKey) async {
    final file = await FieldCameraWidget.takePhoto(
      context: context,
      title: 'Foto $attachmentKey',
    );
    if (file != null && mounted) {
      context.read<InspeksiFormCubit>().updateAttachment(
            attachmentKey,
            file,
            _workOrderSutmItemId,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto berhasil ditambahkan dengan watermark')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InspeksiFormCubit, InspeksiFormState>(
      listener: (context, state) {
        if (state is InspeksiFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state is InspeksiFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_idAsset),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    _formatTimer(_seconds),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: AppColors.backgroundLight),
              ),
            ),
            BlocBuilder<InspeksiFormCubit, InspeksiFormState>(
              builder: (context, state) {
                if (state is InspeksiFormSubmitting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final formValues = state is InspeksiFormLoaded
                    ? state.formValues
                    : <String, dynamic>{};
                final attachments = state is InspeksiFormLoaded
                    ? state.fileAttachments
                    : <String, File?>{};
                final activeStep = state is InspeksiFormLoaded
                    ? state.activeStep
                    : 0;

                return Column(
                  children: [
                    // Asset Info Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: AppColors.primary.withValues(alpha: 0.95),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nama,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _feederName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Auto-Draft Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step Indicator Tabs
                    Container(
                      height: 48,
                      color: Colors.white,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _buildStepTab(0, '1. Tiang', activeStep),
                          _buildStepTab(1, '2. Penghantar', activeStep),
                          _buildStepTab(2, '3. Isolator', activeStep),
                          _buildStepTab(3, '4. Proteksi', activeStep),
                          _buildStepTab(4, '5. Penopang', activeStep),
                          _buildStepTab(5, '6. Hubung', activeStep),
                          _buildStepTab(6, '7. ROW', activeStep),
                        ],
                      ),
                    ),

                    // Form Body Scroll
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activeStep == 0)
                                _buildStepTiang(formValues, attachments),
                              if (activeStep == 1)
                                _buildStepPenghantar(formValues, attachments),
                              if (activeStep == 2)
                                _buildStepIsolator(formValues, attachments),
                              if (activeStep == 3)
                                _buildStepProteksi(formValues, attachments),
                              if (activeStep == 4)
                                _buildStepPenopang(formValues, attachments),
                              if (activeStep == 5)
                                _buildStepHubung(formValues, attachments),
                              if (activeStep == 6)
                                _buildStepRow(formValues, attachments),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bottom Navigation Buttons
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (activeStep > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  context.read<InspeksiFormCubit>().setStep(
                                        activeStep - 1,
                                        _workOrderSutmItemId,
                                      );
                                },
                                child: const Text('Sebelumnya'),
                              ),
                            ),
                          if (activeStep > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activeStep == 6
                                    ? AppColors.success
                                    : AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                if (activeStep < 6) {
                                  context.read<InspeksiFormCubit>().setStep(
                                        activeStep + 1,
                                        _workOrderSutmItemId,
                                      );
                                } else {
                                  // Submit Form
                                  context.read<InspeksiFormCubit>().submitForm(
                                        workOrderSutmItemId: int.tryParse(_workOrderSutmItemId),
                                        sutmId: int.tryParse(_sutmId),
                                        latitude: _latitude,
                                        longitude: _longitude,
                                        startTime: _startTime,
                                      );
                                }
                              },
                              child: Text(
                                activeStep == 6 ? 'Kirim Inspeksi' : 'Selanjutnya',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTab(int step, String label, int activeStep) {
    final isCurrent = step == activeStep;
    return GestureDetector(
      onTap: () {
        context.read<InspeksiFormCubit>().setStep(step, _workOrderSutmItemId);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isCurrent ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              color: isCurrent ? AppColors.primary : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // 1. Step Tiang
  Widget _buildStepTiang(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Tiang',
          value: formValues['1_jenis_tiang'] as String?,
          options: SutmFormConstants.jenisTiangOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('1_jenis_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Tinggi Tiang',
          value: formValues['1_tinggi_tiang'] as String?,
          options: SutmFormConstants.tinggiTiangOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('1_tinggi_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Kondisi Tiang',
          value: formValues['1_kondisi_tiang'] as String?,
          options: SutmFormConstants.kondisiTiangOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('1_kondisi_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Identitas Tiang',
          value: formValues['1_identitas_tiang'] as String?,
          options: SutmFormConstants.identitasTiangOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('1_identitas_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Jenis Konstruksi',
          value: formValues['1_jenis_konstruksi'] as String?,
          options: SutmFormConstants.jenisKonstruksiOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('1_jenis_konstruksi', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        _buildPhotoField(
          label: 'Foto Konstruksi Tiang',
          file: attachments['konstruksiFoto'],
          onTap: () => _openCamera('konstruksiFoto'),
        ),
      ],
    );
  }

  // 2. Step Penghantar
  Widget _buildStepPenghantar(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Konduktor',
          value: formValues['2_jenis_konduktor'] as String?,
          options: SutmFormConstants.jenisKonduktorOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('2_jenis_konduktor', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Ukuran Konduktor',
          value: formValues['2_ukuran_konduktor'] as String?,
          options: SutmFormConstants.ukuranKonduktorOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('2_ukuran_konduktor', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        const Text(
          'Kondisi Konduktor Per Fasa',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ...SutmFormConstants.fasaList.map((fasa) {
          final key = '2_konduktor_fasa_${fasa.toLowerCase()}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDropdown(
              label: 'Fasa $fasa',
              value: formValues[key] as String?,
              options: SutmFormConstants.kondisiKonduktorOptions,
              onChanged: (val) => context
                  .read<InspeksiFormCubit>()
                  .updateField(key, val, _workOrderSutmItemId),
            ),
          );
        }),
        const SizedBox(height: 12),
        _buildPhotoField(
          label: 'Foto Konduktor',
          file: attachments['konduktorFoto'],
          onTap: () => _openCamera('konduktorFoto'),
        ),
      ],
    );
  }

  // 3. Step Isolator
  Widget _buildStepIsolator(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kondisi Isolator Tumpu',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        ...SutmFormConstants.fasaList.map((fasa) {
          final key = '3_isolator_tumpu_fasa_${fasa.toLowerCase()}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDropdown(
              label: 'Isolator Tumpu Fasa $fasa',
              value: formValues[key] as String?,
              options: SutmFormConstants.kondisiIsolatorOptions,
              onChanged: (val) => context
                  .read<InspeksiFormCubit>()
                  .updateField(key, val, _workOrderSutmItemId),
            ),
          );
        }),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Kondisi Cross Arm / Travers',
          value: formValues['3_cross_arm'] as String?,
          options: SutmFormConstants.kondisiCrossArmOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('3_cross_arm', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        _buildPhotoField(
          label: 'Foto Isolator & Travers',
          file: attachments['isolatorFoto'],
          onTap: () => _openCamera('isolatorFoto'),
        ),
      ],
    );
  }

  // 4. Step Proteksi
  Widget _buildStepProteksi(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Letak GSW',
          value: formValues['4_gsw_letak'] as String?,
          options: SutmFormConstants.gswLetakOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('4_gsw_letak', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Kondisi Grounding',
          value: formValues['4_grounding'] as String?,
          options: SutmFormConstants.kondisiGroundingOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('4_grounding', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        _buildPhotoField(
          label: 'Foto Grounding',
          file: attachments['groundingFoto'],
          onTap: () => _openCamera('groundingFoto'),
        ),
      ],
    );
  }

  // 5. Step Penopang
  Widget _buildStepPenopang(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Konstruksi Penopang',
          value: formValues['5_penopang_jenis'] as String?,
          options: SutmFormConstants.jenisPenopangOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('5_penopang_jenis', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Kondisi Konstruksi Penopang',
          value: formValues['5_penopang_kondisi'] as String?,
          options: SutmFormConstants.kondisiPenopangOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('5_penopang_kondisi', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        _buildPhotoField(
          label: 'Foto Konstruksi Penopang',
          file: attachments['penopangFoto'],
          onTap: () => _openCamera('penopangFoto'),
        ),
      ],
    );
  }

  // 6. Step Hubung
  Widget _buildStepHubung(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'LBS Konvensional',
          value: formValues['6_lbs'] as String?,
          options: SutmFormConstants.lbsOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('6_lbs', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Recloser',
          value: formValues['6_recloser'] as String?,
          options: SutmFormConstants.recloserOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('6_recloser', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        _buildPhotoField(
          label: 'Foto Peralatan Hubung',
          file: attachments['hubungFoto'],
          onTap: () => _openCamera('hubungFoto'),
        ),
      ],
    );
  }

  // 7. Step ROW
  Widget _buildStepRow(
    Map<String, dynamic> formValues,
    Map<String, File?> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Pohon',
          value: formValues['7_jenis_pohon'] as String?,
          options: SutmFormConstants.jenisPohonOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('7_jenis_pohon', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Jarak ke Jaringan',
          value: formValues['7_jarak_row'] as String?,
          options: SutmFormConstants.jarakRowOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('7_jarak_row', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          label: 'Tindakan yang Diperlukan',
          value: formValues['7_tindakan_row'] as String?,
          options: SutmFormConstants.jenisTindakanRowOptions,
          onChanged: (val) => context
              .read<InspeksiFormCubit>()
              .updateField('7_tindakan_row', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 20),
        _buildPhotoField(
          label: 'Foto ROW / Pohon Terdekat',
          file: attachments['rowFoto'],
          onTap: () => _openCamera('rowFoto'),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value != null && options.contains(value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          hint: Text('Pilih $label', style: const TextStyle(fontSize: 12)),
          items: options
              .map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt, style: const TextStyle(fontSize: 13)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPhotoField({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: file != null && file.existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 36, color: Colors.grey.shade500),
                      const SizedBox(height: 6),
                      Text(
                        'Ambil Foto Watermark',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
