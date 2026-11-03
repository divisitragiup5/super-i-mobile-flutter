import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/sutm_workorder_model.dart';

class ValidasiDetailWorkorderPage extends StatelessWidget {
  final SutmWorkOrderItem workOrder;

  const ValidasiDetailWorkorderPage({
    super.key,
    required this.workOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validasi WO #${workOrder.id}'),
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Order #${workOrder.id}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: ${workOrder.status}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total SUTM: ${workOrder.items.length} Item',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Daftar Tiang SUTM',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...workOrder.items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(item.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${item.idAsset} • Status: ${item.status}'),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
