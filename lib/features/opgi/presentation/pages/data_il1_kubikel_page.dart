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

class DataIl1KubikelPage extends StatefulWidget {
  final int id; // penyulangId
  final String nama;
  final String garduInduk;
  final int garduIndukId;
  final String status;

  const DataIl1KubikelPage({
    super.key,
    required this.id,
    required this.nama,
    required this.garduInduk,
    required this.garduIndukId,
    required this.status,
  });

  @override
  State<DataIl1KubikelPage> createState() => _DataIl1KubikelPageState();
}

class _DataIl1KubikelPageState extends State<DataIl1KubikelPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch({bool force = false}) {
    context.read<OpgiIl1Cubit>().loadKubikelToday(widget.id, forceRefresh: force);
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

  void _handleDelete(Il1KubikelTodayDetailModel data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Peringatan'),
        content: const Text('Apakah Anda yakin ingin menghapus data IL1 Kubikel?'),
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
              context.read<OpgiIl1Cubit>().deleteKubikel(data.id, penyulangId: widget.id);
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
        title: Text('Data IL1 Kubikel - ${widget.nama}'),
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
            final data = cubit.cachedKubikelToday;

            if (state is OpgiIl1Loading && data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final fotoBuktiUri = _getPhotoUri(data?.fotoBuktiInspeksi);
            final fotoAnomaliUri = _getPhotoUri(data?.fotoAnomali);

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
                        _buildFieldRow('Rel', widget.nama),
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
                                          AppRoutes.updateIl1Kubikel,
                                          extra: {
                                            'id': data.id,
                                            'nama': widget.nama,
                                            'garduInduk': widget.garduInduk,
                                            'garduIndukId': widget.garduIndukId,
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

                    // 3. KONDISI PMT
                    InputContainer(
                      label: 'KONDISI PMT',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Close/Open', data.statusPMT),
                          _buildFieldRow('Rack In/Rack Out', data.rackPMT),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Keterangan PMT', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 4),
                                if (data.keteranganPMT.isNotEmpty)
                                  ...data.keteranganPMT.map((k) => Text('• $k', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)))
                                else
                                  const Text('-'),
                              ],
                            ),
                          ),
                          _buildFieldRow('Kondisi SF6', data.kondisiSF6PMT),
                          _buildFieldRow('Indikator Pegas Mekanik PMT', data.indikatorPegasMekanikPMT),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. VISUAL MVCELL
                    InputContainer(
                      label: 'VISUAL MVCELL',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Benda Asing', data.bendaAsing),
                          _buildFieldRow('Binatang', data.binatang),
                          _buildFieldRow('Tetesan Air', data.tetesanAir),
                          _buildFieldRow('Bunyi-bunyian/Desis', data.desis),
                          _buildFieldRow('Bau-bauan', data.bau),
                          _buildFieldRow('Kondisi LV Panel', data.kondisiLVPanel),
                          _buildFieldRow('Lampu LV Panel', data.lampuLVPanel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. INDIKATOR MVCELL
                    InputContainer(
                      label: 'INDIKATOR MVCELL',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Indikator PMT Close', data.indikatorPMTClose),
                          _buildFieldRow('Indikator PMT Open', data.indikatorPMTOpen),
                          _buildFieldRow('Indikator Tegangan Kubikel', data.indikatorTeganganKubikel),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. RELAY OCR
                    InputContainer(
                      label: 'RELAY OCR',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Tampilan LCD', data.tampilanLCDRelayOCR),
                          _buildFieldRow('Indikator Healthy', data.indikatorHealthyRelayOCR),
                          _buildFieldRow('Pembacaan Arus Netral', '${data.pembacaanArusNetralRelayOCR ?? 0.0} A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 7. RELAY UFR
                    InputContainer(
                      label: 'RELAY UFR',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Keterangan Relay UFR', data.keteranganRelayUFR),
                          if (data.keteranganRelayUFR == 'ADA') ...[
                            _buildFieldRow('Tampilan LCD', data.tampilanLCDRelayUFR),
                            _buildFieldRow('Pembacaan Tegangan', '${data.pembacaanTeganganRelayUFR ?? 0.0} V'),
                            _buildFieldRow('Selector UFR', '${data.selectorUFR ?? 0}'),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 8. KWH METER
                    InputContainer(
                      label: 'KWH METER',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Tampilan LCD', data.tampilanLCDKWHMeter),
                          _buildFieldRow('Tombol KWh Meter', data.tombolKWHMeter),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 9. ALARM CELL
                    InputContainer(
                      label: 'ALARM CELL',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Kondisi Alarm', data.kondisiAlarm),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 10. ANOMALI
                    InputContainer(
                      label: 'ANOMALI',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldRow('Keterangan Anomali', data.keteranganAnomali),
                          if (data.keteranganAnomali == 'ADA') ...[
                            _buildFieldRow('Anomali', data.anomali),
                            const SizedBox(height: 8),
                            if (fotoAnomaliUri != null && fotoAnomaliUri.isNotEmpty)
                              InkWell(
                                onTap: () => _showImagePreview(context, fotoAnomaliUri),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    AppUrlUtils.getFullImageUrl(fotoAnomaliUri),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      height: 120,
                                      color: Colors.grey.shade200,
                                      child: const Center(child: Text('Gagal memuat foto anomali')),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
