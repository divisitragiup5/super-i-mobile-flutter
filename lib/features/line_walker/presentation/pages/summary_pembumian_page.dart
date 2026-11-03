import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryPembumianPage extends StatelessWidget {
  const SummaryPembumianPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Pembumian'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Distribusi Status Inspeksi Pembumian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Visual summary gauge / ring representation
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: 0.85,
                              strokeWidth: 14,
                              backgroundColor: Color(0xFFF1F5F9),
                              color: AppColors.success,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                '85%',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                'Selesai',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Baik', '85%', Colors.green),
                        _buildLegendItem('Anomali', '10%', Colors.orange),
                        _buildLegendItem('Kendala', '5%', Colors.red),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
