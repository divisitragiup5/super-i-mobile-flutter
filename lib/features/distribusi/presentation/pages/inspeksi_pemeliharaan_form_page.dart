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

  @override
  void initState() {
    super.initState();
    _workOrderId = int.tryParse(widget.params['workOrderId']?.toString() ?? '0') ?? 0;
    _workOrderSutmItemId = int.tryParse(widget.params['workOrderSutmItemId']?.toString() ?? '0') ?? 0;
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

  void _takePhoto(int index, String type, RincianPemeliharaanItem item) async {
    final file = await FieldCameraWidget.takePhoto(
      context: context,
      title: 'Foto $type - ${item.komponen}',
    );

    if (file != null && mounted) {
      final updated = RincianPemeliharaanItem(
        rencanaId: item.rencanaId,
        sub: item.sub,
        komponen: item.komponen,
        fasa: item.fasa,
        status: item.status,
        jumlah: item.jumlah,
        kendala: item.kendala,
        fotoSebelum: type == 'Sebelum' ? file : item.fotoSebelum,
        fotoProses: type == 'Proses' ? file : item.fotoProses,
        fotoSesudah: type == 'Sesudah' ? file : item.fotoSesudah,
      );
      context.read<PemeliharaanFormCubit>().updateRincianItem(index, updated);
    }
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

                return Column(
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primary.withValues(alpha: 0.95),
                      child: Row(
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
                              '${rincianItems.length} Rencana',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Scrollable Items Form
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: rincianItems.length,
                        itemBuilder: (context, index) {
                          final item = rincianItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.sub} - ${item.komponen}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (item.fasa != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Fasa ${item.fasa}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Status Switcher
                                Row(
                                  children: [
                                    Expanded(
                                      child: ChoiceChip(
                                        label: const Center(
                                            child: Text('Terlaksana')),
                                        selected:
                                            item.status == 'TERLAKSANA',
                                        selectedColor:
                                            AppColors.success.withValues(alpha: 0.2),
                                        onSelected: (selected) {
                                          if (selected) {
                                            final updated = RincianPemeliharaanItem(
                                              rencanaId: item.rencanaId,
                                              sub: item.sub,
                                              komponen: item.komponen,
                                              fasa: item.fasa,
                                              status: 'TERLAKSANA',
                                              jumlah: item.jumlah,
                                              fotoSebelum: item.fotoSebelum,
                                              fotoProses: item.fotoProses,
                                              fotoSesudah: item.fotoSesudah,
                                            );
                                            context
                                                .read<PemeliharaanFormCubit>()
                                                .updateRincianItem(
                                                    index, updated);
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ChoiceChip(
                                        label:
                                            const Center(child: Text('Kendala')),
                                        selected: item.status == 'KENDALA',
                                        selectedColor:
                                            AppColors.error.withValues(alpha: 0.2),
                                        onSelected: (selected) {
                                          if (selected) {
                                            final updated = RincianPemeliharaanItem(
                                              rencanaId: item.rencanaId,
                                              sub: item.sub,
                                              komponen: item.komponen,
                                              fasa: item.fasa,
                                              status: 'KENDALA',
                                              jumlah: item.jumlah,
                                              fotoSebelum: item.fotoSebelum,
                                              fotoProses: item.fotoProses,
                                              fotoSesudah: item.fotoSesudah,
                                            );
                                            context
                                                .read<PemeliharaanFormCubit>()
                                                .updateRincianItem(
                                                    index, updated);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // 3 Photo Capture Slots (Sebelum, Proses, Sesudah)
                                const Text(
                                  'Dokumentasi Foto Pekerjaan',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPhotoThumb(
                                        label: 'Sebelum',
                                        file: item.fotoSebelum,
                                        onTap: () => _takePhoto(
                                            index, 'Sebelum', item),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildPhotoThumb(
                                        label: 'Proses',
                                        file: item.fotoProses,
                                        onTap: () => _takePhoto(
                                            index, 'Proses', item),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildPhotoThumb(
                                        label: 'Sesudah',
                                        file: item.fotoSesudah,
                                        onTap: () => _takePhoto(
                                            index, 'Sesudah', item),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Submit Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
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
                            context
                                .read<PemeliharaanFormCubit>()
                                .submitPemeliharaan(
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

  Widget _buildPhotoThumb({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: file != null && file.existsSync()
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
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
    );
  }
}
