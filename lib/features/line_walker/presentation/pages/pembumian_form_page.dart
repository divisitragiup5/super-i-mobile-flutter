import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_label.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_toggle_bar.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../../home/presentation/cubit/drafts_cubit.dart';
import '../../data/models/pembumian_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../cubit/pembumian_cubit.dart';

const List<Map<String, String>> _pembumianStatuses = [
  {'value': 'NORMAL (9)', 'label': 'NORMAL'},
  {'value': 'KOROSI (6)', 'label': 'KOROSI'},
  {'value': 'RANTAS (6)', 'label': 'RANTAS'},
  {'value': 'PUTUS (1)', 'label': 'PUTUS'},
  {'value': 'LEPAS (1)', 'label': 'LEPAS'},
  {'value': 'HILANG (1)', 'label': 'HILANG'},
];

class PembumianFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialDraft;
  final int? draftId;

  const PembumianFormPage({super.key, this.initialDraft, this.draftId});

  @override
  State<PembumianFormPage> createState() => _PembumianFormPageState();
}

class _PembumianFormPageState extends State<PembumianFormPage> {
  TowerAssetModel? _selectedTower;
  String _selectedKendala = 'TIDAK';

  File? _fotoSebelum;
  File? _fotoSetelah;

  // Legs controllers & states
  final TextEditingController _legAHasilCtrl = TextEditingController();
  String _legAStatus = '';
  File? _legAPict;
  File? _legAStatusPict;

  final TextEditingController _legBHasilCtrl = TextEditingController();
  String _legBStatus = '';
  File? _legBPict;
  File? _legBStatusPict;

  final TextEditingController _legCHasilCtrl = TextEditingController();
  String _legCStatus = '';
  File? _legCPict;
  File? _legCStatusPict;

  final TextEditingController _legDHasilCtrl = TextEditingController();
  String _legDStatus = '';
  File? _legDPict;
  File? _legDStatusPict;

  final TextEditingController _igswHasilCtrl = TextEditingController();
  String _igswStatus = '';
  File? _igswPict;
  File? _igswStatusPict;

  final TextEditingController _groundingLangsungHasilCtrl =
      TextEditingController();
  String _groundingLangsungStatus = '';
  File? _groundingLangsungPict;
  File? _groundingLangsungStatusPict;

  final TextEditingController _bersamaHasilCtrl = TextEditingController();
  String _bersamaStatus = '';
  File? _bersamaPict;
  File? _bersamaStatusPict;

  final TextEditingController _mdgHasilCtrl = TextEditingController();
  String _mdgStatus = '';
  File? _mdgPict;
  File? _mdgStatusPict;

  // Anomali
  final TextEditingController _catatanAnomaliCtrl = TextEditingController();
  File? _fotoAnomali;

