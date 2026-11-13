import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_gauge.dart';
import '../../domain/repositories/sutm_repository.dart';

class DetailRiwayatPenilaianDistribusiPage extends StatefulWidget {
  final String type; // 'inspeksi' | 'har'
  final Map<String, dynamic> item;

  const DetailRiwayatPenilaianDistribusiPage({
    super.key,
    required this.type,
    required this.item,
  });

  @override
  State<DetailRiwayatPenilaianDistribusiPage> createState() =>
      _DetailRiwayatPenilaianDistribusiPageState();
}

class _DetailRiwayatPenilaianDistribusiPageState
    extends State<DetailRiwayatPenilaianDistribusiPage> {
  String _timeSet = 'harian'; // 'harian' | 'mingguan'
  bool _isLoading = true;
  List<dynamic> _detailList = [];
  Map<String, dynamic> _chartData = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = context.read<SutmRepository>();
    final int? bulan = widget.item['bulan'] as int?;
    final int? tahun = widget.item['tahun'] as int?;

    final detailFuture = repo.getPenilaianDetailHistory(
      type: widget.type,
      timeSet: _timeSet,
      bulan: bulan,
      tahun: tahun,
    );
    final chartFuture = repo.getPenilaianDetailChart(
      type: widget.type,
      timeSet: _timeSet,
      bulan: bulan,
      tahun: tahun,
    );

    final results = await Future.wait([detailFuture, chartFuture]);
    final detailResult = results[0];
    final chartResult = results[1];

    if (!mounted) return;

    detailResult.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = failure.message;
        });
      },
      (detailData) {
        chartResult.fold(
          (failure) {
            setState(() {
              _isLoading = false;
              _errorMessage = failure.message;
            });
          },
          (chartRes) {
            final rawList = detailData['data'] is List
                ? detailData['data'] as List
                : [];
            final rawChart = chartRes['data'] is Map<String, dynamic>
                ? chartRes['data'] as Map<String, dynamic>
                : <String, dynamic>{};

            setState(() {
              _isLoading = false;
              _detailList = rawList;
              _chartData = rawChart;
            });
          },
        );
      },
    );
  }

  void _setTimeSet(String timeSet) {
    if (_timeSet == timeSet) return;
    setState(() => _timeSet = timeSet);
    _fetchDetailData();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'har'
        ? 'Detail Penilaian Pemeliharaan'
        : 'Detail Penilaian Inspeksi';

    final chartHeader = _chartData['chart'] as Map<String, dynamic>? ?? {};
    final double nilaiKinerja =
        (chartHeader['nilaiKinerja'] as num?)?.toDouble() ??
            (widget.item['nilaiKinerja'] as num?)?.toDouble() ??
            0.0;
    final double pointDurasi =
        (chartHeader['pointDurasi'] as num?)?.toDouble() ??
            (widget.item['pointDurasi'] as num?)?.toDouble() ??
            0.0;
    final double pointRealisasi =
        (chartHeader['pointRealisasi'] as num?)?.toDouble() ??
            (widget.item['pointRealisasi'] as num?)?.toDouble() ??
            0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
            onRefresh: _fetchDetailData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Toggle Harian / Mingguan
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
                          onTap: () => _setTimeSet('harian'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _timeSet == 'harian'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Harian',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _timeSet == 'harian'
                                    ? Colors.white
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _setTimeSet('mingguan'),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _timeSet == 'mingguan'
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Mingguan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _timeSet == 'mingguan'
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
                const SizedBox(height: 14),

                // Gauges Header Card
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
                    children: [
                      Text(
                        'Ringkasan Nilai Kinerja ${_timeSet == 'harian' ? 'Harian' : 'Mingguan'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildGaugeColumn(
                            score: nilaiKinerja,
                            label: 'Nilai Kinerja',
                            color: AppColors.primary,
                          ),
                          _buildGaugeColumn(
                            score: pointDurasi,
                            label: 'Point Durasi',
                            color: Colors.blue,
                          ),
                          _buildGaugeColumn(
                            score: pointRealisasi,
                            label: 'Point Realisasi',
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Breakdown Items
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rincian ${_timeSet == 'harian' ? 'Harian' : 'Mingguan'} (${_detailList.length})',
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
                else if (_detailList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tidak ada data rincian untuk periode ini.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  )
                else
                  ..._detailList.map((entry) {
                    final eMap = entry as Map<String, dynamic>;
                    return _buildDetailItemCard(eMap);
                  }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeColumn({
    required double score,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        CircularGauge(
          score: score,
          label: '',
          size: 78,
          strokeWidth: 6,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemCard(Map<String, dynamic> entry) {
    final label = _timeSet == 'harian'
        ? 'Tanggal ${entry['tanggal'] ?? '-'}'
        : 'Minggu ke-${entry['minggu'] ?? '-'}';

    final double nilai =
        (entry['nilaiHarian'] as num?)?.toDouble() ??
            (entry['nilaiMingguan'] as num?)?.toDouble() ??
            (entry['nilaiKinerja'] as num?)?.toDouble() ??
            0.0;
    final double durasi = (entry['pointDurasi'] as num?)?.toDouble() ?? 0.0;
    final double realisasi =
        (entry['pointRealisasi'] as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Skor: ${nilai.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Point Durasi',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    durasi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Point Realisasi',
                      style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    realisasi.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
