import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/sutm_workorder_model.dart';
import '../../domain/repositories/sutm_repository.dart';
import '../cubit/wo_pemeliharaan_cubit.dart';
import '../widgets/sutm_bar_chart_widget.dart';

class RiwayatPemeliharaanPage extends StatefulWidget {
  const RiwayatPemeliharaanPage({super.key});

  @override
  State<RiwayatPemeliharaanPage> createState() =>
      _RiwayatPemeliharaanPageState();
}

class _RiwayatPemeliharaanPageState extends State<RiwayatPemeliharaanPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _activeTab = 'workorder'; // 'workorder' | 'sutm'
  String? _selectedStatus;
  List<SutmBarChartDataPoint> _chartData = [];
  bool _isLoadingChart = false;

  @override
  void initState() {
    super.initState();
    _fetchChart();
    context.read<WoPemeliharaanCubit>().fetchList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchChart() async {
    setState(() => _isLoadingChart = true);
    final repo = context.read<SutmRepository>();
    final result = await repo.getRiwayatPemeliharaanChart();
    if (mounted) {
      result.fold(
        (_) => setState(() => _isLoadingChart = false),
        (rawList) {
          final points = rawList
              .map((item) =>
                  SutmBarChartDataPoint.fromJson(item as Map<String, dynamic>))
              .toList();
          setState(() {
            _chartData = points;
            _isLoadingChart = false;
          });
        },
      );
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<WoPemeliharaanCubit>().fetchList();
      }
    });
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

  Color _getStatusBg(String status) {
    final st = status.toUpperCase();
    if (st.contains('COMPLETED') || st.contains('SELESAI')) {
      return const Color(0xFFECFDF5);
    }
    if (st.contains('REJECT')) {
      return const Color(0xFFFEE2E2);
    }
    if (st.contains('PROGRESS')) {
      return const Color(0xFFFEF3C7);
    }
    return const Color(0xFFEFF6FF);
  }

  Color _getStatusText(String status) {
    final st = status.toUpperCase();
    if (st.contains('COMPLETED') || st.contains('SELESAI')) {
      return const Color(0xFF047857);
    }
    if (st.contains('REJECT')) {
      return const Color(0xFFB91C1C);
    }
    if (st.contains('PROGRESS')) {
      return const Color(0xFFB45309);
    }
    return const Color(0xFF1D4ED8);
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final statuses = [
              'Semua',
              'OPEN',
              'ON PROGRESS',
              'WAITING APPROVAL',
              'COMPLETED',
              'REJECTED',
            ];

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Riwayat Pemeliharaan',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Status Pekerjaan',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: statuses.map((st) {
                      final isSelected = (st == 'Semua' &&
                              _selectedStatus == null) ||
                          _selectedStatus == st;
                      return ChoiceChip(
                        label: Text(st),
                        selected: isSelected,
                        onSelected: (val) {
                          setSheetState(() {
                            setState(() {
                              _selectedStatus = st == 'Semua' ? null : st;
                            });
                          });
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<WoPemeliharaanCubit>().fetchList();
                      },
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeliharaan SUTM'),
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
            onRefresh: () async {
              await Future.wait([
                _fetchChart(),
                context.read<WoPemeliharaanCubit>().fetchList(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Chart Card
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
                      const Text(
                        'Statistik Pemeliharaan SUTM',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Perbandingan target & realisasi bulanan',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 14),
                      if (_isLoadingChart)
                        const SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary),
                          ),
                        )
                      else
                        SutmBarChartWidget(data: _chartData, height: 180),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

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
                          onTap: () => setState(() => _activeTab = 'workorder'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == 'workorder'
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
                                color: _activeTab == 'workorder'
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _activeTab = 'sutm'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == 'sutm'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'SUTM',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 'sutm'
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

                // Search Bar with Filter Button
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
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
                                    hintText: _activeTab == 'workorder'
                                        ? 'Cari nama work order...'
                                        : 'Cari nama SUTM...',
                                    hintStyle: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        const EdgeInsets.symmetric(vertical: 10),
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
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _showFilterSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _selectedStatus != null
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedStatus != null
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 18,
                            color: _selectedStatus != null
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Content List
                BlocBuilder<WoPemeliharaanCubit, WoPemeliharaanState>(
                  builder: (context, state) {
                    if (state is WoPemeliharaanLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        ),
                      );
                    }

                    if (state is WoPemeliharaanError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      );
                    }

                    final allWorkOrders = state is WoPemeliharaanLoaded
                        ? state.allWorkOrders
                        : <SutmWorkOrderItem>[];

                    final searchQ = _searchController.text.trim().toLowerCase();
                    final filteredWo = allWorkOrders.where((wo) {
                      if (_selectedStatus != null &&
                          !wo.status
                              .toUpperCase()
                              .contains(_selectedStatus!.toUpperCase())) {
                        return false;
                      }
                      if (searchQ.isNotEmpty) {
                        final title = (wo.title ?? '').toLowerCase();
                        final idStr = wo.id.toString();
                        if (!title.contains(searchQ) && !idStr.contains(searchQ)) {
                          return false;
                        }
                      }
                      return true;
                    }).toList();

                    if (_activeTab == 'workorder') {
                      if (filteredWo.isEmpty) {
                        return _buildEmptyState(
                            'Tidak ada riwayat work order pemeliharaan');
                      }
                      return Column(
                        children: filteredWo
                            .map((wo) => _buildWorkOrderCard(wo))
                            .toList(),
                      );
                    } else {
                      // SUTM Tab
                      final allSutm = filteredWo
                          .expand((wo) => wo.items)
                          .where((sutm) {
                        if (_selectedStatus != null &&
                            !sutm.status
                                .toUpperCase()
                                .contains(_selectedStatus!.toUpperCase())) {
                          return false;
                        }
                        if (searchQ.isNotEmpty) {
                          final name = sutm.nama.toLowerCase();
                          final idAsset = sutm.idAsset.toLowerCase();
                          if (!name.contains(searchQ) &&
                              !idAsset.contains(searchQ)) {
                            return false;
                          }
                        }
                        return true;
                      }).toList();

                      if (allSutm.isEmpty) {
                        return _buildEmptyState(
                            'Tidak ada riwayat SUTM pemeliharaan');
                      }
                      return Column(
                        children: allSutm
                            .map((sutm) => _buildSutmCard(sutm))
                            .toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.history, size: 44, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkOrderCard(SutmWorkOrderItem item) {
    final statusBg = _getStatusBg(item.status);
    final statusText = _getStatusText(item.status);

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
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusText,
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

  Widget _buildSutmCard(SutmItemModel item) {
    final statusBg = _getStatusBg(item.status);
    final statusText = _getStatusText(item.status);

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
            AppRoutes.detailSutmPemeliharaan,
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
                  Text(
                    item.idAsset,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.statusApproval ?? item.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.nama,
                style: const TextStyle(
                  fontSize: 13,
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
                          style: TextStyle(fontSize: 9, color: Colors.grey)),
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
                          style: TextStyle(fontSize: 9, color: Colors.grey)),
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
            ],
          ),
        ),
      ),
    );
  }
}
