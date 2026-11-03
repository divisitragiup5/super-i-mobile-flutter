import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_il1_cubit.dart';

class Il1KubikelPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const Il1KubikelPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<Il1KubikelPage> createState() => _Il1KubikelPageState();
}

class _Il1KubikelPageState extends State<Il1KubikelPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<OpgiIl1Cubit>().loadKubikel(widget.garduIndukId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IL1 Kubikel - ${widget.garduIndukNama}'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetch,
          ),
        ],
      ),
      body: BlocConsumer<OpgiIl1Cubit, OpgiIl1State>(
        listener: (context, state) {
          if (state is OpgiIl1Success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            _fetch();
          } else if (state is OpgiIl1Error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is OpgiIl1Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is Il1KubikelLoaded) {
            final items = state.items;
            final drafts = state.localDrafts;

            if (items.isEmpty && drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.dns_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Tidak ada data kubikel penyulang'),
                  ],
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Drafts
                if (drafts.isNotEmpty) ...[
                  Text(
                    'Draft Tersimpan (${drafts.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  ...drafts.map((d) {
                    return Card(
                      color: Colors.orange.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.edit_note, color: Colors.orange),
                        title: Text(d['nama'] as String? ?? 'Draft'),
                        subtitle: Text(d['date'] as String? ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            if (d['id'] != null) {
                              context.read<OpgiIl1Cubit>().deleteDraft(d['id'] as int).then((_) => _fetch());
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 24),
                ],

                // Items list
                Text(
                  'Daftar Kubikel (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...items.map((k) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: k.sudahInspeksi
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        child: Icon(
                          k.sudahInspeksi ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: k.sudahInspeksi ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Text(
                        k.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        k.sudahInspeksi ? 'Sudah Diinspeksi' : 'Belum Diinspeksi',
                        style: TextStyle(
                          color: k.sudahInspeksi ? Colors.green : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final res = await context.push(
                          '/input-il1-kubikel',
                          extra: {
                            'garduIndukId': widget.garduIndukId,
                            'garduIndukNama': widget.garduIndukNama,
                            'penyulangId': k.id,
                            'penyulangNama': k.nama,
                          },
                        );
                        if (res == true) _fetch();
                      },
                    ),
                  );
                }),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
