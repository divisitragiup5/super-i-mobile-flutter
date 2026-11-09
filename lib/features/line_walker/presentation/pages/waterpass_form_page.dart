import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_label.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../../home/presentation/cubit/drafts_cubit.dart';
import '../../data/models/tower_asset_model.dart';
import '../../data/models/waterpass_model.dart';
import '../cubit/waterpass_cubit.dart';

class WaterpassFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialDraft;
  final int? draftId;

  const WaterpassFormPage({super.key, this.initialDraft, this.draftId});

  @override
  State<WaterpassFormPage> createState() => _WaterpassFormPageState();
}

class _WaterpassFormPageState extends State<WaterpassFormPage> {
  TowerAssetModel? _selectedTower;
  File? _fotoSebelum;
  File? _fotoSetelah;

  final TextEditingController _hasilXController = TextEditingController();
  final TextEditingController _hasilYController = TextEditingController();
  final TextEditingController _hasilZController = TextEditingController();

  File? _fotoX;
  File? _fotoY;
  File? _fotoZ;

  @override
  void initState() {
    super.initState();
    _hasilXController.addListener(_onFieldChanged);
    _hasilYController.addListener(_onFieldChanged);
    _hasilZController.addListener(_onFieldChanged);
    context.read<WaterpassCubit>().loadTowers();
    _loadInitialDraft();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  void _loadInitialDraft() {
    if (widget.initialDraft != null) {
      final d = widget.initialDraft!;
      if (d['towerId'] != null) {
        final tid = d['towerId'] is int
            ? d['towerId'] as int
            : int.tryParse('${d['towerId']}') ?? 0;
        if (tid > 0) {
          _selectedTower = TowerAssetModel(
            id: tid,
            nama: d['namaTower']?.toString() ?? 'Tower #$tid',
          );
        }
      }
      if (d['hasilX'] != null) _hasilXController.text = d['hasilX'].toString();
      if (d['hasilY'] != null) _hasilYController.text = d['hasilY'].toString();
      if (d['hasilZ'] != null) _hasilZController.text = d['hasilZ'].toString();

      if (d['fotoSebelumPath'] != null) {
        _fotoSebelum = File(d['fotoSebelumPath']);
      }
      if (d['fotoSetelahPath'] != null) {
        _fotoSetelah = File(d['fotoSetelahPath']);
      }
      if (d['fotoXPath'] != null) _fotoX = File(d['fotoXPath']);
      if (d['fotoYPath'] != null) _fotoY = File(d['fotoYPath']);
      if (d['fotoZPath'] != null) _fotoZ = File(d['fotoZPath']);
    }
  }

  @override
  void dispose() {
    _hasilXController.removeListener(_onFieldChanged);
    _hasilYController.removeListener(_onFieldChanged);
    _hasilZController.removeListener(_onFieldChanged);
    _hasilXController.dispose();
    _hasilYController.dispose();
    _hasilZController.dispose();
    super.dispose();
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

    // Periksa jika ada sumbu yang diisi setengah (hanya nilai atau hanya foto)
    final hasAnyX = _hasilXController.text.trim().isNotEmpty || _fotoX != null;
    if (hasAnyX && (_hasilXController.text.trim().isEmpty || _fotoX == null)) {
      return 'Lengkapi nilai dan foto untuk Waterpass X';
    }
    final hasAnyY = _hasilYController.text.trim().isNotEmpty || _fotoY != null;
    if (hasAnyY && (_hasilYController.text.trim().isEmpty || _fotoY == null)) {
      return 'Lengkapi nilai dan foto untuk Waterpass Y';
    }
    final hasAnyZ = _hasilZController.text.trim().isNotEmpty || _fotoZ != null;
    if (hasAnyZ && (_hasilZController.text.trim().isEmpty || _fotoZ == null)) {
      return 'Lengkapi nilai dan foto untuk Waterpass Z';
    }

    // Minimal 1 sumbu terisi lengkap
    final hasX = _hasilXController.text.trim().isNotEmpty && _fotoX != null;
    final hasY = _hasilYController.text.trim().isNotEmpty && _fotoY != null;
    final hasZ = _hasilZController.text.trim().isNotEmpty && _fotoZ != null;

    if (!hasX || !hasY || !hasZ) {
      return 'Waterpass X, Y, dan Z harus diisi lengkap (nilai & foto)';
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
    await context.read<WaterpassCubit>().saveDraft(input);
    try {
      sl<DraftsCubit>().loadDrafts();
    } catch (_) {}
    if (mounted) {
      AppSnackbar.showSuccess(
        context,
        'Data waterpass berhasil disimpan sebagai draft offline',
      );
      context.pop();
    }
  }

  WaterpassInputModel _buildInputModel() {
    return WaterpassInputModel(
      towerId: _selectedTower?.id ?? 0,
      namaTower: _selectedTower?.nama,
      hasilX: double.tryParse(_hasilXController.text),
      hasilY: double.tryParse(_hasilYController.text),
      hasilZ: double.tryParse(_hasilZController.text),
      fotoSebelum: _fotoSebelum,
      fotoSetelah: _fotoSetelah,
      fotoX: _fotoX,
      fotoY: _fotoY,
      fotoZ: _fotoZ,
    );
  }

  void _handleSubmit() {
    final error = _validateForm();
    if (error != null) {
      AppSnackbar.showError(context, error);
      return;
    }

    final input = _buildInputModel();
    context.read<WaterpassCubit>().submitWaterpass(
      input,
      draftId: widget.draftId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Waterpass'),
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
      body: BlocConsumer<WaterpassCubit, WaterpassState>(
        listener: (context, state) {
          if (state is WaterpassSubmitSuccess) {
            try {
              sl<DraftsCubit>().loadDrafts();
            } catch (_) {}
            AppSnackbar.showSuccess(context, state.message);
            context.pop();
          } else if (state is WaterpassSubmitFailure) {
            AppSnackbar.showError(context, state.message);
          }
        },
        builder: (context, state) {
          final bool isSubmitting = state is WaterpassSubmitting;
          List<TowerAssetModel> towers = [];
          WaterpassDetailModel? lastInspection;
          bool isLoadingLast = false;

          if (state is WaterpassLoaded) {
            towers = state.towers;
            lastInspection = state.lastInspection;
            isLoadingLast = state.isLoadingLast;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card 1: Tower Selection
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PILIH OBJEK TOWER',
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
                          isLoading: state is WaterpassLoading ||
                              (towers.isEmpty && state is! WaterpassLoaded),
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
                              context.read<WaterpassCubit>().selectTower(tower);
                            }
                          },
                        ),
                        if (isLoadingLast) ...[
                          const SizedBox(height: 12),
                          const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Memuat inspeksi sebelumnya...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (lastInspection != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Inspeksi Terakhir',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    ),
                                    Text(
                                      lastInspection.createdAt ?? '-',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF1E40AF),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'X: ${lastInspection.hasilX ?? '-'} | Y: ${lastInspection.hasilY ?? '-'} | Z: ${lastInspection.hasilZ ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
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
                                      AppRoutes.riwayatWaterpassDetail,
                                      extra: lastInspection,
                                    );
                                  },
                                  child: const Text(
                                    'Lihat Inspeksi Terakhir',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 2: Foto Sebelum
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FieldPictInput(
                      label: 'Foto Tower Sebelum Inspeksi',
                      placeholder: 'Ambil Foto Sebelum Inspeksi',
                      isRequired: true,
                      forceLandscape: true,
                      pictureFile: _fotoSebelum,
                      onChange: (file) => setState(() => _fotoSebelum = file),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Indikator Status Kelengkapan Pengukuran Sumbu
                Builder(
                  builder: (context) {
                    final hasCompleteX =
                        _hasilXController.text.trim().isNotEmpty &&
                        _fotoX != null;
                    final hasCompleteY =
                        _hasilYController.text.trim().isNotEmpty &&
                        _fotoY != null;
                    final hasCompleteZ =
                        _hasilZController.text.trim().isNotEmpty &&
                        _fotoZ != null;
                    final hasAnyMeasurement =
                        hasCompleteX || hasCompleteY || hasCompleteZ;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: hasAnyMeasurement
                            ? AppColors.success.withValues(alpha: 0.1)
                            : AppColors.danger.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasAnyMeasurement
                              ? AppColors.success.withValues(alpha: 0.3)
                              : AppColors.danger.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasAnyMeasurement
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            size: 18,
                            color: hasAnyMeasurement
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              hasAnyMeasurement
                                  ? 'Pengukuran waterpass terpenuhi ✓'
                                  : 'Wajib mengisi minimal salah satu sumbu (X, Y, atau Z) secara lengkap *',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: hasAnyMeasurement
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
                const SizedBox(height: 16),

                // Card 3: Waterpass X
                Builder(
                  builder: (context) {
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
                            const Text(
                              'WATERPASS X',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hasilXController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: InputDecoration(
                                label: AppInputLabel(
                                  'Hasil X',
                                  isRequired: true,
                                ),
                                hintText: 'Masukkan nilai hasil X...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FieldPictInput(
                              label: 'Foto Hasil X',
                              placeholder: 'Ambil Foto Waterpass X',
                              isRequired: true,
                              forceLandscape: true,
                              pictureFile: _fotoX,
                              onChange: (file) => setState(() => _fotoX = file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 4: Waterpass Y
                Builder(
                  builder: (context) {
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
                            const Text(
                              'WATERPASS Y',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hasilYController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: InputDecoration(
                                label: AppInputLabel(
                                  'Hasil Y',
                                  isRequired: true,
                                ),
                                hintText: 'Masukkan nilai hasil Y...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FieldPictInput(
                              label: 'Foto Hasil Y',
                              placeholder: 'Ambil Foto Waterpass Y',
                              isRequired: true,
                              forceLandscape: true,
                              pictureFile: _fotoY,
                              onChange: (file) => setState(() => _fotoY = file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 5: Waterpass Z
                Builder(
                  builder: (context) {
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
                            const Text(
                              'WATERPASS Z',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _hasilZController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              onTapOutside: (event) =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              decoration: InputDecoration(
                                label: AppInputLabel(
                                  'Hasil Z',
                                  isRequired: true,
                                ),
                                hintText: 'Masukkan nilai hasil Z...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FieldPictInput(
                              label: 'Foto Hasil Z',
                              placeholder: 'Ambil Foto Waterpass Z',
                              isRequired: true,
                              forceLandscape: true,
                              pictureFile: _fotoZ,
                              onChange: (file) => setState(() => _fotoZ = file),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Card 6: Foto Setelah
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FieldPictInput(
                      label: 'Foto Tower Setelah Inspeksi',
                      placeholder: 'Ambil Foto Setelah Inspeksi',
                      isRequired: true,
                      forceLandscape: true,
                      pictureFile: _fotoSetelah,
                      onChange: (file) => setState(() => _fotoSetelah = file),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit button
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
                          'Simpan Waterpass',
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
