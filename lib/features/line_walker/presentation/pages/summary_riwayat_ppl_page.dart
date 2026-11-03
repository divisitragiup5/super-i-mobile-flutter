import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/ppl_cubit.dart';

class SummaryRiwayatPPLPage extends StatefulWidget {
  const SummaryRiwayatPPLPage({super.key});

  @override
  State<SummaryRiwayatPPLPage> createState() => _SummaryRiwayatPPLPageState();
}

class _SummaryRiwayatPPLPageState extends State<SummaryRiwayatPPLPage> {
  @override
  void initState() {
    super.initState();
    context.read<PplCubit>().loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Riwayat PPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<PplCubit, PplState>(
        builder: (context, state) {
          if (state is PplLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> summary = {};
          if (state is PplSummaryLoaded) {
            summary = state.summary;
          }

          final belumTtd = summary['belum-ttd-tl-gi'] ?? 0;
          final sudahTtd = summary['sudah-ttd-tl-gi'] ?? 0;
          final semua = summary['all'] ?? 0;

          return RefreshIndicator(
            onRefresh: () => context.read<PplCubit>().loadSummary(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCard(
                  title: 'Belum TTD TL GI',
                  count: belumTtd,
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                  onTap: () => context.push('/riwayat-ppl?type=belum-ttd-tl-gi'),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  title: 'Sudah TTD TL GI',
                  count: sudahTtd,
                  color: Colors.green,
                  icon: Icons.check_circle_outline,
                  onTap: () => context.push('/riwayat-ppl?type=sudah-ttd-tl-gi'),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  title: 'Semua Riwayat PPL',
                  count: semua,
                  color: AppColors.primary,
                  icon: Icons.folder_outlined,
                  onTap: () => context.push('/riwayat-ppl?type=all'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required dynamic count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}