  @override
  void initState() {
    super.initState();
    _legAHasilCtrl.addListener(_onFieldChanged);
    _legBHasilCtrl.addListener(_onFieldChanged);
    _legCHasilCtrl.addListener(_onFieldChanged);
    _legDHasilCtrl.addListener(_onFieldChanged);
    _igswHasilCtrl.addListener(_onFieldChanged);
    _groundingLangsungHasilCtrl.addListener(_onFieldChanged);
    _bersamaHasilCtrl.addListener(_onFieldChanged);
    _mdgHasilCtrl.addListener(_onFieldChanged);
    _catatanAnomaliCtrl.addListener(_onFieldChanged);
    context.read<PembumianCubit>().loadTowers();
    _loadInitialDraft();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _onChangeKendala(String val) {
    setState(() {
      _selectedKendala = val;
      if (val == 'KENDALA') {
        _legAHasilCtrl.clear();
        _legAStatus = '';
        _legAPict = null;
        _legAStatusPict = null;

        _legBHasilCtrl.clear();
        _legBStatus = '';
        _legBPict = null;
        _legBStatusPict = null;

        _legCHasilCtrl.clear();
        _legCStatus = '';
        _legCPict = null;
        _legCStatusPict = null;

        _legDHasilCtrl.clear();
        _legDStatus = '';
        _legDPict = null;
        _legDStatusPict = null;

        _igswHasilCtrl.clear();
        _igswStatus = '';
        _igswPict = null;
        _igswStatusPict = null;

        _groundingLangsungHasilCtrl.clear();
        _groundingLangsungStatus = '';
        _groundingLangsungPict = null;
        _groundingLangsungStatusPict = null;

        _bersamaHasilCtrl.clear();
        _bersamaStatus = '';
        _bersamaPict = null;
        _bersamaStatusPict = null;

        _mdgHasilCtrl.clear();
        _mdgStatus = '';
        _mdgPict = null;
        _mdgStatusPict = null;
      }
    });
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
      _selectedKendala = d['kendala']?.toString() ?? 'TIDAK';
      if (d['fotoSebelumPath'] != null) {
        _fotoSebelum = File(d['fotoSebelumPath']);
      }
      if (d['fotoSetelahPath'] != null) {
        _fotoSetelah = File(d['fotoSetelahPath']);
      }

      void loadLeg(
        Map<String, dynamic>? leg,
        TextEditingController ctrl,
        Function(String) setStatus,
        Function(File?) setPict,
        Function(File?) setStatusPict,
      ) {
        if (leg != null) {
          if (leg['hasil'] != null) ctrl.text = leg['hasil'].toString();
          if (leg['status'] != null) {
            final st = leg['status'].toString();
            setStatus(
              _pembumianStatuses.any((s) => s['value'] == st)
                  ? st
                  : 'NORMAL (9)',
            );
          }
          if (leg['pictPath'] != null) setPict(File(leg['pictPath']));
          if (leg['statusPictPath'] != null) {
            setStatusPict(File(leg['statusPictPath']));
          }
        }
      }

      loadLeg(
        d['legA'],
        _legAHasilCtrl,
        (s) => _legAStatus = s,
        (f) => _legAPict = f,
        (f) => _legAStatusPict = f,
      );
      loadLeg(
        d['legB'],
        _legBHasilCtrl,
        (s) => _legBStatus = s,
        (f) => _legBPict = f,
        (f) => _legBStatusPict = f,
      );
      loadLeg(
        d['legC'],
        _legCHasilCtrl,
        (s) => _legCStatus = s,
        (f) => _legCPict = f,
        (f) => _legCStatusPict = f,
      );
      loadLeg(
        d['legD'],
        _legDHasilCtrl,
        (s) => _legDStatus = s,
        (f) => _legDPict = f,
        (f) => _legDStatusPict = f,
      );
      loadLeg(
        d['igsw'],
        _igswHasilCtrl,
        (s) => _igswStatus = s,
        (f) => _igswPict = f,
        (f) => _igswStatusPict = f,
      );
      loadLeg(
        d['groundingLangsung'],
        _groundingLangsungHasilCtrl,
        (s) => _groundingLangsungStatus = s,
        (f) => _groundingLangsungPict = f,
        (f) => _groundingLangsungStatusPict = f,
      );
      loadLeg(
        d['bersama'],
        _bersamaHasilCtrl,
        (s) => _bersamaStatus = s,
        (f) => _bersamaPict = f,
        (f) => _bersamaStatusPict = f,
      );
      loadLeg(
        d['mdg'],
        _mdgHasilCtrl,
        (s) => _mdgStatus = s,
        (f) => _mdgPict = f,
        (f) => _mdgStatusPict = f,
      );

      if (d['catatanAnomali'] != null) {
        _catatanAnomaliCtrl.text = d['catatanAnomali'];
      }
      if (d['fotoAnomaliPath'] != null) {
        _fotoAnomali = File(d['fotoAnomaliPath']);
      }
    }
  }

