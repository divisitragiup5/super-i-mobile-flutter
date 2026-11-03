import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_il1_cubit.dart';

class Il1TrafoPsPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const Il1TrafoPsPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<Il1TrafoPsPage> createState() => _Il1TrafoPsPageState();
}

class _Il1TrafoPsPageState extends State<Il1TrafoPsPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<OpgiIl1Cubit>().loadTrafoPs(widget.garduIndukId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IL1 Trafo PS - ${widget.garduIndukNama}'),
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
          if (state is Il1TrafoPsLoaded) {
            final items = state.items;
            final drafts = state.localDrafts;

            if (items.isEmpty && drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.view_in_ar_outlined, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Tidak ada data Trafo PS'),
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
                  'Daftar Trafo PS (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...items.map((t) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: t.sudahInspeksi
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        child: Icon(
                          t.sudahInspeksi ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: t.sudahInspeksi ? Colors.green : Colors.grey,
                        ),
                      ),
                      title: Text(
                        t.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        t.sudahInspeksi ? 'Sudah Diinspeksi' : 'Belum Diinspeksi',
                        style: TextStyle(
                          color: t.sudahInspeksi ? Colors.green : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final res = await context.push(
                          '/input-il1-trafo-ps',
                          extra: {
                            'garduIndukId': widget.garduIndukId,
                            'garduIndukNama': widget.garduIndukNama,
                            'trafoId': t.id,
                            'trafoNama': t.nama,
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
