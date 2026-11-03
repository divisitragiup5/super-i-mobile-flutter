import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/gardu_induk_cubit.dart';

class GarduIndukHubPage extends StatefulWidget {
  final String? redirectPath;

  const GarduIndukHubPage({super.key, this.redirectPath});

  @override
  State<GarduIndukHubPage> createState() => _GarduIndukHubPageState();
}

class _GarduIndukHubPageState extends State<GarduIndukHubPage> {
  @override
  void initState() {
    super.initState();
    context.read<GarduIndukCubit>().loadGarduInduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Gardu Induk 20kV'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<GarduIndukCubit, GarduIndukState>(
        builder: (context, state) {
          if (state is GarduIndukLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GarduIndukError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<GarduIndukCubit>().loadGarduInduk(),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          if (state is GarduIndukLoaded) {
            if (state.list.isEmpty) {
              return const Center(child: Text('Tidak ada Gardu Induk tersedia'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final gi = state.list[index];
                return InkWell(
                  onTap: () {
                    final target = widget.redirectPath ?? '/input-realisasi';
                    context.push(
                      target,
                      extra: {
                        'garduIndukId': gi.id,
                        'garduIndukNama': gi.nama,
                        'garduInduk': {'id': gi.id, 'nama': gi.nama},
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
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.business_outlined, color: AppTheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gi.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (gi.kode != null)
                                Text(
                                  'Kode: ${gi.kode}',
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