  @override
  void dispose() {
    _legAHasilCtrl.removeListener(_onFieldChanged);
    _legBHasilCtrl.removeListener(_onFieldChanged);
    _legCHasilCtrl.removeListener(_onFieldChanged);
    _legDHasilCtrl.removeListener(_onFieldChanged);
    _igswHasilCtrl.removeListener(_onFieldChanged);
    _groundingLangsungHasilCtrl.removeListener(_onFieldChanged);
    _bersamaHasilCtrl.removeListener(_onFieldChanged);
    _mdgHasilCtrl.removeListener(_onFieldChanged);
    _catatanAnomaliCtrl.removeListener(_onFieldChanged);
    _legAHasilCtrl.dispose();
    _legBHasilCtrl.dispose();
    _legCHasilCtrl.dispose();
    _legDHasilCtrl.dispose();
    _igswHasilCtrl.dispose();
    _groundingLangsungHasilCtrl.dispose();
    _bersamaHasilCtrl.dispose();
    _mdgHasilCtrl.dispose();
    _catatanAnomaliCtrl.dispose();
    super.dispose();
  }

  LegInputModel? _buildLeg(
    TextEditingController ctrl,
    String status,
    File? pict,
    File? statusPict,
  ) {
    if (ctrl.text.isEmpty && pict == null && statusPict == null) return null;
    return LegInputModel(
      hasil: double.tryParse(ctrl.text),
      status: status,
      pict: pict,
      statusPict: statusPict,
    );
  }

