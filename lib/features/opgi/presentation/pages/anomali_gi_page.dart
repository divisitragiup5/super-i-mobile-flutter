import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_anomali_cubit.dart';

class AnomaliGiPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const AnomaliGiPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<AnomaliGiPage> createState() => _AnomaliGiPageState();
}

class _AnomaliGiPageState extends State<AnomaliGiPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<OpgiAnomaliCubit>().loadHistory(widget.garduIndukId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Anomali - ${widget.garduIndukNama}'),
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
        icon: const Icon(Icons.add_alert),
        label: const Text('Lapor Anomali'),
        onPressed: () async {
          final res = await context.push(
            '/input-anomali-gi',
            extra: {
              'garduIndukId': widget.garduIndukId,
              'garduIndukNama': widget.garduIndukNama,
            },
          );
          if (res == true) _fetch();
        },
      ),
      body: BlocConsumer<OpgiAnomaliCubit, OpgiAnomaliState>(
        listener: (context, state) {
          if (state is OpgiAnomaliSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            _fetch();
          } else if (state is OpgiAnomaliError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is OpgiAnomaliLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OpgiAnomaliLoaded) {
            final items = state.items;
            final drafts = state.localDrafts;

            if (items.isEmpty && drafts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                    const SizedBox(height: 12),
                    const Text('Tidak ada laporan anomali di GI ini'),
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
                        title: Text(d['nama'] as String? ?? 'Draft Anomali'),
                        subtitle: Text(d['date'] as String? ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                          onPressed: () {
                            if (d['id'] != null) {
                              context.read<OpgiAnomaliCubit>().deleteDraft(d['id'] as int).then((_) => _fetch());
                            }
                          },
                        ),
                      ),
                    );
                  }),
                  const Divider(height: 24),
                ],

                // Server list
                Text(
                  'Laporan Anomali (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                ...items.map((anomali) {
                  final urgensiColor = anomali.urgensi == 'BAHAYA'
                      ? Colors.red
                      : anomali.urgensi == 'INVESTIGASI LANJUTAN'
                          ? Colors.orange
                          : Colors.green;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
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
                              Expanded(
                                child: Text(
                                  anomali.assetNama,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: urgensiColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: urgensiColor),
                                ),
                                child: Text(
                                  anomali.urgensi,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: urgensiColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Entitas: ${anomali.entitas} • ${anomali.jenisAsset}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          if (anomali.createdAt != null)
                            Text(
                              DateFormat('dd MMM yyyy HH:mm').format(anomali.createdAt!),
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          const Divider(height: 16),
                          Text(
                            anomali.keterangan,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Status: ${anomali.tindakan}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Kondisi updates
                          if (anomali.kondisiList.isNotEmpty) ...[
                            ExpansionTile(
                              title: Text(
                                'Riwayat Kondisi (${anomali.kondisiList.length})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              tilePadding: EdgeInsets.zero,
                              children: anomali.kondisiList.map((k) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            k.tindakan,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          if (k.createdAt != null)
                                            Text(
                                              DateFormat('dd/MM HH:mm').format(k.createdAt!),
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(k.keterangan, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.update, size: 16),
                                label: const Text('Update Kondisi'),
                                onPressed: () async {
                                  final res = await context.push(
                                    '/input-kondisi-anomali-gi',
                                    extra: {
                                      'anomaliId': anomali.id,
                                      'assetNama': anomali.assetNama,
                                    },
                                  );
                                  if (res == true) _fetch();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () {
                                  context.read<OpgiAnomaliCubit>().deleteAnomali(anomali.id, widget.garduIndukId);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
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
