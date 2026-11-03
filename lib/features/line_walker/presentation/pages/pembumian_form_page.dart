import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../data/models/pembumian_model.dart';
import '../../data/models/tower_asset_model.dart';
import '../cubit/pembumian_cubit.dart';

class PembumianFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialDraft;
  final int? draftId;

  const PembumianFormPage({
    super.key,
    this.initialDraft,
    this.draftId,
  });

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
  String _legAStatus = 'BAIK';
  File? _legAPict;
  File? _legAStatusPict;

  final TextEditingController _legBHasilCtrl = TextEditingController();
  String _legBStatus = 'BAIK';
  File? _legBPict;
  File? _legBStatusPict;

  final TextEditingController _legCHasilCtrl = TextEditingController();
  String _legCStatus = 'BAIK';
  File? _legCPict;
  File? _legCStatusPict;

  final TextEditingController _legDHasilCtrl = TextEditingController();
  String _legDStatus = 'BAIK';
  File? _legDPict;
  File? _legDStatusPict;

  final TextEditingController _igswHasilCtrl = TextEditingController();
  String _igswStatus = 'BAIK';
  File? _igswPict;
  File? _igswStatusPict;

  final TextEditingController _groundingLangsungHasilCtrl = TextEditingController();
  String _groundingLangsungStatus = 'BAIK';
  File? _groundingLangsungPict;
  File? _groundingLangsungStatusPict;

  final TextEditingController _bersamaHasilCtrl = TextEditingController();
  String _bersamaStatus = 'BAIK';
  File? _bersamaPict;
  File? _bersamaStatusPict;

  final TextEditingController _mdgHasilCtrl = TextEditingController();
  String _mdgStatus = 'BAIK';
  File? _mdgPict;
  File? _mdgStatusPict;

  // Anomali
  final TextEditingController _catatanAnomaliCtrl = TextEditingController();
  File? _fotoAnomali;

  @override
  void initState() {
    super.initState();
    context.read<PembumianCubit>().loadTowers();
    _loadInitialDraft();
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
      if (d['fotoSebelumPath'] != null) _fotoSebelum = File(d['fotoSebelumPath']);
      if (d['fotoSetelahPath'] != null) _fotoSetelah = File(d['fotoSetelahPath']);

      void loadLeg(Map<String, dynamic>? leg, TextEditingController ctrl, Function(String) setStatus, Function(File?) setPict, Function(File?) setStatusPict) {
        if (leg != null) {
          if (leg['hasil'] != null) ctrl.text = leg['hasil'].toString();
          if (leg['status'] != null) setStatus(leg['status']);
          if (leg['pictPath'] != null) setPict(File(leg['pictPath']));
          if (leg['statusPictPath'] != null) setStatusPict(File(leg['statusPictPath']));
        }
      }

      loadLeg(d['legA'], _legAHasilCtrl, (s) => _legAStatus = s, (f) => _legAPict = f, (f) => _legAStatusPict = f);
      loadLeg(d['legB'], _legBHasilCtrl, (s) => _legBStatus = s, (f) => _legBPict = f, (f) => _legBStatusPict = f);
      loadLeg(d['legC'], _legCHasilCtrl, (s) => _legCStatus = s, (f) => _legCPict = f, (f) => _legCStatusPict = f);
      loadLeg(d['legD'], _legDHasilCtrl, (s) => _legDStatus = s, (f) => _legDPict = f, (f) => _legDStatusPict = f);
      loadLeg(d['igsw'], _igswHasilCtrl, (s) => _igswStatus = s, (f) => _igswPict = f, (f) => _igswStatusPict = f);
      loadLeg(d['groundingLangsung'], _groundingLangsungHasilCtrl, (s) => _groundingLangsungStatus = s, (f) => _groundingLangsungPict = f, (f) => _groundingLangsungStatusPict = f);
      loadLeg(d['bersama'], _bersamaHasilCtrl, (s) => _bersamaStatus = s, (f) => _bersamaPict = f, (f) => _bersamaStatusPict = f);
      loadLeg(d['mdg'], _mdgHasilCtrl, (s) => _mdgStatus = s, (f) => _mdgPict = f, (f) => _mdgStatusPict = f);

      if (d['catatanAnomali'] != null) _catatanAnomaliCtrl.text = d['catatanAnomali'];
      if (d['fotoAnomaliPath'] != null) _fotoAnomali = File(d['fotoAnomaliPath']);
    }
  }

  @override
  void dispose() {
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

  LegInputModel? _buildLeg(TextEditingController ctrl, String status, File? pict, File? statusPict) {
    if (ctrl.text.isEmpty && pict == null && statusPict == null) return null;
    return LegInputModel(
      hasil: double.tryParse(ctrl.text),
      status: status,
      pict: pict,
      statusPict: statusPict,
    );
  }

  PembumianInputModel _buildInputModel() {
    return PembumianInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      kendala: _selectedKendala,
      fotoSebelum: _fotoSebelum,
      fotoSetelah: _fotoSetelah,
      legA: _buildLeg(_legAHasilCtrl, _legAStatus, _legAPict, _legAStatusPict),
      legB: _buildLeg(_legBHasilCtrl, _legBStatus, _legBPict, _legBStatusPict),
      legC: _buildLeg(_legCHasilCtrl, _legCStatus, _legCPict, _legCStatusPict),
      legD: _buildLeg(_legDHasilCtrl, _legDStatus, _legDPict, _legDStatusPict),
      igsw: _buildLeg(_igswHasilCtrl, _igswStatus, _igswPict, _igswStatusPict),
      groundingLangsung: _buildLeg(_groundingLangsungHasilCtrl, _groundingLangsungStatus, _groundingLangsungPict, _groundingLangsungStatusPict),
      bersama: _buildLeg(_bersamaHasilCtrl, _bersamaStatus, _bersamaPict, _bersamaStatusPict),
      mdg: _buildLeg(_mdgHasilCtrl, _mdgStatus, _mdgPict, _mdgStatusPict),
      catatanAnomali: _catatanAnomaliCtrl.text.isNotEmpty ? _catatanAnomaliCtrl.text : null,
      fotoAnomali: _fotoAnomali,
    );
  }

  Future<void> _handleSaveDraft() async {
    final input = _buildInputModel();
    await context.read<PembumianCubit>().saveDraft(input);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data pembumian berhasil disimpan sebagai draft offline'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  void _handleSubmit() {
    if (_selectedTower == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih objek tower terlebih dahulu')),
      );
      return;
    }

    if (_selectedKendala == 'TIDAK') {
      final input = _buildInputModel();
      if (input.legA == null &&
          input.legB == null &&
          input.legC == null &&
          input.legD == null &&
          input.igsw == null &&
          input.groundingLangsung == null &&
          input.bersama == null &&
          input.mdg == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jika tidak ada kendala, minimal salah satu leg/grounding wajib diisi!')),
        );
        return;
      }
    }

    final input = _buildInputModel();
    context.read<PembumianCubit>().submitPembumian(input, draftId: widget.draftId);
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Hasil Nilai (Ohm)',
                hintText: 'Contoh: 1.5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: status,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: const [
                DropdownMenuItem(value: 'BAIK', child: Text('BAIK')),
                DropdownMenuItem(value: 'TIDAK BAIK', child: Text('TIDAK BAIK')),
              ],
              onChanged: (val) {
                if (val != null) onStatusChanged(val);
              },
            ),
            const SizedBox(height: 12),
            FieldPictInput(
              label: 'Foto Hasil $title',
              placeholder: 'Ambil Foto Hasil',
              pictureFile: pict,
              onChange: onPictChanged,
            ),
            const SizedBox(height: 12),
            FieldPictInput(
              label: 'Foto Status $title',
              placeholder: 'Ambil Foto Kondisi/Status',
              pictureFile: statusPict,
              onChange: onStatusPictChanged,
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is PembumianSubmitFailure) {
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
          final isSubmitting = state is PembumianSubmitting;
          List<TowerAssetModel> towers = [];
          if (state is PembumianLoaded) {
            towers = state.towers;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tower & Kendala Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PILIH OBJEK & KENDALA',
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
                              setState(() {
                                _selectedTower = tower;
                              });
                              context.read<PembumianCubit>().selectTower(tower);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedKendala,
                          decoration: InputDecoration(
                            labelText: 'Kendala',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'TIDAK', child: Text('TIDAK ADA KENDALA')),
                            DropdownMenuItem(value: 'BANJIR', child: Text('BANJIR')),
                            DropdownMenuItem(value: 'TIDAK BISA DIAKSES', child: Text('TIDAK BISA DIAKSES')),
                            DropdownMenuItem(value: 'LAINNYA', child: Text('LAINNYA')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedKendala = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Foto Sebelum & Setelah
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        FieldPictInput(
                          label: 'Foto Tower Sebelum Inspeksi',
                          placeholder: 'Ambil Foto Sebelum',
                          pictureFile: _fotoSebelum,
                          onChange: (f) => setState(() => _fotoSebelum = f),
                        ),
                        const SizedBox(height: 16),
                        FieldPictInput(
                          label: 'Foto Tower Setelah Inspeksi',
                          placeholder: 'Ambil Foto Setelah',
                          pictureFile: _fotoSetelah,
                          onChange: (f) => setState(() => _fotoSetelah = f),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Legs
                _buildLegSection('LEG A', _legAHasilCtrl, _legAStatus, (s) => setState(() => _legAStatus = s), _legAPict, (f) => setState(() => _legAPict = f), _legAStatusPict, (f) => setState(() => _legAStatusPict = f)),
                _buildLegSection('LEG B', _legBHasilCtrl, _legBStatus, (s) => setState(() => _legBStatus = s), _legBPict, (f) => setState(() => _legBPict = f), _legBStatusPict, (f) => setState(() => _legBStatusPict = f)),
                _buildLegSection('LEG C', _legCHasilCtrl, _legCStatus, (s) => setState(() => _legCStatus = s), _legCPict, (f) => setState(() => _legCPict = f), _legCStatusPict, (f) => setState(() => _legCStatusPict = f)),
                _buildLegSection('LEG D', _legDHasilCtrl, _legDStatus, (s) => setState(() => _legDStatus = s), _legDPict, (f) => setState(() => _legDPict = f), _legDStatusPict, (f) => setState(() => _legDStatusPict = f)),
                _buildLegSection('IGSW', _igswHasilCtrl, _igswStatus, (s) => setState(() => _igswStatus = s), _igswPict, (f) => setState(() => _igswPict = f), _igswStatusPict, (f) => setState(() => _igswStatusPict = f)),
                _buildLegSection('GROUNDING LANGSUNG', _groundingLangsungHasilCtrl, _groundingLangsungStatus, (s) => setState(() => _groundingLangsungStatus = s), _groundingLangsungPict, (f) => setState(() => _groundingLangsungPict = f), _groundingLangsungStatusPict, (f) => setState(() => _groundingLangsungStatusPict = f)),
                _buildLegSection('BERSAMA', _bersamaHasilCtrl, _bersamaStatus, (s) => setState(() => _bersamaStatus = s), _bersamaPict, (f) => setState(() => _bersamaPict = f), _bersamaStatusPict, (f) => setState(() => _bersamaStatusPict = f)),
                _buildLegSection('MDG', _mdgHasilCtrl, _mdgStatus, (s) => setState(() => _mdgStatus = s), _mdgPict, (f) => setState(() => _mdgPict = f), _mdgStatusPict, (f) => setState(() => _mdgStatusPict = f)),

                // Anomali
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ANOMALI (OPSIONAL)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _catatanAnomaliCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Catatan Anomali',
                            hintText: 'Tuliskan catatan anomali jika ada...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Foto Anomali',
                          placeholder: 'Ambil Foto Anomali',
                          pictureFile: _fotoAnomali,
                          onChange: (f) => setState(() => _fotoAnomali = f),
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
                          'Simpan Pembumian',
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
