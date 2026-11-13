import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/field_camera_widget.dart';
import '../../data/models/sutm_pemeliharaan_model.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../cubit/pemeliharaan_form_cubit.dart';

class InspeksiPemeliharaanFormPage extends StatefulWidget {
  final Map<String, dynamic> params;

  const InspeksiPemeliharaanFormPage({
    super.key,
    required this.params,
  });

  @override
  State<InspeksiPemeliharaanFormPage> createState() =>
      _InspeksiPemeliharaanFormPageState();
}

class _InspeksiPemeliharaanFormPageState
    extends State<InspeksiPemeliharaanFormPage> {
  late int _workOrderId;
  late int _workOrderSutmItemId;
  late int _sutmId;
  late String _idAsset;
  late String _nama;
  late List<RencanaItemModel> _rencanaList;

  String _activeTab = 'Terlaksana'; // 'Terlaksana' | 'Kendala'
  final TextEditingController _globalKendalaController = TextEditingController();
  File? _globalFotoKendala;

  @override
  void initState() {
    super.initState();
    _workOrderId =
        int.tryParse(widget.params['workOrderId']?.toString() ?? '0') ?? 0;
    _workOrderSutmItemId =
        int.tryParse(widget.params['workOrderSutmItemId']?.toString() ?? '0') ??
            0;
    _sutmId = int.tryParse(widget.params['sutmId']?.toString() ?? '0') ?? 0;
    _idAsset = widget.params['idAsset']?.toString() ?? '-';
    _nama = widget.params['nama']?.toString() ?? '-';

    final rawRencana = widget.params['rencana'];
    if (rawRencana is List<RencanaItemModel>) {
      _rencanaList = rawRencana;
    } else if (rawRencana is List) {
      _rencanaList = rawRencana
          .map((r) => r is RencanaItemModel
              ? r
              : RencanaItemModel.fromJson(r as Map<String, dynamic>))
          .toList();
    } else {
      _rencanaList = [];
    }

    context.read<PemeliharaanFormCubit>().initFromRencana(_rencanaList);
  }

  @override
  void dispose() {
    _globalKendalaController.dispose();
    super.dispose();
  }

  void _takePhoto(int index, String type, RincianPemeliharaanItem item) async {
    final file = await FieldCameraWidget.takePhoto(
      context: context,
      title: 'Foto $type - ${item.komponen}',
    );

    if (file != null && mounted) {
      final updated = item.copyWith(
        fotoSebelum: type == 'Sebelum' ? file : item.fotoSebelum,
        fotoProses: type == 'Proses' ? file : item.fotoProses,
        fotoSesudah: type == 'Sesudah' ? file : item.fotoSesudah,
      );
      context.read<PemeliharaanFormCubit>().updateRincianItem(index, updated);
    }
  }

  void _showConditionDetailPopup(RincianPemeliharaanItem item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Hasil Inspeksi Awal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildPopupRow('Sub Aktivitas', item.sub),
                      const Divider(height: 16),
                      _buildPopupRow('Komponen', item.komponen),
                      if (item.fasa != null && item.fasa!.isNotEmpty) ...[
                        const Divider(height: 16),
                        _buildPopupRow('Fasa', item.fasa!),
                      ],
                      const Divider(height: 16),
                      _buildPopupRow(
                        'Kondisi Temuan',
                        item.nilaiAwal ?? 'Perlu Pemeliharaan',
                        isHighlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (item.fotoTemuanAwalUrl != null &&
                    item.fotoTemuanAwalUrl!.isNotEmpty) ...[
                  const Text(
                    'Foto Temuan Inspeksi:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openLightbox(
                      imageUrl: item.fotoTemuanAwalUrl,
                      title: 'Temuan - ${item.komponen}',
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.fotoTemuanAwalUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Text(
                              'Foto tidak tersedia',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Container(
          padding: isHighlight
              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
              : EdgeInsets.zero,
          decoration: isHighlight
              ? BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.red.shade200),
                )
              : null,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Colors.red.shade700 : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _openLightbox({File? file, String? imageUrl, required String title}) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black.withValues(alpha: 0.95),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  maxScale: 4.0,
                  child: file != null
                      ? Image.file(file)
                      : (imageUrl != null
                          ? Image.network(imageUrl)
                          : const SizedBox()),
                ),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PemeliharaanFormCubit, PemeliharaanFormState>(
      listener: (context, state) {
        if (state is PemeliharaanFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
        } else if (state is PemeliharaanFormError) {
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
          title: Text('Pemeliharaan $_idAsset'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
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
            BlocBuilder<PemeliharaanFormCubit, PemeliharaanFormState>(
              builder: (context, state) {
                if (state is PemeliharaanFormSubmitting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rincianItems = state is PemeliharaanFormLoaded
                    ? state.rincianItems
                    : <RincianPemeliharaanItem>[];

                final completedCount = rincianItems.where((item) {
                  if (item.fotoSebelum == null) return false;
                  if (item.status == 'TERLAKSANA') {
                    return item.fotoProses != null && item.fotoSesudah != null;
                  }
                  return item.kendala != null && item.kendala!.trim().isNotEmpty;
                }).length;

                final progressPercent = rincianItems.isNotEmpty
                    ? (completedCount / rincianItems.length).clamp(0.0, 1.0)
                    : 0.0;

                return Column(
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primary.withValues(alpha: 0.95),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _nama,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Aset: $_idAsset',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${rincianItems.length} Target',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Top Tab Switcher: Terlaksana vs Kendala
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _activeTab = 'Terlaksana'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _activeTab == 'Terlaksana'
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Terlaksana',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _activeTab == 'Terlaksana'
                                              ? AppColors.primary
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _activeTab = 'Kendala'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _activeTab == 'Kendala'
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Kendala',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _activeTab == 'Kendala'
                                              ? Colors.red.shade700
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: _activeTab == 'Kendala'
                          ? _buildKendalaTab()
                          : _buildTerlaksanaTab(rincianItems, completedCount, progressPercent),
                    ),

                    // Submit Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (_activeTab == 'Kendala') {
                              if (_globalKendalaController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Harap masukkan deskripsi kendala'),
                                    backgroundColor: AppColors.warning,
                                  ),
                                );
                                return;
                              }
                              context.read<PemeliharaanFormCubit>().setGlobalKendala(
                                    _globalKendalaController.text.trim(),
                                    _globalFotoKendala,
                                  );
                            }
                            context.read<PemeliharaanFormCubit>().submitPemeliharaan(
                                  workOrderId: _workOrderId,
                                  workOrderSutmItemId: _workOrderSutmItemId,
                                  sutmId: _sutmId,
                                );
                          },
                          child: const Text(
                            'Simpan Realisasi Pemeliharaan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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

  Widget _buildKendalaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsi Kendala Pemeliharaan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _globalKendalaController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tuliskan alasan kendala atau hambatan pekerjaan...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Foto Dokumentasi Kendala',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final file = await FieldCameraWidget.takePhoto(
                    context: context,
                    title: 'Foto Kendala Pemeliharaan',
                  );
                  if (file != null && mounted) {
                    setState(() => _globalFotoKendala = file);
                  }
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _globalFotoKendala != null &&
                          _globalFotoKendala!.existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_globalFotoKendala!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.camera_alt_outlined,
                                size: 36, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              'Ambil Foto Kendala',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTerlaksanaTab(
    List<RincianPemeliharaanItem> rincianItems,
    int completedCount,
    double progressPercent,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rincianItems.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          // Banner Fokus Utama
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.build_circle_outlined,
                            size: 18,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Pengerjaan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '${rincianItems.length} komponen target pemeliharaan',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        '$completedCount / ${rincianItems.length} Selesai',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  progressPercent >= 1.0
                      ? '✓ Semua target pemeliharaan telah didokumentasikan lengkap!'
                      : 'Lengkapi foto sebelum, proses, dan sesudah untuk setiap target di bawah ini.',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final itemIndex = index - 1;
        final item = rincianItems[itemIndex];
        final isTerlaksana = item.status == 'TERLAKSANA';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Kartu
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.sub.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            if (item.fasa != null && item.fasa!.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Fasa ${item.fasa}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.komponen,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Temuan Awal Pill with Popup Trigger
                  GestureDetector(
                    onTap: () => _showConditionDetailPopup(item),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Temuan Awal',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.nilaiAwal ?? 'Temuan',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.info_outline,
                                size: 12,
                                color: Colors.red.shade700,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Status Pelaksanaan Switcher
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final updated = item.copyWith(
                          status: 'TERLAKSANA',
                          kondisiSesudah: 'Baik',
                        );
                        context
                            .read<PemeliharaanFormCubit>()
                            .updateRincianItem(itemIndex, updated);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isTerlaksana
                              ? const Color(0xFFECFDF5)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isTerlaksana
                                ? const Color(0xFFA7F3D0)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: isTerlaksana
                                  ? const Color(0xFF059669)
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Terlaksana',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isTerlaksana
                                    ? const Color(0xFF047857)
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final updated = item.copyWith(status: 'KENDALA');
                        context
                            .read<PemeliharaanFormCubit>()
                            .updateRincianItem(itemIndex, updated);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isTerlaksana
                              ? Colors.red.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: !isTerlaksana
                                ? Colors.red.shade200
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: !isTerlaksana
                                  ? Colors.red.shade700
                                  : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kendala',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: !isTerlaksana
                                    ? Colors.red.shade700
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Jika TERLAKSANA: Kondisi Sesudah Perbaikan
              if (isTerlaksana) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kondisi Baru:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Text(
                          item.kondisiSesudah ?? 'Baik',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Jika KENDALA: Input Alasan Kendala
              if (!isTerlaksana) ...[
                TextFormField(
                  initialValue: item.kendala,
                  onChanged: (text) {
                    final updated = item.copyWith(kendala: text);
                    context
                        .read<PemeliharaanFormCubit>()
                        .updateRincianItem(itemIndex, updated);
                  },
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Alasan Kendala Komponen *',
                    hintText: 'Tuliskan penyebab kendala...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 3 Photo Thumbnails (Sebelum, Proses, Sesudah)
              const Text(
                'Dokumentasi Foto Pekerjaan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildPhotoSlot(
                      label: 'Sebelum *',
                      file: item.fotoSebelum,
                      onTake: () => _takePhoto(itemIndex, 'Sebelum', item),
                      onPreview: item.fotoSebelum != null
                          ? () => _openLightbox(
                                file: item.fotoSebelum,
                                title: 'Foto Sebelum - ${item.komponen}',
                              )
                          : null,
                    ),
                  ),
                  if (isTerlaksana) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPhotoSlot(
                        label: 'Proses *',
                        file: item.fotoProses,
                        onTake: () => _takePhoto(itemIndex, 'Proses', item),
                        onPreview: item.fotoProses != null
                            ? () => _openLightbox(
                                  file: item.fotoProses,
                                  title: 'Foto Proses - ${item.komponen}',
                                )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildPhotoSlot(
                        label: 'Sesudah *',
                        file: item.fotoSesudah,
                        onTake: () => _takePhoto(itemIndex, 'Sesudah', item),
                        onPreview: item.fotoSesudah != null
                            ? () => _openLightbox(
                                  file: item.fotoSesudah,
                                  title: 'Foto Sesudah - ${item.komponen}',
                                )
                            : null,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoSlot({
    required String label,
    required File? file,
    required VoidCallback onTake,
    VoidCallback? onPreview,
  }) {
    final hasFile = file != null && file.existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: hasFile ? onPreview : onTake,
          child: Container(
            height: 85,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasFile ? const Color(0xFF10B981) : Colors.grey.shade300,
                width: hasFile ? 1.5 : 1,
              ),
            ),
            child: hasFile
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: Image.file(file, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined,
                          size: 20, color: Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasFile) ...[
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              InkWell(
                onTap: onTake,
                child: const Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
