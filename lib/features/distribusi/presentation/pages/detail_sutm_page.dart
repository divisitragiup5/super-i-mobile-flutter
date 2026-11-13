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
  late String _inspectionId;
  late String _idAsset;
  late String _nama;
  late String _feederName;
  late String _mode; // 'form' | 'view' | 'validate'
  late double _latitude;
  late double _longitude;

  late DateTime _startTime;
  Timer? _timer;
  int _seconds = 0;

  final Map<String, String> _validationErrors = {};

  bool get _isValidateMode => _mode == 'validate';
  bool get _isViewMode => _mode == 'view';
  bool get _isReadOnly => _isViewMode;

  @override
  void initState() {
    super.initState();
    _workOrderSutmItemId = widget.params['workOrderSutmItemId']?.toString() ??
        widget.params['id']?.toString() ??
        '0';
    _sutmId = widget.params['sutmId']?.toString() ??
        widget.params['id']?.toString() ??
        '0';
    _inspectionId = widget.params['inspectionId']?.toString() ?? '0';
    _idAsset = widget.params['idAsset']?.toString() ??
        widget.params['id']?.toString() ??
        '-';
    _nama = widget.params['nama']?.toString() ??
        widget.params['name']?.toString() ??
        '-';
    _feederName = widget.params['feederName']?.toString() ?? '-';
    _mode = widget.params['mode']?.toString() ?? 'form';
    _latitude = double.tryParse(widget.params['latitude']?.toString() ?? '0') ?? 0.0;
    _longitude = double.tryParse(widget.params['longitude']?.toString() ?? '0') ?? 0.0;

    _startTime = DateTime.now();

    final cubit = context.read<InspeksiFormCubit>();
    if (_isValidateMode || _isViewMode) {
      cubit.loadRemoteInspection(_workOrderSutmItemId, isReadOnly: _isReadOnly);
    } else {
      cubit.initForm(_workOrderSutmItemId);
    }

    if (!_isViewMode) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _seconds++;
          });
          cubit.updateTimer(_seconds, _workOrderSutmItemId);
        }
      });
    }

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
      setState(() {
        _validationErrors.remove(attachmentKey);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto berhasil ditambahkan dengan watermark'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showPhotoPreview(dynamic fileOrUrl, String title, {String? attachmentKey}) {
    if (fileOrUrl == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                // Interactive Image View with Zoom / Pinch
                Expanded(
                  child: Center(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: fileOrUrl is File
                          ? Image.file(
                              fileOrUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('Gagal memuat gambar',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            )
                          : Image.network(
                              fileOrUrl.toString(),
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Text('Gagal memuat gambar',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                    ),
                  ),
                ),
                // Footer Buttons
                if (!_isReadOnly && attachmentKey != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Ambil Ulang Foto'),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _openCamera(attachmentKey);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Multi-Select Dialog for Kondisi Tiang
  void _showMultiSelectKondisiTiang(
    BuildContext context,
    String? currentValue,
    Function(String) onSelected,
  ) {
    final List<String> currentSelections = currentValue != null && currentValue.isNotEmpty
        ? currentValue.split(',').map((s) => s.trim()).toList()
        : [];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Pilih Kondisi Tiang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: SutmFormConstants.kondisiTiangOptions.map((option) {
                    final isChecked = currentSelections.contains(option);
                    return CheckboxListTile(
                      title: Text(option, style: const TextStyle(fontSize: 14)),
                      value: isChecked,
                      onChanged: (val) {
                        setDialogState(() {
                          if (option == 'Baik') {
                            if (val == true) {
                              currentSelections.clear();
                              currentSelections.add('Baik');
                            } else {
                              currentSelections.remove('Baik');
                            }
                          } else {
                            currentSelections.remove('Baik');
                            if (val == true) {
                              currentSelections.add(option);
                            } else {
                              currentSelections.remove(option);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final result = currentSelections.join(', ');
                    onSelected(result);
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Validasi Step Sekarang
  bool _validateStep(
    int step,
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    if (_isReadOnly || _isValidateMode) return true;
    _validationErrors.clear();

    void checkRequired(String key, String label) {
      final val = formValues[key];
      if (val == null || val.toString().trim().isEmpty) {
        _validationErrors[key] = '$label wajib diisi';
      }
    }

    void checkAttachmentRequired(String key, String label, bool isRequired) {
      if (isRequired) {
        final att = attachments[key];
        if (att == null) {
          _validationErrors[key] = 'Foto $label wajib dilampirkan';
        }
      }
    }

    if (step == 0) {
      // 1. Tiang
      checkRequired('1_jenis_tiang', 'Jenis Tiang');
      checkRequired('1_tinggi_tiang', 'Tinggi Tiang');
      checkRequired('1_kondisi_tiang', 'Kondisi Tiang');
      checkRequired('1_identitas_tiang', 'Identitas Tiang');
      checkRequired('1_jenis_konstruksi', 'Jenis Konstruksi');

      final kondisiTiang = formValues['1_kondisi_tiang']?.toString() ?? '';
      final isKondisiTiangBaik = kondisiTiang.contains('Baik');
      checkAttachmentRequired('kondisiTiangFoto', 'Kondisi Tiang', !isKondisiTiangBaik && kondisiTiang.isNotEmpty);
      checkAttachmentRequired('jenisKonstruksiFoto', 'Konstruksi Tiang', true);
    } else if (step == 1) {
      // 2. Penghantar
      checkRequired('2_jenis_konduktor', 'Jenis Konduktor');
      checkRequired('2_ukuran_konduktor', 'Ukuran Konduktor');
      checkAttachmentRequired('jenisKonduktorFoto', 'Jenis Konduktor', true);

      for (final f in ['r', 's', 't']) {
        final fasaUpper = f.toUpperCase();
        checkRequired('2_konduktor_fasa_$f', 'Konduktor Fasa $fasaUpper');
        final kondisi = formValues['2_konduktor_fasa_$f']?.toString() ?? 'Baik';
        checkAttachmentRequired('konduktorFoto$fasaUpper', 'Konduktor Fasa $fasaUpper', kondisi != 'Baik');

        checkRequired('2_sambungan_fasa_$f', 'Sambungan Fasa $fasaUpper');
        final sambungan = formValues['2_sambungan_fasa_$f']?.toString() ?? 'Tidak Ada';
        checkAttachmentRequired('sambunganFoto$fasaUpper', 'Sambungan Fasa $fasaUpper', sambungan != 'Tidak Ada');

        checkRequired('2_terminasi_fasa_$f', 'Terminasi Fasa $fasaUpper');
        final terminasi = formValues['2_terminasi_fasa_$f']?.toString() ?? 'Tidak Ada';
        checkAttachmentRequired('terminasiFoto$fasaUpper', 'Terminasi Fasa $fasaUpper', terminasi != 'Tidak Ada');
      }
    } else if (step == 2) {
      // 3. Isolator
      final jenisKonstr = formValues['1_jenis_konstruksi']?.toString() ?? 'TM 1';
      final useTm13 = jenisKonstr == 'TM 1' || jenisKonstr == 'TM 3';
      final suffix = useTm13 ? 'tm_1_3' : 'tm_5';

      checkRequired('3_jenis_isolator_$suffix', 'Jenis Isolator');

      for (final f in ['r', 's', 't']) {
        final fasaUpper = f.toUpperCase();
        checkRequired('3_isolator_tumpu_${suffix}_fasa_$f', 'Isolator Tumpu Fasa $fasaUpper');
        final kondisiTumpu = formValues['3_isolator_tumpu_${suffix}_fasa_$f']?.toString() ?? 'Baik';
        checkAttachmentRequired('isolatorTumpuFoto$fasaUpper', 'Isolator Tumpu Fasa $fasaUpper', kondisiTumpu != 'Baik');

        checkRequired('3_top_ties_${suffix}_fasa_$f', 'Top Ties Fasa $fasaUpper');
        final kondisiTopTies = formValues['3_top_ties_${suffix}_fasa_$f']?.toString() ?? 'Baik';
        checkAttachmentRequired('topTiesFoto$fasaUpper', 'Top Ties Fasa $fasaUpper', kondisiTopTies != 'Baik');
      }

      checkRequired('3_cross_arm_$suffix', 'Cross Arm');
      final crossArm = formValues['3_cross_arm_$suffix']?.toString() ?? 'Baik';
      checkAttachmentRequired('crossArmFoto', 'Cross Arm', crossArm != 'Baik');

      if (useTm13) {
        checkRequired('3_arm_tie_tm_1_3', 'Arm Tie');
        final armTie = formValues['3_arm_tie_tm_1_3']?.toString() ?? 'Baik';
        checkAttachmentRequired('armTieFoto', 'Arm Tie', armTie != 'Baik');
      } else {
        for (final f in ['r', 's', 't']) {
          final fasaUpper = f.toUpperCase();
          checkRequired('3_isolator_tarik_tm_5_fasa_$f', 'Isolator Tarik Fasa $fasaUpper');
          final kondisiTarik = formValues['3_isolator_tarik_tm_5_fasa_$f']?.toString() ?? 'Baik';
          checkAttachmentRequired('isolatorTarikFoto$fasaUpper', 'Isolator Tarik Fasa $fasaUpper', kondisiTarik != 'Baik');

          checkRequired('3_sambungan_jumper_tm_5_fasa_$f', 'Sambungan Jumper Fasa $fasaUpper');
          final sambunganJumper = formValues['3_sambungan_jumper_tm_5_fasa_$f']?.toString() ?? 'Tidak Ada';
          checkAttachmentRequired('sambunganJumperFoto$fasaUpper', 'Sambungan Jumper Fasa $fasaUpper', sambunganJumper != 'Tidak Ada');
        }
      }
    } else if (step == 3) {
      // 4. Proteksi & Pembumian
      checkRequired('4_gsw', 'GSW');
      final gsw = formValues['4_gsw']?.toString() ?? 'Tidak Ada';
      checkAttachmentRequired('gswFoto', 'GSW', gsw != 'Tidak Ada');

      if (gsw != 'Tidak Ada') {
        checkRequired('4_kondisi_gsw', 'Kondisi GSW');
        final kondisiGsw = formValues['4_kondisi_gsw']?.toString() ?? 'Baik';
        checkAttachmentRequired('kondisiGswFoto', 'Kondisi GSW', kondisiGsw != 'Baik');
      }

      checkRequired('4_has_arrester', 'Arrester');
      final hasArrester = formValues['4_has_arrester']?.toString() == 'Ada';

      if (hasArrester) {
        bool anyArresterActive = false;
        for (final f in ['r', 's', 't']) {
          final fasaUpper = f.toUpperCase();
          checkRequired('4_jenis_arrester_fasa_$f', 'Jenis Arrester Fasa $fasaUpper');
          final jenisArr = formValues['4_jenis_arrester_fasa_$f']?.toString() ?? 'Tidak Ada';
          if (jenisArr != 'Tidak Ada') {
            anyArresterActive = true;
            checkRequired('4_kondisi_arrester_fasa_$f', 'Kondisi Arrester Fasa $fasaUpper');
            final kondisiArr = formValues['4_kondisi_arrester_fasa_$f']?.toString() ?? 'Baik';
            checkAttachmentRequired('kondisiArresterFoto$fasaUpper', 'Arrester Fasa $fasaUpper', kondisiArr != 'Baik');
          }
        }
        if (anyArresterActive) {
          checkRequired('4_jumper_arrester', 'Jumper Arrester');
          final jumperArr = formValues['4_jumper_arrester']?.toString() ?? 'Tidak Ada';
          checkAttachmentRequired('jumperArresterFoto', 'Jumper Arrester', jumperArr != 'Tidak Ada');
        }
      }

      final showPembumian = gsw != 'Tidak Ada' || hasArrester;
      if (showPembumian) {
        checkRequired('4_kawat_pembumian', 'Kawat Pembumian');
        final ukurKawat = formValues['4_hasil_ukur_kawat_pembumian']?.toString() ?? '';
        if (ukurKawat.trim().isNotEmpty) {
          checkAttachmentRequired('ukurKawatPembumianFoto', 'Hasil Ukur Kawat Pembumian', true);
        }

        checkRequired('4_grounding', 'Grounding');
        final ukurGrounding = formValues['4_hasil_ukur_grounding']?.toString() ?? '';
        if (ukurGrounding.trim().isNotEmpty) {
          checkAttachmentRequired('ukurGroundingFoto', 'Hasil Ukur Grounding', true);
        }
      }
    } else if (step == 4) {
      // 5. Penopang
      checkRequired('5_penopang_jenis', 'Jenis Konstruksi Penopang');
      final penopangJenis = formValues['5_penopang_jenis']?.toString() ?? 'Tidak Ada';
      checkAttachmentRequired('konstruksiPenopangFoto', 'Konstruksi Penopang', penopangJenis != 'Tidak Ada');

      if (penopangJenis != 'Tidak Ada') {
        checkRequired('5_penopang_kondisi', 'Kondisi Penopang');
        final penopangKondisi = formValues['5_penopang_kondisi']?.toString() ?? 'Baik';
        checkAttachmentRequired('kondisiKonstruksiPenopangFoto', 'Kondisi Penopang', penopangKondisi != 'Baik');

        checkRequired('5_kondisi_steel_wire', 'Kondisi Steel Wire');
        final steelWire = formValues['5_kondisi_steel_wire']?.toString() ?? 'Baik';
        checkAttachmentRequired('kondisiSteelWireFoto', 'Steel Wire', steelWire != 'Baik');

        checkRequired('5_pondasi', 'Pondasi');
        final pondasi = formValues['5_pondasi']?.toString() ?? 'Baik';
        checkAttachmentRequired('pondasiFoto', 'Pondasi', pondasi != 'Baik');
      }
    } else if (step == 5) {
      // 6. Hubung
      for (final f in ['r', 's', 't']) {
        final fasaUpper = f.toUpperCase();
        checkRequired('6_fco_fasa_$f', 'FCO Fasa $fasaUpper');
        final fco = formValues['6_fco_fasa_$f']?.toString() ?? 'Tidak Ada';
        checkAttachmentRequired('fcoFoto$fasaUpper', 'FCO Fasa $fasaUpper', fco != 'Tidak Ada');
      }

      checkRequired('6_sambungan_fco', 'Sambungan FCO');
      final sambunganFco = formValues['6_sambungan_fco']?.toString() ?? 'Tidak Ada';
      checkAttachmentRequired('sambunganFCOFoto', 'Sambungan FCO', sambunganFco != 'Tidak Ada');

      checkRequired('6_lbs_konvensional', 'LBS Konvensional');
      final lbsKonv = formValues['6_lbs_konvensional']?.toString() ?? 'Tidak Ada';
      checkAttachmentRequired('lbsKonvensionalFoto', 'LBS Konvensional', lbsKonv != 'Tidak Ada');

      checkRequired('6_lbs_remote_motorized', 'LBS Remote Motorized');
      final lbsRemote = formValues['6_lbs_remote_motorized']?.toString() ?? 'Tidak Ada';
      checkAttachmentRequired('lbsRemoteFoto', 'LBS Remote', lbsRemote != 'Tidak Ada');

      checkRequired('6_recloser', 'Recloser');
      final recloser = formValues['6_recloser']?.toString() ?? 'Tidak Ada';
      checkAttachmentRequired('recloserFoto', 'Recloser', recloser != 'Tidak Ada');
    }

    if (_validationErrors.isNotEmpty) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi field wajib yang bertanda * merah.'),
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    return true;
  }

  // Dialog Reject for Koordinator
  void _showRejectDialog() {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Alasan Penolakan', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Masukkan alasan penolakan...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Alasan penolakan wajib diisi'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.of(ctx).pop();
                context.read<InspeksiFormCubit>().rejectInspection(
                      role: 'koordinator',
                      inspectionId: int.tryParse(_inspectionId) ?? 0,
                      reason: reason,
                    );
              },
              child: const Text('Tolak'),
            ),
          ],
        );
      },
    );
  }

  // Dialog Approve for Koordinator
  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Validasi', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda yakin ingin menyetujui hasil inspeksi SUTM ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<InspeksiFormCubit>().approveInspection(
                      role: 'koordinator',
                      inspectionId: int.tryParse(_inspectionId) ?? 0,
                    );
              },
              child: const Text('Setujui'),
            ),
          ],
        );
      },
    );
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
          title: Text(_isValidateMode ? 'Validasi: $_idAsset' : _idAsset),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            if (!_isViewMode)
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
                    : <String, dynamic>{};
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
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _isValidateMode ? Colors.orange : Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isValidateMode
                                  ? 'Mode Validasi'
                                  : (_isViewMode ? 'Riwayat' : 'Auto-Draft Aktif'),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step Indicator Tabs (1 to 7)
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
                      child: _isValidateMode
                          ? Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.error,
                                      side: const BorderSide(color: AppColors.error),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: _showRejectDialog,
                                    child: const Text('Tolak / Reject', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: _showApproveDialog,
                                    child: const Text('Validasi / Setujui', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            )
                          : Row(
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
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    onPressed: () {
                                      if (_validateStep(activeStep, formValues, attachments)) {
                                        if (activeStep < 6) {
                                          context.read<InspeksiFormCubit>().setStep(
                                                activeStep + 1,
                                                _workOrderSutmItemId,
                                              );
                                        } else {
                                          _showConfirmSubmitDialog(formValues, attachments);
                                        }
                                      }
                                    },
                                    child: Text(
                                      activeStep == 6 ? 'Kirim Inspeksi' : 'Selanjutnya',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
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

  void _showConfirmSubmitDialog(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Kirim Formulir Inspeksi', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Pastikan seluruh data dan foto yang diisi sudah sesuai. Kirim data inspeksi sekarang?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Periksa Kembali'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.read<InspeksiFormCubit>().submitForm(
                      workOrderSutmItemId: int.tryParse(_workOrderSutmItemId),
                      sutmId: int.tryParse(_sutmId),
                      latitude: _latitude,
                      longitude: _longitude,
                      startTime: _startTime,
                    );
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
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

  Widget _buildFieldLabel(String label, {bool isRequired = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                children: [
                  if (isRequired)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (hint != null)
            Text(
              hint,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String fieldKey,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    bool isRequired = true,
  }) {
    final error = _validationErrors[fieldKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _isReadOnly ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: error != null ? AppColors.error : Colors.grey.shade300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: options.contains(value) ? value : null,
              hint: Text('Pilih $label', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              items: options.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt, style: const TextStyle(fontSize: 13)),
                );
              }).toList(),
              onChanged: _isReadOnly ? null : onChanged,
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(error, style: const TextStyle(color: AppColors.error, fontSize: 11)),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String fieldKey,
    required String? value,
    required ValueChanged<String> onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? hint,
    bool isRequired = false,
  }) {
    final error = _validationErrors[fieldKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        TextField(
          controller: TextEditingController(text: value ?? '')..selection = TextSelection.collapsed(offset: (value ?? '').length),
          readOnly: _isReadOnly,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint ?? 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: _isReadOnly,
            fillColor: _isReadOnly ? Colors.grey.shade100 : Colors.white,
            errorText: error,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: error != null ? AppColors.error : Colors.grey.shade300),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1.5)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPhotoField({
    required String label,
    required String attachmentKey,
    required dynamic fileOrUrl,
    required VoidCallback onTap,
    bool isRequired = false,
  }) {
    final hasPhoto = fileOrUrl != null;
    final error = _validationErrors[attachmentKey];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        if (!hasPhoto)
          InkWell(
            onTap: _isReadOnly ? null : onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: error != null ? AppColors.error : Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 28,
                      color: error != null ? AppColors.error : AppColors.primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isReadOnly ? 'Tidak ada foto' : 'Ambil Foto $label',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: error != null ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                // Thumbnail with click to preview
                GestureDetector(
                  onTap: () => _showPhotoPreview(fileOrUrl, label, attachmentKey: attachmentKey),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: fileOrUrl is File
                          ? Image.file(fileOrUrl, fit: BoxFit.cover)
                          : Image.network(
                              fileOrUrl.toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Foto Tersedia',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: const Size(0, 32),
                              side: const BorderSide(color: AppColors.primary),
                            ),
                            icon: const Icon(Icons.visibility_outlined, size: 14),
                            label: const Text('Lihat Foto', style: TextStyle(fontSize: 11)),
                            onPressed: () => _showPhotoPreview(fileOrUrl, label, attachmentKey: attachmentKey),
                          ),
                          if (!_isReadOnly)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: const Size(0, 32),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text('Ambil Ulang', style: TextStyle(fontSize: 11)),
                              onPressed: onTap,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(error, style: const TextStyle(color: AppColors.error, fontSize: 11)),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. STEP TIANG
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepTiang(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    final kondisiTiang = formValues['1_kondisi_tiang']?.toString() ?? '';
    final isKondisiTiangBaik = kondisiTiang.contains('Baik');
    final isKondisiTiangPhotoRequired = !isKondisiTiangBaik && kondisiTiang.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Tiang',
          fieldKey: '1_jenis_tiang',
          value: formValues['1_jenis_tiang'] as String?,
          options: SutmFormConstants.jenisTiangOptions,
          onChanged: (val) => context.read<InspeksiFormCubit>().updateField('1_jenis_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Tinggi Tiang',
          fieldKey: '1_tinggi_tiang',
          value: formValues['1_tinggi_tiang'] as String?,
          options: SutmFormConstants.tinggiTiangOptions,
          onChanged: (val) => context.read<InspeksiFormCubit>().updateField('1_tinggi_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 14),

        // Multi-Select Kondisi Tiang
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel('Kondisi Tiang', isRequired: true),
            InkWell(
              onTap: _isReadOnly
                  ? null
                  : () => _showMultiSelectKondisiTiang(
                        context,
                        formValues['1_kondisi_tiang'] as String?,
                        (selected) {
                          context.read<InspeksiFormCubit>().updateField('1_kondisi_tiang', selected, _workOrderSutmItemId);
                        },
                      ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: _isReadOnly ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _validationErrors['1_kondisi_tiang'] != null ? AppColors.error : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        kondisiTiang.isNotEmpty ? kondisiTiang : 'Pilih Kondisi Tiang',
                        style: TextStyle(
                          fontSize: 13,
                          color: kondisiTiang.isNotEmpty ? Colors.black87 : Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            if (_validationErrors['1_kondisi_tiang'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 4),
                child: Text(
                  _validationErrors['1_kondisi_tiang']!,
                  style: const TextStyle(color: AppColors.error, fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),

        // Foto Kondisi Tiang (Muncul dan wajib jika kondisi bukan Baik)
        _buildPhotoField(
          label: 'Foto Kondisi Tiang',
          attachmentKey: 'kondisiTiangFoto',
          fileOrUrl: attachments['kondisiTiangFoto'],
          isRequired: isKondisiTiangPhotoRequired,
          onTap: () => _openCamera('kondisiTiangFoto'),
        ),
        const SizedBox(height: 14),

        _buildDropdown(
          label: 'Identitas Tiang',
          fieldKey: '1_identitas_tiang',
          value: formValues['1_identitas_tiang'] as String?,
          options: SutmFormConstants.identitasTiangOptions,
          onChanged: (val) => context.read<InspeksiFormCubit>().updateField('1_identitas_tiang', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Jenis Konstruksi',
          fieldKey: '1_jenis_konstruksi',
          value: formValues['1_jenis_konstruksi'] as String?,
          options: SutmFormConstants.jenisKonstruksiOptions,
          onChanged: (val) => context.read<InspeksiFormCubit>().updateField('1_jenis_konstruksi', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 14),
        _buildPhotoField(
          label: 'Foto Konstruksi Tiang',
          attachmentKey: 'jenisKonstruksiFoto',
          fileOrUrl: attachments['jenisKonstruksiFoto'],
          isRequired: true,
          onTap: () => _openCamera('jenisKonstruksiFoto'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. STEP PENGHANTAR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepPenghantar(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Konduktor',
          fieldKey: '2_jenis_konduktor',
          value: formValues['2_jenis_konduktor'] as String?,
          options: SutmFormConstants.jenisKonduktorOptions,
          onChanged: (val) => context.read<InspeksiFormCubit>().updateField('2_jenis_konduktor', val, _workOrderSutmItemId),
        ),
        const SizedBox(height: 14),
        _buildPhotoField(
          label: 'Foto Jenis Konduktor',
          attachmentKey: 'jenisKonduktorFoto',
          fileOrUrl: attachments['jenisKonduktorFoto'],
          isRequired: true,
          onTap: () => _openCamera('jenisKonduktorFoto'),
        ),
        const SizedBox(height: 14),
        _buildDropdown(
          label: 'Ukuran Konduktor',
          fieldKey: '2_ukuran_konduktor',
          value: formValues['2_ukuran_konduktor'] as String?,
          options: SutmFormConstants.ukuranKonduktorOptions,
          onChanged: (val) => context.read<InspeksiFormCubit>().updateField('2_ukuran_konduktor', val, _workOrderSutmItemId),
        ),

        // Konduktor Per Fasa
        _buildSectionHeader('Konduktor Per Fasa'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final fieldKey = '2_konduktor_fasa_$fasaLower';
          final attachmentKey = 'konduktorFoto$fasa';
          final val = formValues[fieldKey] as String?;
          final isPhotoReq = val != null && val != 'Baik';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Konduktor Fasa $fasa',
                  fieldKey: fieldKey,
                  value: val,
                  options: SutmFormConstants.kondisiKonduktorOptions,
                  onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                ),
                const SizedBox(height: 8),
                _buildPhotoField(
                  label: 'Foto Konduktor Fasa $fasa',
                  attachmentKey: attachmentKey,
                  fileOrUrl: attachments[attachmentKey],
                  isRequired: isPhotoReq,
                  onTap: () => _openCamera(attachmentKey),
                ),
              ],
            ),
          );
        }),

        // Sambungan Konduktor
        _buildSectionHeader('Sambungan Konduktor'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final fieldKey = '2_sambungan_fasa_$fasaLower';
          final attachmentKey = 'sambunganFoto$fasa';
          final val = formValues[fieldKey] as String?;
          final isPhotoReq = val != null && val != 'Tidak Ada';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Sambungan Fasa $fasa',
                  fieldKey: fieldKey,
                  value: val,
                  options: SutmFormConstants.sambunganKonduktorOptions,
                  onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                ),
                const SizedBox(height: 8),
                _buildPhotoField(
                  label: 'Foto Sambungan Fasa $fasa',
                  attachmentKey: attachmentKey,
                  fileOrUrl: attachments[attachmentKey],
                  isRequired: isPhotoReq,
                  onTap: () => _openCamera(attachmentKey),
                ),
              ],
            ),
          );
        }),

        // Thermal Sambungan Konduktor (Opsional)
        _buildSectionHeader('Thermal Sambungan Konduktor (Opsional)'),
        _buildTextField(
          label: 'Suhu Lingkungan (°C)',
          fieldKey: '2_thermal_sambungan_min',
          value: formValues['2_thermal_sambungan_min'] as String?,
          keyboardType: TextInputType.number,
          hint: 'Contoh: 30',
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('2_thermal_sambungan_min', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 10),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final key = '2_thermal_sambungan_fasa_${fasaLower}_max';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildTextField(
              label: 'Suhu Maks Fasa $fasa (°C)',
              fieldKey: key,
              value: formValues[key] as String?,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 45',
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField(key, v, _workOrderSutmItemId),
            ),
          );
        }),

        // Partial Discharge Sambungan (Opsional)
        _buildSectionHeader('Partial Discharge Sambungan (Opsional)'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final key = '2_pd_sambungan_fasa_$fasaLower';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildDropdown(
              label: 'PD Sambungan Fasa $fasa',
              fieldKey: key,
              value: formValues[key] as String?,
              options: SutmFormConstants.pdOptions,
              isRequired: false,
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField(key, v, _workOrderSutmItemId),
            ),
          );
        }),

        // Terminasi
        _buildSectionHeader('Terminasi'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final fieldKey = '2_terminasi_fasa_$fasaLower';
          final attachmentKey = 'terminasiFoto$fasa';
          final val = formValues[fieldKey] as String?;
          final isPhotoReq = val != null && val != 'Tidak Ada';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Terminasi Fasa $fasa',
                  fieldKey: fieldKey,
                  value: val,
                  options: SutmFormConstants.terminasiOptions,
                  onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                ),
                const SizedBox(height: 8),
                _buildPhotoField(
                  label: 'Foto Terminasi Fasa $fasa',
                  attachmentKey: attachmentKey,
                  fileOrUrl: attachments[attachmentKey],
                  isRequired: isPhotoReq,
                  onTap: () => _openCamera(attachmentKey),
                ),
              ],
            ),
          );
        }),

        // Thermal & PD Terminasi (Opsional)
        _buildSectionHeader('Thermal & PD Terminasi (Opsional)'),
        _buildTextField(
          label: 'Suhu Lingkungan (°C)',
          fieldKey: '2_thermal_terminasi_min',
          value: formValues['2_thermal_terminasi_min'] as String?,
          keyboardType: TextInputType.number,
          hint: 'Contoh: 30',
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('2_thermal_terminasi_min', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 10),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final key = '2_thermal_terminasi_fasa_${fasaLower}_max';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildTextField(
              label: 'Suhu Maks Fasa $fasa (°C)',
              fieldKey: key,
              value: formValues[key] as String?,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 45',
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField(key, v, _workOrderSutmItemId),
            ),
          );
        }),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final key = '2_pd_terminasi_fasa_$fasaLower';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildDropdown(
              label: 'PD Terminasi Fasa $fasa',
              fieldKey: key,
              value: formValues[key] as String?,
              options: SutmFormConstants.pdOptions,
              isRequired: false,
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField(key, v, _workOrderSutmItemId),
            ),
          );
        }),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. STEP ISOLATOR
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepIsolator(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    final jenisKonstruksi = formValues['1_jenis_konstruksi']?.toString();
    if (jenisKonstruksi == null || jenisKonstruksi.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          children: [
            const Icon(Icons.info_outline, size: 40, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              'Silakan pilih Jenis Konstruksi di Sub Tiang terlebih dahulu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    final useTm13 = jenisKonstruksi == 'TM 1' || jenisKonstruksi == 'TM 3';
    final suffix = useTm13 ? 'tm_1_3' : 'tm_5';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Jenis Isolator
        _buildDropdown(
          label: 'Jenis Isolator',
          fieldKey: '3_jenis_isolator_$suffix',
          value: formValues['3_jenis_isolator_$suffix'] as String?,
          options: useTm13
              ? SutmFormConstants.jenisIsolatorTm13Options
              : SutmFormConstants.jenisIsolatorTm5Options,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('3_jenis_isolator_$suffix', v, _workOrderSutmItemId),
        ),

        // Isolator Tumpu Per Fasa
        _buildSectionHeader('Isolator Tumpu'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final fieldKey = '3_isolator_tumpu_${suffix}_fasa_$fasaLower';
          final jumlahTemuanKey = '3_isolator_tumpu_${suffix}_fasa_${fasaLower}_jumlah_temuan';
          final attachmentKey = 'isolatorTumpuFoto$fasa';
          final val = formValues[fieldKey] as String?;
          final isPhotoReq = val != null && val != 'Baik';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Isolator Tumpu Fasa $fasa',
                  fieldKey: fieldKey,
                  value: val,
                  options: SutmFormConstants.kondisiIsolatorOptions,
                  onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                ),
                if (jenisKonstruksi == 'TM 3') ...[
                  const SizedBox(height: 8),
                  _buildTextField(
                    label: 'Jumlah Temuan Fasa $fasa',
                    fieldKey: jumlahTemuanKey,
                    value: formValues[jumlahTemuanKey] as String?,
                    keyboardType: TextInputType.number,
                    hint: 'Contoh: 1',
                    onChanged: (v) => context.read<InspeksiFormCubit>().updateField(jumlahTemuanKey, v, _workOrderSutmItemId),
                  ),
                ],
                const SizedBox(height: 8),
                _buildPhotoField(
                  label: 'Foto Isolator Tumpu Fasa $fasa',
                  attachmentKey: attachmentKey,
                  fileOrUrl: attachments[attachmentKey],
                  isRequired: isPhotoReq,
                  onTap: () => _openCamera(attachmentKey),
                ),
              ],
            ),
          );
        }),

        // PD Isolator Tumpu
        _buildSectionHeader('PD Isolator Tumpu (Opsional)'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final key = '3_pd_isolator_tumpu_${suffix}_fasa_$fasaLower';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildDropdown(
              label: 'PD Isolator Tumpu Fasa $fasa',
              fieldKey: key,
              value: formValues[key] as String?,
              options: SutmFormConstants.pdOptions,
              isRequired: false,
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField(key, v, _workOrderSutmItemId),
            ),
          );
        }),

        // Top Ties
        _buildSectionHeader('Top Ties'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final fieldKey = '3_top_ties_${suffix}_fasa_$fasaLower';
          final jumlahTemuanKey = '3_top_ties_${suffix}_fasa_${fasaLower}_jumlah_temuan';
          final attachmentKey = 'topTiesFoto$fasa';
          final val = formValues[fieldKey] as String?;
          final isPhotoReq = val != null && val != 'Baik';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'Top Ties Fasa $fasa',
                  fieldKey: fieldKey,
                  value: val,
                  options: SutmFormConstants.kondisiTopTiesOptions,
                  onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                ),
                if (val != null && val != 'Baik') ...[
                  const SizedBox(height: 8),
                  _buildTextField(
                    label: 'Jumlah Temuan Top Ties Fasa $fasa',
                    fieldKey: jumlahTemuanKey,
                    value: formValues[jumlahTemuanKey] as String?,
                    keyboardType: TextInputType.number,
                    hint: 'Contoh: 1',
                    onChanged: (v) => context.read<InspeksiFormCubit>().updateField(jumlahTemuanKey, v, _workOrderSutmItemId),
                  ),
                ],
                const SizedBox(height: 8),
                _buildPhotoField(
                  label: 'Foto Top Ties Fasa $fasa',
                  attachmentKey: attachmentKey,
                  fileOrUrl: attachments[attachmentKey],
                  isRequired: isPhotoReq,
                  onTap: () => _openCamera(attachmentKey),
                ),
              ],
            ),
          );
        }),

        // Cross Arm
        _buildSectionHeader('Cross Arm / Travers'),
        _buildDropdown(
          label: 'Kondisi Cross Arm',
          fieldKey: '3_cross_arm_$suffix',
          value: formValues['3_cross_arm_$suffix'] as String?,
          options: SutmFormConstants.kondisiCrossArmOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('3_cross_arm_$suffix', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto Cross Arm',
          attachmentKey: 'crossArmFoto',
          fileOrUrl: attachments['crossArmFoto'],
          isRequired: formValues['3_cross_arm_$suffix'] != null && formValues['3_cross_arm_$suffix'] != 'Baik',
          onTap: () => _openCamera('crossArmFoto'),
        ),

        // Arm Tie (Khusus TM 1 / TM 3)
        if (useTm13) ...[
          _buildSectionHeader('Arm Tie'),
          _buildDropdown(
            label: 'Kondisi Arm Tie',
            fieldKey: '3_arm_tie_tm_1_3',
            value: formValues['3_arm_tie_tm_1_3'] as String?,
            options: SutmFormConstants.kondisiArmTieOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('3_arm_tie_tm_1_3', v, _workOrderSutmItemId),
          ),
          const SizedBox(height: 8),
          _buildPhotoField(
            label: 'Foto Arm Tie',
            attachmentKey: 'armTieFoto',
            fileOrUrl: attachments['armTieFoto'],
            isRequired: formValues['3_arm_tie_tm_1_3'] != null && formValues['3_arm_tie_tm_1_3'] != 'Baik',
            onTap: () => _openCamera('armTieFoto'),
          ),
        ] else ...[
          // Isolator Tarik & Sambungan Jumper (Khusus TM 5 / dsb)
          _buildSectionHeader('Isolator Tarik'),
          ...SutmFormConstants.fasaList.map((fasa) {
            final fasaLower = fasa.toLowerCase();
            final fieldKey = '3_isolator_tarik_tm_5_fasa_$fasaLower';
            final attachmentKey = 'isolatorTarikFoto$fasa';
            final val = formValues[fieldKey] as String?;
            final isPhotoReq = val != null && val != 'Baik';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: 'Isolator Tarik Fasa $fasa',
                    fieldKey: fieldKey,
                    value: val,
                    options: SutmFormConstants.kondisiIsolatorOptions,
                    onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                  ),
                  const SizedBox(height: 8),
                  _buildPhotoField(
                    label: 'Foto Isolator Tarik Fasa $fasa',
                    attachmentKey: attachmentKey,
                    fileOrUrl: attachments[attachmentKey],
                    isRequired: isPhotoReq,
                    onTap: () => _openCamera(attachmentKey),
                  ),
                ],
              ),
            );
          }),

          _buildSectionHeader('Sambungan Jumper'),
          ...SutmFormConstants.fasaList.map((fasa) {
            final fasaLower = fasa.toLowerCase();
            final fieldKey = '3_sambungan_jumper_tm_5_fasa_$fasaLower';
            final attachmentKey = 'sambunganJumperFoto$fasa';
            final val = formValues[fieldKey] as String?;
            final isPhotoReq = val != null && val != 'Tidak Ada';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: 'Sambungan Jumper Fasa $fasa',
                    fieldKey: fieldKey,
                    value: val,
                    options: SutmFormConstants.sambunganJumperOptions,
                    onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                  ),
                  const SizedBox(height: 8),
                  _buildPhotoField(
                    label: 'Foto Sambungan Jumper Fasa $fasa',
                    attachmentKey: attachmentKey,
                    fileOrUrl: attachments[attachmentKey],
                    isRequired: isPhotoReq,
                    onTap: () => _openCamera(attachmentKey),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. STEP PROTEKSI & PEMBUMIAN
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepProteksi(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    final gswVal = formValues['4_gsw']?.toString() ?? 'Tidak Ada';
    final hasGsw = gswVal != 'Tidak Ada';

    final hasArresterVal = formValues['4_has_arrester']?.toString() ?? 'Tidak Ada';
    final hasArrester = hasArresterVal == 'Ada';

    final showPembumianGrounding = hasGsw || hasArrester;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Letak GSW',
          fieldKey: '4_gsw',
          value: formValues['4_gsw'] as String?,
          options: SutmFormConstants.gswLetakOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_gsw', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto GSW',
          attachmentKey: 'gswFoto',
          fileOrUrl: attachments['gswFoto'],
          isRequired: hasGsw,
          onTap: () => _openCamera('gswFoto'),
        ),

        if (hasGsw) ...[
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Kondisi GSW',
            fieldKey: '4_kondisi_gsw',
            value: formValues['4_kondisi_gsw'] as String?,
            options: SutmFormConstants.kondisiGswOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_kondisi_gsw', v, _workOrderSutmItemId),
          ),
          const SizedBox(height: 8),
          _buildPhotoField(
            label: 'Foto Kondisi GSW',
            attachmentKey: 'kondisiGswFoto',
            fileOrUrl: attachments['kondisiGswFoto'],
            isRequired: formValues['4_kondisi_gsw'] != null && formValues['4_kondisi_gsw'] != 'Baik',
            onTap: () => _openCamera('kondisiGswFoto'),
          ),
        ],

        _buildSectionHeader('Arrester'),
        _buildDropdown(
          label: 'Keberadaan Arrester',
          fieldKey: '4_has_arrester',
          value: formValues['4_has_arrester'] as String?,
          options: SutmFormConstants.arresterOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_has_arrester', v, _workOrderSutmItemId),
        ),

        if (hasArrester) ...[
          const SizedBox(height: 14),
          ...SutmFormConstants.fasaList.map((fasa) {
            final fasaLower = fasa.toLowerCase();
            final jenisKey = '4_jenis_arrester_fasa_$fasaLower';
            final kondisiKey = '4_kondisi_arrester_fasa_$fasaLower';
            final attachmentKey = 'kondisiArresterFoto$fasa';
            final jenisVal = formValues[jenisKey] as String?;
            final kondisiVal = formValues[kondisiKey] as String?;
            final isJenisActive = jenisVal != null && jenisVal != 'Tidak Ada';

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdown(
                    label: 'Jenis Arrester Fasa $fasa',
                    fieldKey: jenisKey,
                    value: jenisVal,
                    options: SutmFormConstants.jenisArresterOptions,
                    onChanged: (v) => context.read<InspeksiFormCubit>().updateField(jenisKey, v, _workOrderSutmItemId),
                  ),
                  if (isJenisActive) ...[
                    const SizedBox(height: 8),
                    _buildDropdown(
                      label: 'Kondisi Arrester Fasa $fasa',
                      fieldKey: kondisiKey,
                      value: kondisiVal,
                      options: SutmFormConstants.kondisiArresterOptions,
                      onChanged: (v) => context.read<InspeksiFormCubit>().updateField(kondisiKey, v, _workOrderSutmItemId),
                    ),
                    const SizedBox(height: 8),
                    _buildPhotoField(
                      label: 'Foto Arrester Fasa $fasa',
                      attachmentKey: attachmentKey,
                      fileOrUrl: attachments[attachmentKey],
                      isRequired: kondisiVal != null && kondisiVal != 'Baik',
                      onTap: () => _openCamera(attachmentKey),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Jumper Arrester
          _buildDropdown(
            label: 'Jumper Arrester',
            fieldKey: '4_jumper_arrester',
            value: formValues['4_jumper_arrester'] as String?,
            options: SutmFormConstants.jumperArresterOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_jumper_arrester', v, _workOrderSutmItemId),
          ),
          const SizedBox(height: 8),
          _buildPhotoField(
            label: 'Foto Jumper Arrester',
            attachmentKey: 'jumperArresterFoto',
            fileOrUrl: attachments['jumperArresterFoto'],
            isRequired: formValues['4_jumper_arrester'] != null && formValues['4_jumper_arrester'] != 'Tidak Ada',
            onTap: () => _openCamera('jumperArresterFoto'),
          ),
        ],

        // Pembumian & Grounding
        if (showPembumianGrounding) ...[
          _buildSectionHeader('Pembumian & Grounding'),
          _buildDropdown(
            label: 'Kawat Pembumian',
            fieldKey: '4_kawat_pembumian',
            value: formValues['4_kawat_pembumian'] as String?,
            options: SutmFormConstants.kawatPembumianOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_kawat_pembumian', v, _workOrderSutmItemId),
          ),
          if (formValues['4_kawat_pembumian'] != null && formValues['4_kawat_pembumian'] != 'Tidak Ada') ...[
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Hasil Ukur Kawat Pembumian (Ω)',
              fieldKey: '4_hasil_ukur_kawat_pembumian',
              value: formValues['4_hasil_ukur_kawat_pembumian'] as String?,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 1.5',
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_hasil_ukur_kawat_pembumian', v, _workOrderSutmItemId),
            ),
            const SizedBox(height: 8),
            _buildPhotoField(
              label: 'Foto Hasil Ukur Kawat Pembumian',
              attachmentKey: 'ukurKawatPembumianFoto',
              fileOrUrl: attachments['ukurKawatPembumianFoto'],
              isRequired: (formValues['4_hasil_ukur_kawat_pembumian'] as String?)?.isNotEmpty ?? false,
              onTap: () => _openCamera('ukurKawatPembumianFoto'),
            ),
          ],
          const SizedBox(height: 14),

          _buildDropdown(
            label: 'Grounding',
            fieldKey: '4_grounding',
            value: formValues['4_grounding'] as String?,
            options: SutmFormConstants.groundingOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_grounding', v, _workOrderSutmItemId),
          ),
          if (formValues['4_grounding'] != null && formValues['4_grounding'] != 'Tidak Ada') ...[
            const SizedBox(height: 8),
            _buildTextField(
              label: 'Hasil Ukur Grounding (Ω)',
              fieldKey: '4_hasil_ukur_grounding',
              value: formValues['4_hasil_ukur_grounding'] as String?,
              keyboardType: TextInputType.number,
              hint: 'Contoh: 0.8',
              onChanged: (v) => context.read<InspeksiFormCubit>().updateField('4_hasil_ukur_grounding', v, _workOrderSutmItemId),
            ),
            const SizedBox(height: 8),
            _buildPhotoField(
              label: 'Foto Hasil Ukur Grounding',
              attachmentKey: 'ukurGroundingFoto',
              fileOrUrl: attachments['ukurGroundingFoto'],
              isRequired: (formValues['4_hasil_ukur_grounding'] as String?)?.isNotEmpty ?? false,
              onTap: () => _openCamera('ukurGroundingFoto'),
            ),
          ],
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 5. STEP KONSTRUKSI PENOPANG
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepPenopang(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    final jenisPenopang = formValues['5_penopang_jenis']?.toString() ?? 'Tidak Ada';
    final hasPenopang = jenisPenopang != 'Tidak Ada';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdown(
          label: 'Jenis Konstruksi Penopang',
          fieldKey: '5_penopang_jenis',
          value: formValues['5_penopang_jenis'] as String?,
          options: SutmFormConstants.penopangJenisOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('5_penopang_jenis', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto Konstruksi Penopang',
          attachmentKey: 'konstruksiPenopangFoto',
          fileOrUrl: attachments['konstruksiPenopangFoto'],
          isRequired: hasPenopang,
          onTap: () => _openCamera('konstruksiPenopangFoto'),
        ),

        if (hasPenopang) ...[
          const SizedBox(height: 14),
          _buildDropdown(
            label: 'Kondisi Konstruksi Penopang',
            fieldKey: '5_penopang_kondisi',
            value: formValues['5_penopang_kondisi'] as String?,
            options: SutmFormConstants.penopangKondisiOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('5_penopang_kondisi', v, _workOrderSutmItemId),
          ),
          const SizedBox(height: 8),
          _buildPhotoField(
            label: 'Foto Kondisi Penopang',
            attachmentKey: 'kondisiKonstruksiPenopangFoto',
            fileOrUrl: attachments['kondisiKonstruksiPenopangFoto'],
            isRequired: formValues['5_penopang_kondisi'] != null && formValues['5_penopang_kondisi'] != 'Baik',
            onTap: () => _openCamera('kondisiKonstruksiPenopangFoto'),
          ),
          const SizedBox(height: 14),

          _buildDropdown(
            label: 'Kondisi Steel Wire',
            fieldKey: '5_kondisi_steel_wire',
            value: formValues['5_kondisi_steel_wire'] as String?,
            options: SutmFormConstants.kondisiSteelWireOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('5_kondisi_steel_wire', v, _workOrderSutmItemId),
          ),
          const SizedBox(height: 8),
          _buildPhotoField(
            label: 'Foto Kondisi Steel Wire',
            attachmentKey: 'kondisiSteelWireFoto',
            fileOrUrl: attachments['kondisiSteelWireFoto'],
            isRequired: formValues['5_kondisi_steel_wire'] != null && formValues['5_kondisi_steel_wire'] != 'Baik',
            onTap: () => _openCamera('kondisiSteelWireFoto'),
          ),
          const SizedBox(height: 14),

          _buildDropdown(
            label: 'Kondisi Pondasi',
            fieldKey: '5_pondasi',
            value: formValues['5_pondasi'] as String?,
            options: SutmFormConstants.pondasiOptions,
            onChanged: (v) => context.read<InspeksiFormCubit>().updateField('5_pondasi', v, _workOrderSutmItemId),
          ),
          const SizedBox(height: 8),
          _buildPhotoField(
            label: 'Foto Pondasi',
            attachmentKey: 'pondasiFoto',
            fileOrUrl: attachments['pondasiFoto'],
            isRequired: formValues['5_pondasi'] != null && formValues['5_pondasi'] != 'Baik',
            onTap: () => _openCamera('pondasiFoto'),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 6. STEP PERALATAN HUBUNG
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepHubung(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('FCO (Fuse Cut Out)'),
        ...SutmFormConstants.fasaList.map((fasa) {
          final fasaLower = fasa.toLowerCase();
          final fieldKey = '6_fco_fasa_$fasaLower';
          final attachmentKey = 'fcoFoto$fasa';
          final val = formValues[fieldKey] as String?;
          final isPhotoReq = val != null && val != 'Tidak Ada';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdown(
                  label: 'FCO Fasa $fasa',
                  fieldKey: fieldKey,
                  value: val,
                  options: SutmFormConstants.fcoOptions,
                  onChanged: (v) => context.read<InspeksiFormCubit>().updateField(fieldKey, v, _workOrderSutmItemId),
                ),
                const SizedBox(height: 8),
                _buildPhotoField(
                  label: 'Foto FCO Fasa $fasa',
                  attachmentKey: attachmentKey,
                  fileOrUrl: attachments[attachmentKey],
                  isRequired: isPhotoReq,
                  onTap: () => _openCamera(attachmentKey),
                ),
              ],
            ),
          );
        }),

        _buildSectionHeader('Sambungan FCO'),
        _buildDropdown(
          label: 'Sambungan FCO',
          fieldKey: '6_sambungan_fco',
          value: formValues['6_sambungan_fco'] as String?,
          options: SutmFormConstants.sambunganFcoOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('6_sambungan_fco', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto Sambungan FCO',
          attachmentKey: 'sambunganFCOFoto',
          fileOrUrl: attachments['sambunganFCOFoto'],
          isRequired: formValues['6_sambungan_fco'] != null && formValues['6_sambungan_fco'] != 'Tidak Ada',
          onTap: () => _openCamera('sambunganFCOFoto'),
        ),

        _buildSectionHeader('Switching Lainnya'),
        _buildDropdown(
          label: 'LBS Konvensional',
          fieldKey: '6_lbs_konvensional',
          value: formValues['6_lbs_konvensional'] as String?,
          options: SutmFormConstants.lbsKonvensionalOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('6_lbs_konvensional', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto LBS Konvensional',
          attachmentKey: 'lbsKonvensionalFoto',
          fileOrUrl: attachments['lbsKonvensionalFoto'],
          isRequired: formValues['6_lbs_konvensional'] != null && formValues['6_lbs_konvensional'] != 'Tidak Ada',
          onTap: () => _openCamera('lbsKonvensionalFoto'),
        ),
        const SizedBox(height: 14),

        _buildDropdown(
          label: 'LBS Remote Motorized',
          fieldKey: '6_lbs_remote_motorized',
          value: formValues['6_lbs_remote_motorized'] as String?,
          options: SutmFormConstants.lbsRemoteOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('6_lbs_remote_motorized', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto LBS Remote Motorized',
          attachmentKey: 'lbsRemoteFoto',
          fileOrUrl: attachments['lbsRemoteFoto'],
          isRequired: formValues['6_lbs_remote_motorized'] != null && formValues['6_lbs_remote_motorized'] != 'Tidak Ada',
          onTap: () => _openCamera('lbsRemoteFoto'),
        ),
        const SizedBox(height: 14),

        _buildDropdown(
          label: 'Recloser',
          fieldKey: '6_recloser',
          value: formValues['6_recloser'] as String?,
          options: SutmFormConstants.recloserOptions,
          onChanged: (v) => context.read<InspeksiFormCubit>().updateField('6_recloser', v, _workOrderSutmItemId),
        ),
        const SizedBox(height: 8),
        _buildPhotoField(
          label: 'Foto Recloser',
          attachmentKey: 'recloserFoto',
          fileOrUrl: attachments['recloserFoto'],
          isRequired: formValues['6_recloser'] != null && formValues['6_recloser'] != 'Tidak Ada',
          onTap: () => _openCamera('recloserFoto'),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 7. STEP ROW & LINGKUNGAN
  // ═══════════════════════════════════════════════════════════════
  Widget _buildStepRow(
    Map<String, dynamic> formValues,
    Map<String, dynamic> attachments,
  ) {
    final rows = (formValues['7_rows'] as List<dynamic>?) ?? [];

    void addRow() {
      final newRows = List<Map<String, dynamic>>.from(rows.map((r) => Map<String, dynamic>.from(r as Map)));
      final newRow = {
        'idEntitas': '${_idAsset}_ROW_${DateTime.now().millisecondsSinceEpoch}',
        'jenisEntitas': SutmFormConstants.jenisEntitasOptions.first,
        'jarak': SutmFormConstants.jarakOptions.first,
        'fasa': SutmFormConstants.fasaRowOptions.first,
        'latitude': _latitude,
        'longitude': _longitude,
      };
      newRows.add(newRow);
      context.read<InspeksiFormCubit>().updateField('7_rows', newRows, _workOrderSutmItemId);
    }

    void removeRow(int index) {
      final newRows = List<Map<String, dynamic>>.from(rows.map((r) => Map<String, dynamic>.from(r as Map)));
      newRows.removeAt(index);
      context.read<InspeksiFormCubit>().updateField('7_rows', newRows, _workOrderSutmItemId);
    }

    void updateRowField(int index, String key, dynamic value) {
      final newRows = List<Map<String, dynamic>>.from(rows.map((r) => Map<String, dynamic>.from(r as Map)));
      newRows[index][key] = value;
      context.read<InspeksiFormCubit>().updateField('7_rows', newRows, _workOrderSutmItemId);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Daftar ROW & Lingkungan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (!_isReadOnly)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Tambah ROW', style: TextStyle(fontSize: 12)),
                onPressed: addRow,
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (rows.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.nature_people_outlined, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text('Belum ada data ROW tercatat', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                if (!_isReadOnly) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Data ROW Pertama'),
                    onPressed: addRow,
                  ),
                ],
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final r = rows[index] as Map<String, dynamic>;
              final rowPhotoKey = 'rowFoto$index';

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ROW #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                        ),
                        if (!_isReadOnly)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            onPressed: () => removeRow(index),
                          ),
                      ],
                    ),
                    const Divider(),
                    Text('ID Entitas: ${r['idEntitas']}', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),

                    _buildDropdown(
                      label: 'Jenis Entitas',
                      fieldKey: 'row_${index}_jenis',
                      value: r['jenisEntitas'] as String?,
                      options: SutmFormConstants.jenisEntitasOptions,
                      onChanged: (v) => updateRowField(index, 'jenisEntitas', v),
                    ),
                    const SizedBox(height: 10),

                    _buildDropdown(
                      label: 'Jarak Aman',
                      fieldKey: 'row_${index}_jarak',
                      value: r['jarak'] as String?,
                      options: SutmFormConstants.jarakOptions,
                      onChanged: (v) => updateRowField(index, 'jarak', v),
                    ),
                    const SizedBox(height: 10),

                    _buildDropdown(
                      label: 'Fasa Terkena Dampak',
                      fieldKey: 'row_${index}_fasa',
                      value: r['fasa'] as String?,
                      options: SutmFormConstants.fasaRowOptions,
                      onChanged: (v) => updateRowField(index, 'fasa', v),
                    ),
                    const SizedBox(height: 10),

                    // Koordinat GPS ROW
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'GPS: ${r['latitude']?.toString() ?? '-'}, ${r['longitude']?.toString() ?? '-'}',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                        if (!_isReadOnly)
                          TextButton.icon(
                            icon: const Icon(Icons.my_location, size: 14),
                            label: const Text('Ambil GPS', style: TextStyle(fontSize: 11)),
                            onPressed: () async {
                              try {
                                final pos = await Geolocator.getCurrentPosition();
                                updateRowField(index, 'latitude', pos.latitude);
                                updateRowField(index, 'longitude', pos.longitude);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Koordinat ROW diperbarui')),
                                  );
                                }
                              } catch (_) {}
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _buildPhotoField(
                      label: 'Foto ROW #${index + 1}',
                      attachmentKey: rowPhotoKey,
                      fileOrUrl: attachments[rowPhotoKey],
                      isRequired: false,
                      onTap: () => _openCamera(rowPhotoKey),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
