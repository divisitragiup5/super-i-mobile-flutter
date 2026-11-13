import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/google_sutm_map_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';

class DetailSutmPemeliharaanPage extends StatefulWidget {
  final SutmItemModel item;

  const DetailSutmPemeliharaanPage({super.key, required this.item});

  @override
  State<DetailSutmPemeliharaanPage> createState() =>
      _DetailSutmPemeliharaanPageState();
}

class _DetailSutmPemeliharaanPageState
    extends State<DetailSutmPemeliharaanPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = context.read<SutmRepository>();
    final result = await repo
        .getRiwayatPemeliharaanDetail(widget.item.id.toString());

    result.fold(
      (failure) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        }
      },
      (data) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _detailData = data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : data;
          });
        }
      },
    );
  }

  List<String> _getUserRoles(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.roles;
    }
    return [];
  }

  String _getRolePath(List<String> roles) {
    if (roles.any((r) => r.toUpperCase().contains('UP3'))) return 'up3';
    if (roles.any((r) => r.toUpperCase().contains('ULP'))) return 'ulp';
    return 'koordinator';
  }

  String _getRoleLabel(List<String> roles) {
    if (roles.any((r) => r.toUpperCase().contains('UP3'))) return 'UP3';
    if (roles.any((r) => r.toUpperCase().contains('ULP'))) return 'ULP';
    return 'Koordinator';
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('d MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void _showImageLightbox(String imageUrl, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey.shade900,
                  alignment: Alignment.center,
                  child: const Text('Gagal memuat foto',
                      style: TextStyle(color: Colors.white70)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(int visitId, List<String> roles) {
    final rolePath = _getRolePath(roles);
    final roleLabel = _getRoleLabel(roles);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF059669), size: 22),
            const SizedBox(width: 8),
            const Text(
              'Konfirmasi Approve',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menyetujui laporan pemeliharaan ini sebagai $roleLabel?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = context.read<SutmRepository>();
              final result = await repo.approvePemeliharaan(
                role: rolePath,
                id: visitId,
              );
              result.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(f.message),
                    backgroundColor: Colors.red,
                  ),
                ),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan pemeliharaan berhasil disetujui.'),
                      backgroundColor: Color(0xFF059669),
                    ),
                  );
                  _fetchDetail();
                },
              );
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(int visitId, List<String> roles) {
    final rolePath = _getRolePath(roles);
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFDC2626), size: 22),
            const SizedBox(width: 8),
            const Text(
              'Reject Pemeliharaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan alasan penolakan hasil pemeliharaan:',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Alasan penolakan...',
                hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan wajib diisi'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              final repo = context.read<SutmRepository>();
              final result = await repo.rejectPemeliharaan(
                role: rolePath,
                id: visitId,
                reason: reason,
              );
              result.fold(
                (f) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(f.message),
                    backgroundColor: Colors.red,
                  ),
                ),
                (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Laporan pemeliharaan berhasil ditolak.'),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  );
                  _fetchDetail();
                },
              );
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = _getUserRoles(context);
    final roleLabel = _getRoleLabel(roles);
    final item = widget.item;

    final progress = _detailData?['progress'] as Map<String, dynamic>?;
    final targetList = _detailData?['rencana'] as List<dynamic>? ?? [];
    final kunjunganList = _detailData?['kunjungan'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(item.nama),
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
          RefreshIndicator(
            onRefresh: _fetchDetail,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_errorMessage != null && _detailData == null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: _fetchDetail,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ],
                // Header Info SUTM Card
                Container(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.idAsset,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.nama,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.statusApproval ?? item.status,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Penyulang / Feeder',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                              Text(
                                item.feederName ?? item.penyulang ?? '-',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Tegangan',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey)),
                              Text(
                                item.tegangan ?? '20kV',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (item.latitude != null && item.longitude != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${item.latitude}, ${item.longitude}',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleSutmMapCard(
                            height: 160,
                            items: [
                              SutmMapItem(
                                idAsset: item.idAsset,
                                name: item.nama,
                                latitude: item.latitude!,
                                longitude: item.longitude!,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Review Banner if actionable
                if (item.canUserApprove(roles) && kunjunganList.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
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
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Review Hasil Pemeliharaan ($roleLabel)',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Laporan pengerjaan siap ditinjau. Anda dapat menyetujui atau menolak laporan ini.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFDC2626),
                                  side: const BorderSide(
                                      color: Color(0xFFDC2626)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  final visitId = kunjunganList.first['id'] as int? ?? item.id;
                                  _showRejectDialog(visitId, roles);
                                },
                                child: const Text('Reject',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  final visitId = kunjunganList.first['id'] as int? ?? item.id;
                                  _showApproveDialog(visitId, roles);
                                },
                                child: const Text('Approve',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Realisasi Progress Card
                if (progress != null) ...[
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress Realisasi Pemeliharaan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${progress['persenTervalidasi'] ?? 0}% Selesai',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ((progress['persenTervalidasi'] ?? 0) as num)
                                    .toDouble() /
                                100.0,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.green),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildProgressBox('Target', progress['target'] ?? 0,
                                Colors.grey.shade700),
                            _buildProgressBox('Dilaporkan',
                                progress['dilaporkan'] ?? 0, Colors.blue),
                            _buildProgressBox('Tervalidasi',
                                progress['tervalidasi'] ?? 0, Colors.green),
                            _buildProgressBox('Kendala',
                                progress['kendala'] ?? 0, Colors.red),
                            _buildProgressBox(
                                'Sisa', progress['sisa'] ?? 0, Colors.amber),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Target Rencana Komponen
                if (targetList.isNotEmpty) ...[
                  Container(
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Target Rencana Komponen',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${targetList.length} komponen',
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...targetList.map((rec) {
                          final recMap = rec as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            (recMap['sub'] ?? 'KOMPONEN')
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          if (recMap['fasa'] != null) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                'Fasa ${recMap['fasa']}',
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
                                      const SizedBox(height: 3),
                                      Text(
                                        recMap['komponen'] ?? '-',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      if (recMap['nilai'] != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Masalah: ${recMap['nilai']}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    '${recMap['jumlah'] ?? 1} unit',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // Riwayat Kunjungan Accordions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Riwayat Kunjungan (${kunjunganList.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (kunjunganList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Belum ada riwayat kunjungan pemeliharaan',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                else
                  ...kunjunganList.map((kunj) {
                    final Map<String, dynamic> kjg =
                        kunj as Map<String, dynamic>;
                    return _buildKunjunganAccordion(kjg, targetList, roles);
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBox(String label, dynamic count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 9, color: color)),
          const SizedBox(height: 2),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKunjunganAccordion(
    Map<String, dynamic> kunj,
    List<dynamic> targetList,
    List<String> roles,
  ) {
    final status = kunj['status']?.toString() ?? 'OPEN';
    final pelaksanaan = kunj['pelaksanaan']?.toString() ?? 'TERLAKSANA';
    final isKendala = pelaksanaan == 'KENDALA';
    final inspector = kunj['inspector'] as Map<String, dynamic>?;
    final rincianList = kunj['rincianWO'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isKendala
                        ? const Color(0xFFFEE2E2)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isKendala ? 'KENDALA' : 'TERLAKSANA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isKendala
                          ? const Color(0xFFB91C1C)
                          : const Color(0xFF047857),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(kunj['startTime']?.toString()),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Petugas: ${inspector?['namaLengkap'] ?? '-'}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        subtitle: (kunj['rejectedReason'] != null)
            ? Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Alasan Penolakan: "${kunj['rejectedReason']}"',
                  style: const TextStyle(fontSize: 11, color: Color(0xFFB91C1C)),
                ),
              )
            : null,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Approval Trail
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildApprovalRow(
                        'Koordinator',
                        kunj['approvalKoordinatorAt'],
                        status.contains('REJECTED_BY_KOORDINATOR'),
                      ),
                      const SizedBox(height: 8),
                      _buildApprovalRow(
                        'PLN ULP',
                        kunj['approvalULPAt'],
                        status.contains('REJECTED_BY_ULP'),
                      ),
                      const SizedBox(height: 8),
                      _buildApprovalRow(
                        'PLN UP3',
                        kunj['approvalUP3At'],
                        status.contains('REJECTED_BY_UP3'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Content
                if (isKendala) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Laporan Kendala:',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB91C1C)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kunj['kendala'] ?? 'Tidak ada keterangan kendala',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  if (kunj['fotoKendala'] != null) ...[
                    const SizedBox(height: 10),
                    const Text('Foto Bukti Kendala',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () => _showImageLightbox(
                          kunj['fotoKendala'], 'Foto Bukti Kendala'),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          kunj['fotoKendala'],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.broken_image,
                                color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  ...rincianList.map((rincian) {
                    final rMap = rincian as Map<String, dynamic>;
                    final target = targetList.firstWhere(
                      (t) => (t as Map<String, dynamic>)['id'] == rMap['rencanaId'],
                      orElse: () => <String, dynamic>{},
                    ) as Map<String, dynamic>;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
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
                                target['komponen'] ?? 'Komponen',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '${rMap['jumlah'] ?? 1} unit',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildPhotoThumbnail(
                                'Sebelum',
                                rMap['fotoSebelumUrl']?.toString(),
                              ),
                              const SizedBox(width: 8),
                              _buildPhotoThumbnail(
                                'Proses',
                                rMap['fotoProsesUrl']?.toString(),
                              ),
                              const SizedBox(width: 8),
                              _buildPhotoThumbnail(
                                'Sesudah',
                                rMap['fotoSesudahUrl']?.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalRow(String title, dynamic approvedAt, bool isRejected) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              isRejected
                  ? Icons.cancel
                  : approvedAt != null
                      ? Icons.check_circle
                      : Icons.access_time,
              size: 16,
              color: isRejected
                  ? Colors.red
                  : approvedAt != null
                      ? Colors.green
                      : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
        Text(
          isRejected
              ? 'Ditolak'
              : approvedAt != null
                  ? _formatDate(approvedAt.toString())
                  : 'Menunggu',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isRejected
                ? Colors.red
                : approvedAt != null
                    ? Colors.green
                    : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(String label, String? url) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 9, color: Colors.grey)),
          const SizedBox(height: 4),
          InkWell(
            onTap: url != null ? () => _showImageLightbox(url, label) : null,
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: url != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, st) => const Icon(
                            Icons.broken_image,
                            size: 20,
                            color: Colors.grey),
                      ),
                    )
                  : const Center(
                      child: Text('Tidak ada',
                          style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
