import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../cubit/validasi_pemeliharaan_cubit.dart';

class ValidasiPemeliharaanPage extends StatefulWidget {
  const ValidasiPemeliharaanPage({super.key});

  @override
  State<ValidasiPemeliharaanPage> createState() =>
      _ValidasiPemeliharaanPageState();
}

class _ValidasiPemeliharaanPageState extends State<ValidasiPemeliharaanPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<ValidasiPemeliharaanCubit>().loadValidasiData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context
            .read<ValidasiPemeliharaanCubit>()
            .loadValidasiData(search: query.trim().isEmpty ? null : query.trim());
      }
    });
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
      return DateFormat('d MMM yyyy').format(dt);
    } catch (_) {
      return raw;
    }
  }

  void _showSingleApproveDialog(SutmItemModel item, List<String> roles) {
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
          'Apakah Anda yakin ingin menyetujui (Approve) hasil pemeliharaan untuk SUTM ${item.nama} sebagai $roleLabel?',
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
              final success = await context
                  .read<ValidasiPemeliharaanCubit>()
                  .approveSingle(role: rolePath, id: item.id);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Pemeliharaan ${item.nama} berhasil disetujui.'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showSingleRejectDialog(SutmItemModel item, List<String> roles) {
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
            Text(
              'Masukkan alasan penolakan hasil pemeliharaan SUTM ${item.nama}:',
              style: const TextStyle(fontSize: 13, color: Colors.black87),
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
              final success = await context
                  .read<ValidasiPemeliharaanCubit>()
                  .rejectSingle(
                    role: rolePath,
                    id: item.id,
                    reason: reason,
                  );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Pemeliharaan ${item.nama} berhasil ditolak.'),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _showBulkApproveDialog(List<String> roles, int count) {
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
            Text(
              'Approve $count SUTM Terpilih',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menyetujui (Approve) $count SUTM terpilih sebagai $roleLabel?',
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
              final success = await context
                  .read<ValidasiPemeliharaanCubit>()
                  .approveBulk(role: rolePath);
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count SUTM berhasil disetujui.'),
                    backgroundColor: const Color(0xFF059669),
                  ),
                );
              }
            },
            child: const Text('Approve Terpilih'),
          ),
        ],
      ),
    );
  }

  void _showBulkRejectDialog(List<String> roles, int count) {
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
            Text(
              'Reject $count SUTM Terpilih',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alasan Reject untuk Semua SUTM Terpilih *',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Masukkan alasan penolakan untuk seluruh item terpilih...',
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
              final success = await context
                  .read<ValidasiPemeliharaanCubit>()
                  .rejectBulk(
                    role: rolePath,
                    reason: reason,
                  );
              if (mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count SUTM berhasil ditolak.'),
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                );
              }
            },
            child: const Text('Reject Terpilih'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = _getUserRoles(context);
    final roleLabel = _getRoleLabel(roles);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validasi Pemeliharaan'),
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
          BlocConsumer<ValidasiPemeliharaanCubit, ValidasiPemeliharaanState>(
            listener: (context, state) {
              if (state is ValidasiPemeliharaanError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is ValidasiPemeliharaanLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (state is! ValidasiPemeliharaanLoaded) {
                return const SizedBox();
              }

              final approvableSutm = state.sutmItems
                  .where((item) => item.canUserApprove(roles))
                  .toList();
              final isAllSelected = approvableSutm.isNotEmpty &&
                  approvableSutm.every(
                      (item) => state.selectedSutmIds.contains(item.id));

              return Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await context
                            .read<ValidasiPemeliharaanCubit>()
                            .loadValidasiData(
                              search: _searchController.text.trim().isEmpty
                                  ? null
                                  : _searchController.text.trim(),
                            );
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Header Role Banner
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Menu Review Pemeliharaan ($roleLabel)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF064E3B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Menampilkan hasil pengerjaan pemeliharaan yang siap ditinjau dan disetujui.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF047857),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Tab Switcher
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    onTap: () => context
                                        .read<ValidasiPemeliharaanCubit>()
                                        .switchTab('workorder'),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: state.activeTab == 'workorder'
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Work Order',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: state.activeTab == 'workorder'
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => context
                                        .read<ValidasiPemeliharaanCubit>()
                                        .switchTab('sutm'),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: state.activeTab == 'sutm'
                                            ? AppColors.primary
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'SUTM (${approvableSutm.isNotEmpty ? '${approvableSutm.length} perlu review' : state.sutmItems.length})',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: state.activeTab == 'sutm'
                                              ? Colors.white
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Search Bar & Filter Badge
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search,
                                          size: 18, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          onChanged: _onSearchChanged,
                                          style: const TextStyle(fontSize: 13),
                                          decoration: InputDecoration(
                                            hintText: state.activeTab ==
                                                    'workorder'
                                                ? 'Cari nama work order...'
                                                : 'Cari nama SUTM / ID Asset...',
                                            hintStyle: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10),
                                          ),
                                        ),
                                      ),
                                      if (_searchController.text.isNotEmpty)
                                        InkWell(
                                          onTap: () {
                                            _searchController.clear();
                                            _onSearchChanged('');
                                          },
                                          child: const Icon(Icons.close,
                                              size: 18, color: Colors.grey),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFFDE68A)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF59E0B),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            'Filter: ON PROGRESS',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFB45309),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_searchController.text
                                        .trim()
                                        .isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Filter nama: "${_searchController.text.trim()}"',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Select All Header (Only in SUTM tab if reviewable items exist)
                          if (state.activeTab == 'sutm' &&
                              approvableSutm.isNotEmpty) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (isAllSelected) {
                                      context
                                          .read<ValidasiPemeliharaanCubit>()
                                          .clearSelection();
                                    } else {
                                      context
                                          .read<ValidasiPemeliharaanCubit>()
                                          .selectAll(roles);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isAllSelected
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          size: 18,
                                          color: isAllSelected
                                              ? AppColors.primary
                                              : Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isAllSelected
                                              ? 'Batal Pilih Semua'
                                              : 'Pilih Semua SUTM (${approvableSutm.length})',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (state.selectedSutmIds.isNotEmpty)
                                  Text(
                                    '${state.selectedSutmIds.length} dipilih',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Items List
                          if (state.activeTab == 'workorder') ...[
                            if (state.workOrders.isEmpty)
                              _buildEmptyState('Tidak ada work order yang perlu validasi')
                            else
                              ...state.workOrders.map((wo) => _buildWorkOrderCard(wo)),
                          ] else ...[
                            if (state.sutmItems.isEmpty)
                              _buildEmptyState('Tidak ada SUTM yang perlu validasi')
                            else
                              ...state.sutmItems.map((sutm) => _buildSutmCard(
                                    sutm,
                                    roles,
                                    state.selectedSutmIds.contains(sutm.id),
                                  )),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Floating Bulk Action Bar
                  if (state.activeTab == 'sutm' &&
                      state.selectedSutmIds.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${state.selectedSutmIds.length} SUTM Terpilih',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(
                                    color: Color(0xFFDC2626)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                              onPressed: () => _showBulkRejectDialog(
                                  roles, state.selectedSutmIds.length),
                              child: const Text('Reject Terpilih',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                              ),
                              onPressed: () => _showBulkApproveDialog(
                                  roles, state.selectedSutmIds.length),
                              child: const Text('Approve Terpilih',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_outlined,
              size: 44, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderCard(SutmWorkOrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.detailWorkorderPemeliharaanToday,
            extra: item,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WO-${item.id}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.title ?? 'Work Order Pemeliharaan',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (item.lintasan != null) ...[
                    const Icon(Icons.alt_route, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      item.lintasan!,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(item.startDate)} - ${_formatDate(item.endDate)}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSutmCard(
    SutmItemModel item,
    List<String> roles,
    bool isChecked,
  ) {
    final canApprove = item.canUserApprove(roles);
    final stageLabel = item.getApprovalStageLabel(roles);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked ? AppColors.primary : Colors.grey.shade100,
          width: isChecked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canApprove) ...[
                  InkWell(
                    onTap: () {
                      context
                          .read<ValidasiPemeliharaanCubit>()
                          .toggleSelectSutm(item.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8, top: 2),
                      child: Icon(
                        isChecked
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        color: isChecked ? AppColors.primary : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: InkWell(
                    onTap: () {
                      context.push(
                        AppRoutes.detailSutmPemeliharaan,
                        extra: item,
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.idAsset,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                if (canApprove)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: const Color(0xFFA7F3D0)),
                                    ),
                                    child: const Text(
                                      'Perlu Review',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047857),
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
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
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.nama,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Penyulang',
                                    style: TextStyle(
                                        fontSize: 9, color: Colors.grey)),
                                Text(
                                  item.feederName ?? item.penyulang ?? '-',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Tegangan',
                                    style: TextStyle(
                                        fontSize: 9, color: Colors.grey)),
                                Text(
                                  item.tegangan ?? '20kV',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (item.progressTarget != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Target: ${item.progressTarget}',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.black87),
                                ),
                                Text(
                                  'Dilaporkan: ${item.progressDilaporkan ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Tervalidasi: ${item.progressTervalidasi ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                if ((item.progressKendala ?? 0) > 0)
                                  Text(
                                    'Kendala: ${item.progressKendala}',
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            if (canApprove) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _showSingleRejectDialog(item, roles),
                      child: const Text('Reject',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _showSingleApproveDialog(item, roles),
                      child: const Text('Approve',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Status: $stageLabel',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
