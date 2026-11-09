import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_manuver_cubit.dart';

class ManuverPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const ManuverPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<ManuverPage> createState() => _ManuverPageState();
}

class _ManuverPageState extends State<ManuverPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<OpgiManuverCubit>().loadHistory(widget.garduIndukId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manuver - ${widget.garduIndukNama}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetch,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Input Manuver'),
        onPressed: () async {
          final res = await context.push(
            '/input-manuver',
            extra: {
              'garduIndukId': widget.garduIndukId,
              'garduIndukNama': widget.garduIndukNama,
            },
          );
          if (res == true) _fetch();
        },
      ),
      body: BlocConsumer<OpgiManuverCubit, OpgiManuverState>(
        listener: (context, state) {
          if (state is OpgiManuverSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            _fetch();
          } else if (state is OpgiManuverError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is OpgiManuverLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OpgiManuverLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.swap_calls_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Belum ada riwayat manuver'),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = state.items[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.namaPeralatan,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.tindakan == 'TUTUP' || item.tindakan == 'MASUK'
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: item.tindakan == 'TUTUP' || item.tindakan == 'MASUK'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              child: Text(
                                item.tindakan,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: item.tindakan == 'TUTUP' || item.tindakan == 'MASUK'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Waktu: ${item.waktuManuver}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        if (item.dispatcher != null)
                          Text(
                            'Dispatcher: ${item.dispatcher}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        if (item.keterangan != null) ...[
                          const SizedBox(height: 6),
                          Text('Keterangan: ${item.keterangan}', style: const TextStyle(fontSize: 13)),
                        ],
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () {
                                if (item.id != null) {
                                  context.read<OpgiManuverCubit>().deleteManuver(item.id!, widget.garduIndukId);
                                }
                              },
                            ),
                          ],
                        ),
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
