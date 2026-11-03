import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/circular_gauge.dart';

class RiwayatPenilaianInspeksiPage extends StatelessWidget {
  const RiwayatPenilaianInspeksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penilaian Kinerja Inspeksi'),
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
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
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
                    const Text(
                      'Skor Kinerja Bulan Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularGauge(
                      score: 95.0,
                      label: 'Target 100%',
                      size: 130,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Kepatuhan', '100%'),
                        _buildStat('Penyelesaian', '90%'),
                        _buildStat('Kehadiran', '98%'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Riwayat Penilaian Bulanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildHistoryCard('Oktober 2026', 96.5, 'Sangat Baik'),
              _buildHistoryCard('September 2026', 94.0, 'Baik'),
              _buildHistoryCard('Agustus 2026', 98.2, 'Sangat Baik'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, String val) {
    return Column(
      children: [
        Text(val,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildHistoryCard(String bulan, double score, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bulan,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Status: $status',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          Text(
            score.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