  PembumianInputModel _buildInputModel() {
    final isKendala = _selectedKendala == 'KENDALA';
    return PembumianInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      kendala: _selectedKendala,
      fotoSebelum: _fotoSebelum,
      fotoSetelah: _fotoSetelah,
      legA: isKendala
          ? null
          : _buildLeg(_legAHasilCtrl, _legAStatus, _legAPict, _legAStatusPict),
      legB: isKendala
          ? null
          : _buildLeg(_legBHasilCtrl, _legBStatus, _legBPict, _legBStatusPict),
      legC: isKendala
          ? null
          : _buildLeg(_legCHasilCtrl, _legCStatus, _legCPict, _legCStatusPict),
      legD: isKendala
          ? null
          : _buildLeg(_legDHasilCtrl, _legDStatus, _legDPict, _legDStatusPict),
      igsw: isKendala
          ? null
          : _buildLeg(_igswHasilCtrl, _igswStatus, _igswPict, _igswStatusPict),
      groundingLangsung: isKendala
          ? null
          : _buildLeg(
              _groundingLangsungHasilCtrl,
              _groundingLangsungStatus,
              _groundingLangsungPict,
              _groundingLangsungStatusPict,
            ),
      bersama: isKendala
          ? null
          : _buildLeg(
              _bersamaHasilCtrl,
              _bersamaStatus,
              _bersamaPict,
              _bersamaStatusPict,
            ),
      mdg: isKendala
          ? null
          : _buildLeg(_mdgHasilCtrl, _mdgStatus, _mdgPict, _mdgStatusPict),
      catatanAnomali: _catatanAnomaliCtrl.text.isNotEmpty
          ? _catatanAnomaliCtrl.text
          : null,
      fotoAnomali: _fotoAnomali,
    );
  }

  String? _validateLeg(
    String name,
    TextEditingController ctrl,
    File? pict,
    File? statusPict,
  ) {
    final hasAny =
        ctrl.text.trim().isNotEmpty || pict != null || statusPict != null;
    if (hasAny) {
      if (ctrl.text.trim().isEmpty) return 'Nilai hasil $name wajib diisi';
      if (double.tryParse(ctrl.text.trim()) == null) {
        return 'Nilai hasil $name harus berupa angka valid';
      }
      if (pict == null) return 'Foto hasil $name wajib diambil';
      if (statusPict == null) return 'Foto kondisi/status $name wajib diambil';
    }
    return null;
  }

  String? _validateForm() {
    if (_selectedTower == null) {
      return 'Pilih objek tower terlebih dahulu';
    }
    if (_fotoSebelum == null) {
      return 'Foto tower sebelum inspeksi wajib diambil';
    }
    if (_fotoSetelah == null) {
      return 'Foto tower setelah inspeksi wajib diambil';
    }

    if (_selectedKendala == 'TIDAK') {
      // Validasi kelengkapan masing-masing leg/grounding jika diisi
      final legErrors = [
        _validateLeg('LEG A', _legAHasilCtrl, _legAPict, _legAStatusPict),
        _validateLeg('LEG B', _legBHasilCtrl, _legBPict, _legBStatusPict),
        _validateLeg('LEG C', _legCHasilCtrl, _legCPict, _legCStatusPict),
        _validateLeg('LEG D', _legDHasilCtrl, _legDPict, _legDStatusPict),
        _validateLeg('IGSW', _igswHasilCtrl, _igswPict, _igswStatusPict),
        _validateLeg(
          'GROUNDING LANGSUNG',
          _groundingLangsungHasilCtrl,
          _groundingLangsungPict,
          _groundingLangsungStatusPict,
        ),
        _validateLeg(
          'BERSAMA',
          _bersamaHasilCtrl,
          _bersamaPict,
          _bersamaStatusPict,
        ),
        _validateLeg('MDG', _mdgHasilCtrl, _mdgPict, _mdgStatusPict),
      ];
      for (final err in legErrors) {
        if (err != null) return err;
      }

      final input = _buildInputModel();
      if (input.legA == null &&
          input.legB == null &&
          input.legC == null &&
          input.legD == null &&
          input.igsw == null &&
          input.groundingLangsung == null &&
          input.bersama == null &&
          input.mdg == null) {
        return 'Salah satu dari LEG A, LEG B, LEG C, LEG D, IGSW, GROUNDING LANGSUNG, BERSAMA, atau MDG wajib di isi';
      }
    }

    final hasCatatanAnomali = _catatanAnomaliCtrl.text.trim().isNotEmpty;
    final hasFotoAnomali = _fotoAnomali != null;
    if (hasCatatanAnomali && !hasFotoAnomali) {
      return 'Lengkapi foto anomali';
    }
    if (!hasCatatanAnomali && hasFotoAnomali) {
      return 'Tulis catatan anomali';
    }

    return null;
  }

  Future<void> _handleSaveDraft() async {
    final error = _validateForm();
    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    final input = _buildInputModel();
    await context.read<PembumianCubit>().saveDraft(input);
    try {
      sl<DraftsCubit>().loadDrafts();
    } catch (_) {}
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        'Data pembumian berhasil disimpan sebagai draft offline',
      );
      context.pop();
    }
  }

  void _handleSubmit() {
    final error = _validateForm();
    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah anda yakin ingin menyimpan data pembumian ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final input = _buildInputModel();
              context.read<PembumianCubit>().submitPembumian(
                input,
                draftId: widget.draftId,
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegSection(
    String title,
    TextEditingController ctrl,
    String status,
    Function(String) onStatusChanged,
    File? pict,
    Function(File?) onPictChanged,
    File? statusPict,
    Function(File?) onStatusPictChanged,
  ) {
    final isFilled =
        ctrl.text.trim().isNotEmpty || pict != null || statusPict != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                if (isFilled)
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            FieldPictInput(
              label: 'Foto Hasil $title',
              placeholder: 'Ambil Foto',
              isRequired: isFilled,
              forceLandscape: true,
              pictureFile: pict,
              onChange: onPictChanged,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onTapOutside: (event) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                label: AppInputLabel('Hasil', isRequired: isFilled),
                hintText: 'Tulis Hasil',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FieldPictInput(
              label: 'Foto Status $title',
              placeholder: 'Ambil Foto',
              isRequired: isFilled,
              forceLandscape: true,
              pictureFile: statusPict,
              onChange: onStatusPictChanged,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _pembumianStatuses.any((s) => s['value'] == status)
                  ? status
                  : null,
              decoration: InputDecoration(
                label: AppInputLabel('Status', isRequired: isFilled),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _pembumianStatuses.map((s) {
                return DropdownMenuItem<String>(
                  value: s['value']!,
                  child: Text(s['label']!),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onStatusChanged(val);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Pembumian'),
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
      body: BlocConsumer<PembumianCubit, PembumianState>(
        listener: (context, state) {
          if (state is PembumianSubmitSuccess) {
            AppSnackbar.showSuccess(context, state.message);
            context.pop();
          } else if (state is PembumianSubmitFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final isSubmitting = state is PembumianSubmitting;
          Map<String, dynamic>? lastInspection;
          bool isLoadingLast = false;
          List<TowerAssetModel> towers = [];
          if (state is PembumianLoaded) {
            towers = state.towers;
            lastInspection = state.lastInspection;
            isLoadingLast = state.isLoadingLast;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Pilih Objek
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'PILIH OBJEK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SearchableDropdown<int>(
                          label: 'Pilih Objek',
                          hint: 'Pilih tower atau gantry',
                          isRequired: true,
                          isLoading: state is PembumianLoading ||
                              (towers.isEmpty && state is! PembumianLoaded),
                          value: _selectedTower?.id,
                          items: towers
                              .map(
                                (t) => DropdownItem<int>(
                                  value: t.id,
                                  label: t.nama,
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            if (id != null) {
                              final tower = towers.firstWhere(
                                (t) => t.id == id,
                              );
                              setState(() {
                                _selectedTower = tower;
                              });
                              context.read<PembumianCubit>().selectTower(tower);
                            }
                          },
                        ),
                        if (_selectedTower != null) ...[
                          const SizedBox(height: 12),
                          if (isLoadingLast)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          else if (lastInspection != null)
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                              onPressed: () {
                                context.push(
                                  AppRoutes.riwayatPembumianDetail,
                                  extra: lastInspection,
                                );
                              },
                              child: const Text(
                                'Lihat Inspeksi Terakhir',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Data inspeksi tidak ditemukan',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Kendala (Toggle Bar)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppToggleBar<String>(
                      label: 'Kendala',
                      isRequired: true,
                      selectedValue: _selectedKendala,
                      items: const [
                        ToggleItem(label: 'TIDAK', value: 'TIDAK'),
                        ToggleItem(label: 'KENDALA', value: 'KENDALA'),
                      ],
                      onValueChanged: _onChangeKendala,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Foto Tower Sebelum Inspeksi
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FieldPictInput(
                      label: 'Foto Tower Sebelum Inspeksi',
                      placeholder: 'Ambil Foto',
                      isRequired: true,
                      forceLandscape: true,
                      pictureFile: _fotoSebelum,
                      onChange: (f) => setState(() => _fotoSebelum = f),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Titik Pentanahan (HANYA JIKA kendala == 'TIDAK')
                if (_selectedKendala == 'TIDAK') ...[
                  // Banner Status Kelengkapan Titik Pentanahan
                  Builder(
                    builder: (context) {
                      final hasAnyCompleteLeg =
                          (_legAHasilCtrl.text.isNotEmpty &&
                              _legAPict != null &&
                              _legAStatusPict != null) ||
                          (_legBHasilCtrl.text.isNotEmpty &&
                              _legBPict != null &&
                              _legBStatusPict != null) ||
                          (_legCHasilCtrl.text.isNotEmpty &&
                              _legCPict != null &&
                              _legCStatusPict != null) ||
                          (_legDHasilCtrl.text.isNotEmpty &&
                              _legDPict != null &&
                              _legDStatusPict != null) ||
                          (_igswHasilCtrl.text.isNotEmpty &&
                              _igswPict != null &&
                              _igswStatusPict != null) ||
                          (_groundingLangsungHasilCtrl.text.isNotEmpty &&
                              _groundingLangsungPict != null &&
                              _groundingLangsungStatusPict != null) ||
                          (_bersamaHasilCtrl.text.isNotEmpty &&
                              _bersamaPict != null &&
                              _bersamaStatusPict != null) ||
                          (_mdgHasilCtrl.text.isNotEmpty &&
                              _mdgPict != null &&
                              _mdgStatusPict != null);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: hasAnyCompleteLeg
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.danger.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasAnyCompleteLeg
                                ? AppColors.success.withValues(alpha: 0.3)
                                : AppColors.danger.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasAnyCompleteLeg
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              size: 18,
                              color: hasAnyCompleteLeg
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hasAnyCompleteLeg
                                    ? 'Pengukuran pentanahan terpenuhi ✓'
                                    : 'Wajib mengisi minimal salah satu leg/grounding secara lengkap *',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: hasAnyCompleteLeg
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 8 Legs
                  _buildLegSection(
                    'LEG A',
                    _legAHasilCtrl,
                    _legAStatus,
                    (s) => setState(() => _legAStatus = s),
                    _legAPict,
                    (f) => setState(() => _legAPict = f),
                    _legAStatusPict,
                    (f) => setState(() => _legAStatusPict = f),
                  ),
                  _buildLegSection(
                    'LEG B',
                    _legBHasilCtrl,
                    _legBStatus,
                    (s) => setState(() => _legBStatus = s),
                    _legBPict,
                    (f) => setState(() => _legBPict = f),
                    _legBStatusPict,
                    (f) => setState(() => _legBStatusPict = f),
                  ),
                  _buildLegSection(
                    'LEG C',
                    _legCHasilCtrl,
                    _legCStatus,
                    (s) => setState(() => _legCStatus = s),
                    _legCPict,
                    (f) => setState(() => _legCPict = f),
                    _legCStatusPict,
                    (f) => setState(() => _legCStatusPict = f),
                  ),
                  _buildLegSection(
                    'LEG D',
                    _legDHasilCtrl,
                    _legDStatus,
                    (s) => setState(() => _legDStatus = s),
                    _legDPict,
                    (f) => setState(() => _legDPict = f),
                    _legDStatusPict,
                    (f) => setState(() => _legDStatusPict = f),
                  ),
                  _buildLegSection(
                    'IGSW',
                    _igswHasilCtrl,
                    _igswStatus,
                    (s) => setState(() => _igswStatus = s),
                    _igswPict,
                    (f) => setState(() => _igswPict = f),
                    _igswStatusPict,
                    (f) => setState(() => _igswStatusPict = f),
                  ),
                  _buildLegSection(
                    'GROUNDING LANGSUNG',
                    _groundingLangsungHasilCtrl,
                    _groundingLangsungStatus,
                    (s) => setState(() => _groundingLangsungStatus = s),
                    _groundingLangsungPict,
                    (f) => setState(() => _groundingLangsungPict = f),
                    _groundingLangsungStatusPict,
                    (f) => setState(() => _groundingLangsungStatusPict = f),
                  ),
                  _buildLegSection(
                    'BERSAMA',
                    _bersamaHasilCtrl,
                    _bersamaStatus,
                    (s) => setState(() => _bersamaStatus = s),
                    _bersamaPict,
                    (f) => setState(() => _bersamaPict = f),
                    _bersamaStatusPict,
                    (f) => setState(() => _bersamaStatusPict = f),
                  ),
                  _buildLegSection(
                    'MDG',
                    _mdgHasilCtrl,
                    _mdgStatus,
                    (s) => setState(() => _mdgStatus = s),
                    _mdgPict,
                    (f) => setState(() => _mdgPict = f),
                    _mdgStatusPict,
                    (f) => setState(() => _mdgStatusPict = f),
                  ),
                ],

                // 5. ANOMALI (Opsional)
                Builder(
                  builder: (context) {
                    final hasCatatan = _catatanAnomaliCtrl.text
                        .trim()
                        .isNotEmpty;
                    final hasFoto = _fotoAnomali != null;
                    final hasAnyAnomali = hasCatatan || hasFoto;

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'ANOMALI',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (hasAnyAnomali)
                                  const Text(
                                    ' *',
                                    style: TextStyle(
                                      color: AppColors.danger,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            FieldPictInput(
                              label: 'Foto',
                              placeholder: 'Ambil Foto',
                              isRequired: hasAnyAnomali,
                              forceLandscape: true,
                              pictureFile: _fotoAnomali,
                              onChange: (f) => setState(() => _fotoAnomali = f),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _catatanAnomaliCtrl,
                              maxLines: 5,
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: InputDecoration(
                                label: AppInputLabel(
                                  'Catatan',
                                  isRequired: hasAnyAnomali,
                                ),
                                hintText: 'Tulis Catatan',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // 6. Foto Tower Setelah Inspeksi
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FieldPictInput(
                      label: 'Foto Tower Setelah Inspeksi',
                      placeholder: 'Ambil Foto',
                      isRequired: true,
                      forceLandscape: true,
                      pictureFile: _fotoSetelah,
                      onChange: (f) => setState(() => _fotoSetelah = f),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
