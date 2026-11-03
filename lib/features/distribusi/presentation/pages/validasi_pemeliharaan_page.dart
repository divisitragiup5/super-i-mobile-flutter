import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ValidasiPemeliharaanPage extends StatelessWidget {
  const ValidasiPemeliharaanPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_outlined, size: 48, color: AppColors.primary),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada antrean validasi pemeliharaan saat ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
