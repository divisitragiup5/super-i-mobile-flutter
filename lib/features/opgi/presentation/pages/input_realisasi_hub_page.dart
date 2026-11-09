import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class InputRealisasiHubPage extends StatelessWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const InputRealisasiHubPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {
        'title': 'BEBAN PENYULANG',
        'desc': garduIndukNama,
        'icon': Icons.account_tree_outlined,
        'route': '/beban-penyulang',
        'color': const Color(0xFF00796B),
      },
      {
        'title': 'BEBAN TRAFO',
        'desc': garduIndukNama,
        'icon': Icons.memory_outlined,
        'route': '/beban-trafo',
        'color': const Color(0xFF1565C0),
      },
      {
        'title': 'TEGANGAN TRAFO',
        'desc': garduIndukNama,
        'icon': Icons.bolt_outlined,
        'route': '/tegangan-trafo',
        'color': const Color(0xFFE65100),
      },
      {
        'title': 'KWH HARIAN',
        'desc': garduIndukNama,
        'icon': Icons.insert_chart_outlined,
        'route': '/kwh-harian',
        'color': const Color(0xFF6A1B9A),
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Realisasi - $garduIndukNama'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: menuItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final color = item['color'] as Color;
          return InkWell(
            onTap: () {
              context.push(
                item['route'] as String,
                extra: {
                  'garduIndukId': garduIndukId,
                  'garduIndukNama': garduIndukNama,
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['desc'] as String,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
