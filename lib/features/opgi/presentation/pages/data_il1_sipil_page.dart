import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/input_container.dart';
import '../../data/models/opgi_il1_model.dart';
import '../cubit/opgi_il1_cubit.dart';

class DataIl1SipilPage extends StatefulWidget {
  final int id; // sipilId
  final String nama;
  final String gedung;
  final String garduInduk;
  final String status;

  const DataIl1SipilPage({
    super.key,
    required this.id,
    required this.nama,
    required this.gedung,
    required this.garduInduk,
    required this.status,
  });

  @override
  State<DataIl1SipilPage> createState() => _DataIl1SipilPageState();
}

class _DataIl1SipilPageState extends State<DataIl1SipilPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch({bool force = false}) {
    context.read<OpgiIl1Cubit>().loadSipilToday(widget.id, forceRefresh: force);
  }

  String? _getPhotoUri(Map<String, dynamic>? photoMap) {
    if (photoMap == null) return null;
    return photoMap['uri']?.toString() ?? photoMap['path']?.toString();
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;
    final resolvedUrl = AppUrlUtils.getFullImageUrl(imageUrl);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  resolvedUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Text('Gagal memuat gambar'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDelete(Il1SipilTodayDetailModel data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text('Apakah Anda yakin ingin menghapus data IL1 Sipil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OpgiIl1Cubit>().deleteSipil(data.id, sipilId: widget.id);
              context.pop();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 3),
          Text(
            value != null && value.isNotEmpty ? value : '-',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data IL1 Sipil - ${widget.gedung}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiIl1Cubit, OpgiIl1State>(
          listener: (context, state) {
            if (state is OpgiIl1Error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<OpgiIl1Cubit>();
            final data = cubit.cachedSipilToday;

            if (state is OpgiIl1Loading && data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final fotoBuktiUri = _getPhotoUri(data?.fotoBuktiInspeksi);

            return RefreshIndicator(
              onRefresh: () async => _fetch(force: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  // 1. INFO CARD
                  InputContainer(
                    label: 'INFO',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldRow('Gardu Induk', widget.garduInduk),
                        _buildFieldRow('Gedung', widget.gedung),
                        _buildFieldRow('Ruangan', widget.nama),
                        _buildFieldRow('Status', data?.status ?? widget.status),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: data == null
                                    ? null
                                    : () {
                                        context.push(
                                          AppRoutes.updateIl1Sipil,
                                          extra: {
                                            'id': widget.id,
                                            'nama': widget.nama,
                                            'gedung': widget.gedung,
                                            'data': data.toJson(),
                                          },
                                        ).then((_) => _fetch(force: true));
                                      },
                                child: const Text('Update', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.all(12),
                              ),
                              icon: const Icon(Icons.delete_outline),
                              onPressed: data == null ? null : () => _handleDelete(data),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (data == null)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Tidak ada data inspeksi hari ini'),
                      ),
                    )
                  else ...[
                    // 2. BUKTI INSPEKSI
                    InputContainer(
                      label: 'BUKTI INSPEKSI',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Foto Bukti Inspeksi', style: TextStyle(color: Colors.grey, fontSize: 13)),
                          const SizedBox(height: 8),
                          if (fotoBuktiUri != null && fotoBuktiUri.isNotEmpty)
                            InkWell(
                              onTap: () => _showImagePreview(context, fotoBuktiUri),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  AppUrlUtils.getFullImageUrl(fotoBuktiUri),
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: const Center(child: Text('Gagal memuat foto')),
                                  ),
                                ),
                              ),
                            )
                          else
                            const Text('-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. LAMPU PENERANGAN
                    InputContainer(
                      label: 'LAMPU PENERANGAN',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kondisi Lampu Penerangan', data.kondisiLampuPenerangan),
                          _buildFieldRow('Jenis Lampu Penerangan', data.jenisLampuPenerangan),
                          _buildFieldRow('Jumlah Lampu Penerangan', '${data.jumlahLampuPenerangan ?? 0}'),
                          _buildFieldRow('Jumlah Lampu Penerangan Mati', '${data.jumlahLampuPeneranganMati ?? 0}'),
                          _buildFieldRow('Keterangan Lampu Penerangan', data.keteranganLampuPenerangan),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. AIR CONDITIONER
                    InputContainer(
                      label: 'AIR CONDITIONER',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kondisi Ruangan', data.kondisiRuangan),
                          _buildFieldRow('Jumlah AC', '${data.jumlahAC ?? 0}'),
                          _buildFieldRow('Jumlah AC Menyala Normal', '${data.jumlahACMenyalaNormal ?? 0}'),
                          _buildFieldRow('Jumlah AC Hanya Keluar Angin', '${data.jumlahACWindOnly ?? 0}'),
                          _buildFieldRow('Jumlah AC Menetes/Bocor', '${data.jumlahACBocor ?? 0}'),
                          _buildFieldRow('Jumlah AC Rusak', '${data.jumlahACRusak ?? 0}'),
                          _buildFieldRow('Keterangan AC', data.keteranganAc),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. KEBOCORAN ATAP
                    InputContainer(
                      label: 'KEBOCORAN ATAP',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kondisi Atap', data.kondisiAtap),
                          if (data.letakKebocoranAtap != null && data.letakKebocoranAtap!.isNotEmpty)
                            _buildFieldRow('Letak Kebocoran Atap', data.letakKebocoranAtap),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. COMPARTMEN MAINHOLE/BASEMENT
                    InputContainer(
                      label: 'COMPARTMEN MAINHOLE/BASEMENT',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Tergenang Air', data.mainholeTergenangAir),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. POWER SUPPLY AC
                    InputContainer(
                      label: 'POWER SUPPLY AC',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Power Supply AC', data.powerSupplyAC),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. POWER SUPPLY DC
                    InputContainer(
                      label: 'POWER SUPPLY DC',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kebersihan Panel DCBC', data.kebersihanPanelDCBC),
                          _buildFieldRow('Kebersihan Ruang Baterai', data.kebersihanRuangBaterai),
                          _buildFieldRow('Suhu Ruang Baterai', '${data.suhuRuangBaterai ?? 0} °C'),
                          _buildFieldRow('Kelembaban Ruang Baterai', '${data.kelembabanRuangBaterai ?? 0} %'),
                          _buildFieldRow('Kebersihan Baterai', data.kebersihanBaterai),
                          _buildFieldRow('Kebocoran Baterai', data.kebocoranBaterai),
                          _buildFieldRow('Exhaust Fan', data.exhaustFan),
                          _buildFieldRow('Kondisi Ruang Baterai', data.kondisiRuangBaterai),
                          _buildFieldRow('Tegangan Beban', '${data.teganganBeban ?? 0.0} V'),
                          _buildFieldRow('Arus Beban', '${data.arusBeban ?? 0.0} A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 9. RECTIFIER 110 V
                    InputContainer(
                      label: 'RECTIFIER 110 V',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kondisi Rectifier', data.kondisiRectifier),
                          _buildFieldRow('Kebersihan Ruang Rectifier', data.kebersihanRuangRectifier),
                          _buildFieldRow('Suhu Ruang Rectifier', '${data.suhuRuangRectifier ?? 0} °C'),
                          _buildFieldRow('Kelembaban Ruang Rectifier', '${data.kelembabanRuangRectifier ?? 0} %'),
                          _buildFieldRow('Kebersihan Panel', data.kebersihanPanel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 10. PERALATAN KOMPUTER DAN KOMUNIKASI
                    InputContainer(
                      label: 'PERALATAN KOMPUTER DAN KOMUNIKASI',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kondisi MMI', data.kondisiMMI),
                          _buildFieldRow('Kondisi Mouse Komputer', data.kondisiMouseKomputer),
                          _buildFieldRow('Kondisi Keyboard Komputer', data.kondisiKeyboardKomputer),
                          _buildFieldRow('Kondisi Internet', data.kondisiInternet),
                          _buildFieldRow('Kondisi Radio', data.kondisiRadio),
                          _buildFieldRow('Kondisi Yealink', data.kondisiYealink),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
