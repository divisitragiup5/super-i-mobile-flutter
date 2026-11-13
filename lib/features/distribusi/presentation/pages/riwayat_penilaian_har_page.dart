import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/repositories/sutm_repository.dart';

class RiwayatPenilaianHarPage extends StatefulWidget {
  const RiwayatPenilaianHarPage({super.key});

  @override
  State<RiwayatPenilaianHarPage> createState() =>
      _RiwayatPenilaianHarPageState();
}

class _RiwayatPenilaianHarPageState extends State<RiwayatPenilaianHarPage> {
  bool _isLoading = true;
  List<dynamic> _items = [];
  String? _errorMessage;
  DateTime? _selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = context.read<SutmRepository>();
    final result = await repo.getPenilaianHistory(
      type: 'har',
      bulan: _selectedMonth != null ? _selectedMonth!.month - 1 : null,
      tahun: _selectedMonth?.year,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (data) {
        final list = (data['data'] is Map && data['data']['items'] is List)
            ? data['data']['items'] as List
            : (data['items'] is List ? data['items'] as List : []);

        setState(() {
          _isLoading = false;
          _items = list;
        });
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AMAN':
        return const Color(0xFF10B981);
      case 'SURAT TEGURAN':
        return Colors.orange.shade700;
      case 'SURAT PERINGATAN':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  void _selectMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      helpText: 'Pilih Bulan Penilaian',
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
      _fetchHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penilaian Pemeliharaan'),
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
            onRefresh: _fetchHistory,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Month Picker Filter Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month,
                              size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _selectedMonth != null
                                ? DateFormat('MMMM yyyy').format(_selectedMonth!)
                                : 'Semua Periode Bulan',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (_selectedMonth != null)
                            InkWell(
                              onTap: () {
                                setState(() => _selectedMonth = null);
                                _fetchHistory();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.close,
                                    size: 18, color: Colors.grey),
                              ),
                            ),
                          InkWell(
                            onTap: _selectMonth,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Ubah',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  )
                else if (_items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tidak ada riwayat penilaian ditemukan',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  )
                else
                  ..._items.map((entry) {
                    final eMap = entry as Map<String, dynamic>;
                    return _buildPenilaianCard(eMap);
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenilaianCard(Map<String, dynamic> item) {
    final bulanStr = item['bulanString'] ?? 'Bulan Penilaian';
    final perTanggal = item['perTanggal'] ?? '-';
    final status = (item['status'] ?? 'AMAN').toString();

    final nilaiKinerja = (item['nilaiKinerja'] as num?)?.toDouble() ?? 0.0;
    final pointDurasi = (item['pointDurasi'] as num?)?.toDouble() ?? 0.0;
    final pointRealisasi = (item['pointRealisasi'] as num?)?.toDouble() ?? 0.0;

    final performaConfig = item['performaConfig'] as Map<String, dynamic>?;
    final durasiConfig = item['durasiConfig'] as Map<String, dynamic>?;
    final realisasiConfig = item['realisasiConfig'] as Map<String, dynamic>?;

    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(
                bulanStr.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Per Tanggal: $perTanggal',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Metrics rows
          _buildScoreRow('Nilai Kinerja', nilaiKinerja, performaConfig),
          const SizedBox(height: 6),
          _buildScoreRow('Point Durasi', pointDurasi, durasiConfig),
          const SizedBox(height: 6),
          _buildScoreRow('Point Realisasi', pointRealisasi, realisasiConfig),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () {
                context.push(
                  AppRoutes.detailRiwayatPenilaianHar,
                  extra: {
                    'type': 'har',
                    'item': item,
                  },
                );
              },
              child: const Text('Lihat Detail',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(
    String label,
    double value,
    Map<String, dynamic>? config,
  ) {
    final cat = config?['category']?.toString();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        Row(
          children: [
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (cat != null) ...[
              const SizedBox(width: 4),
              Text(
                '($cat)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
