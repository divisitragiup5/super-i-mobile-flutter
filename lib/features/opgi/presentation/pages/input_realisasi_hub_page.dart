import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/qr_scanner_modal.dart';
import '../widgets/opgi_menu_card.dart';

class InputRealisasiHubPage extends StatelessWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const InputRealisasiHubPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  Future<void> _handleScan(BuildContext context, String title, String route) async {
    final code = await QrScannerModal.scan(
      context,
      title: 'Scan QR $title',
    );
    if (code != null && code.trim().isNotEmpty && context.mounted) {
      context.push(
        route,
        extra: {
          'garduIndukId': garduIndukId,
          'garduIndukNama': garduIndukNama,
          'scanValue': code.trim(),
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleText = garduIndukNama.isNotEmpty && garduIndukNama != '-'
        ? 'Input Realisasi - $garduIndukNama'
        : 'Input Realisasi';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (garduIndukId == 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Gardu Induk Belum Dipilih',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Silakan pilih Gardu Induk terlebih dahulu agar input realisasi terdata dengan benar.',
                        style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          context.push(
                            AppRoutes.garduInduk20kv,
                            extra: {'redirectPath': AppRoutes.inputRealisasi},
                          );
                        },
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Pilih Gardu Induk'),
                      ),
                    ],
                  ),
                ),
              ],
              OpgiMenuCard(
                title: 'BEBAN PENYULANG',
                description: garduIndukNama,
                icon: Icons.account_tree_outlined,
                iconColor: const Color(0xFF00796B),
                useScanner: true,
                onTap: () {
                  context.push(
                    AppRoutes.bebanPenyulang,
                    extra: {
                      'garduIndukId': garduIndukId,
                      'garduIndukNama': garduIndukNama,
                    },
                  );
                },
                onScanTap: () => _handleScan(context, 'Beban Penyulang', AppRoutes.bebanPenyulang),
              ),
              const SizedBox(height: 12),
              OpgiMenuCard(
                title: 'BEBAN TRAFO',
                description: garduIndukNama,
                icon: Icons.memory_outlined,
                iconColor: const Color(0xFF1565C0),
                useScanner: true,
                onTap: () {
                  context.push(
                    AppRoutes.bebanTrafo,
                    extra: {
                      'garduIndukId': garduIndukId,
                      'garduIndukNama': garduIndukNama,
                    },
                  );
                },
                onScanTap: () => _handleScan(context, 'Beban Trafo', AppRoutes.bebanTrafo),
              ),
              const SizedBox(height: 12),
              OpgiMenuCard(
                title: 'TEGANGAN TRAFO',
                description: garduIndukNama,
                icon: Icons.bolt_outlined,
                iconColor: const Color(0xFFE65100),
                useScanner: true,
                onTap: () {
                  context.push(
                    AppRoutes.teganganTrafo,
                    extra: {
                      'garduIndukId': garduIndukId,
                      'garduIndukNama': garduIndukNama,
                    },
                  );
                },
                onScanTap: () => _handleScan(context, 'Tegangan Trafo', AppRoutes.teganganTrafo),
              ),
              const SizedBox(height: 12),
              OpgiMenuCard(
                title: 'KWH HARIAN',
                description: garduIndukNama,
                icon: Icons.insert_chart_outlined,
                iconColor: const Color(0xFF6A1B9A),
                useScanner: true,
                onTap: () {
                  context.push(
                    AppRoutes.kwhHarian,
                    extra: {
                      'garduIndukId': garduIndukId,
                      'garduIndukNama': garduIndukNama,
                    },
                  );
                },
                onScanTap: () => _handleScan(context, 'KWH Harian', AppRoutes.kwhHarian),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
