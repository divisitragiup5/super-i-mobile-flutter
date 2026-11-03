import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/searchable_dropdown.dart';
import '../../data/models/tower_asset_model.dart';
import '../../data/models/waterpass_model.dart';
import '../cubit/waterpass_cubit.dart';

class WaterpassFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialDraft;
  final int? draftId;

  const WaterpassFormPage({
    super.key,
    this.initialDraft,
    this.draftId,
  });

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
    context.read<WaterpassCubit>().loadTowers();
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
      if (d['hasilX'] != null) _hasilXController.text = d['hasilX'].toString();
      if (d['hasilY'] != null) _hasilYController.text = d['hasilY'].toString();
      if (d['hasilZ'] != null) _hasilZController.text = d['hasilZ'].toString();

      if (d['fotoSebelumPath'] != null) _fotoSebelum = File(d['fotoSebelumPath']);
      if (d['fotoSetelahPath'] != null) _fotoSetelah = File(d['fotoSetelahPath']);
      if (d['fotoXPath'] != null) _fotoX = File(d['fotoXPath']);
      if (d['fotoYPath'] != null) _fotoY = File(d['fotoYPath']);
      if (d['fotoZPath'] != null) _fotoZ = File(d['fotoZPath']);
    }
  }

  @override
  void dispose() {
    _hasilXController.dispose();
    _hasilYController.dispose();
    _hasilZController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveDraft() async {
    final input = _buildInputModel();
    await context.read<WaterpassCubit>().saveDraft(input);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data waterpass berhasil disimpan sebagai draft offline'),
          backgroundColor: AppColors.success,
        ),
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
    if (_selectedTower == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih objek tower terlebih dahulu')),
      );
      return;
    }
    if (_fotoSebelum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto tower sebelum inspeksi wajib diambil')),
      );
      return;
    }
    if (_fotoSetelah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto tower setelah inspeksi wajib diambil')),
      );
      return;
    }

    // Minimal 1 sumbu terisi
    final hasX = _hasilXController.text.isNotEmpty && _fotoX != null;
    final hasY = _hasilYController.text.isNotEmpty && _fotoY != null;
    final hasZ = _hasilZController.text.isNotEmpty && _fotoZ != null;

    if (!hasX && !hasY && !hasZ) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimal salah satu dari Waterpass X, Y, atau Z harus diisi lengkap (nilai & foto)')),
      );
      return;
    }

    final input = _buildInputModel();
    context.read<WaterpassCubit>().submitWaterpass(input, draftId: widget.draftId);
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is WaterpassSubmitFailure) {
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Memuat inspeksi sebelumnya...',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
                              border: Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF1E40AF)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'X: ${lastInspection.hasilX ?? '-'} | Y: ${lastInspection.hasilY ?? '-'} | Z: ${lastInspection.hasilZ ?? '-'}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FieldPictInput(
                      label: 'Foto Tower Sebelum Inspeksi',
                      placeholder: 'Ambil Foto Sebelum Inspeksi',
                      isRequired: true,
                      pictureFile: _fotoSebelum,
                      onChange: (file) => setState(() => _fotoSebelum = file),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 3: Waterpass X
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Hasil X',
                            hintText: 'Masukkan nilai hasil X...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Foto Hasil X',
                          placeholder: 'Ambil Foto Waterpass X',
                          pictureFile: _fotoX,
                          onChange: (file) => setState(() => _fotoX = file),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 4: Waterpass Y
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Hasil Y',
                            hintText: 'Masukkan nilai hasil Y...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Foto Hasil Y',
                          placeholder: 'Ambil Foto Waterpass Y',
                          pictureFile: _fotoY,
                          onChange: (file) => setState(() => _fotoY = file),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 5: Waterpass Z
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Hasil Z',
                            hintText: 'Masukkan nilai hasil Z...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FieldPictInput(
                          label: 'Foto Hasil Z',
                          placeholder: 'Ambil Foto Waterpass Z',
                          pictureFile: _fotoZ,
                          onChange: (file) => setState(() => _fotoZ = file),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Card 6: Foto Setelah
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: FieldPictInput(
                      label: 'Foto Tower Setelah Inspeksi',
                      placeholder: 'Ambil Foto Setelah Inspeksi',
                      isRequired: true,
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Simpan Waterpass',
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
