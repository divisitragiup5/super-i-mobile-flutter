import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_background.dart';
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
        title: const Text('Riwayat PPL'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PplCubit>().loadSummary();
            },
          ),
        ],
      ),
      body: AppBackground(
        child: BlocBuilder<PplCubit, PplState>(
          builder: (context, state) {
            final isLoading = state is PplLoading;
            Map<String, dynamic> summary = {};
            if (state is PplSummaryLoaded) {
              summary = state.summary;
            }

            final items = [
              {
                'icon': Icons.insert_drive_file_outlined,
                'title': 'Belum TTD',
                'type': 'belum-ttd-tl-gi',
                'count': summary['belum-ttd-tl-gi'],
              },
              {
                'icon': Icons.file_copy_outlined,
                'title': 'Sudah TTD',
                'type': 'sudah-ttd-tl-gi',
                'count': summary['sudah-ttd-tl-gi'],
              },
              {
                'icon': Icons.description_outlined,
                'title': 'Semua',
                'type': 'all',
                'count': summary['all'],
              },
            ];

            return RefreshIndicator(
              onRefresh: () => context.read<PplCubit>().loadSummary(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final count = item['count'];

                  return InkWell(
                    onTap: () async {
                      await context.push('/riwayat-ppl?type=${item['type']}');
                      if (context.mounted) {
                        context.read<PplCubit>().loadSummary();
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          if (isLoading)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                          else
                            Text(
                              (count ?? 0).toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
