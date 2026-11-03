import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class TeganganTrafoPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const TeganganTrafoPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<TeganganTrafoPage> createState() => _TeganganTrafoPageState();
}

class _TeganganTrafoPageState extends State<TeganganTrafoPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    context.read<OpgiRealisasiCubit>().loadTeganganTrafo(widget.garduIndukId, dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Tegangan Trafo - ${widget.garduIndukNama}'),
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
        label: const Text('Input Tegangan Trafo'),
        onPressed: () async {
          final res = await context.push(
            '/input-tegangan-trafo',
            extra: {
              'garduIndukId': widget.garduIndukId,
              'garduIndukNama': widget.garduIndukNama,
              'date': DateFormat('yyyy-MM-dd').format(selectedDate),
            },
          );
          if (res == true) _fetch();
        },
      ),
      body: Column(
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                      _fetch();
                    }
                  },
                  child: const Text('Ganti Tanggal'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: BlocConsumer<OpgiRealisasiCubit, OpgiRealisasiState>(
              listener: (context, state) {
                if (state is OpgiRealisasiSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                  _fetch();
                } else if (state is OpgiRealisasiError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
              },
              builder: (context, state) {
                if (state is OpgiRealisasiLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TeganganTrafoLoaded) {
                  final items = state.items;
                  final drafts = state.localDrafts;

                  if (items.isEmpty && drafts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bolt_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Belum ada data Tegangan Trafo pada tanggal ini'),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Drafts
                      if (drafts.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Draft Tersimpan (${drafts.length})',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                              label: const Text('Kirim Draft'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              onPressed: () {
                                final payload = drafts.map((d) {
                                  final dataMap = d['data'] is String
                                      ? Map<String, dynamic>.from(const {})
                                      : d['data'] as Map<String, dynamic>;
                                  return dataMap;
                                }).toList();
                                context.read<OpgiRealisasiCubit>().submitTeganganTrafo(widget.garduIndukId, payload);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...drafts.map((d) {
                          return Card(
                            color: Colors.orange.shade50,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.edit_note, color: Colors.orange),
                              title: Text(d['nama'] as String? ?? 'Draft'),
                              subtitle: Text('Periode: ${d['periode'] ?? '-'} WIB'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  if (d['id'] != null) {
                                    context.read<OpgiRealisasiCubit>().deleteDraft(d['id'] as int).then((_) => _fetch());
                                  }
                                },
                              ),
                            ),
                          );
                        }),
                        const Divider(height: 24),
                      ],

                      // Server data
                      Text(
                        'Data Tersimpan (${items.length})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      ...items.map((t) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t.namaTrafo,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Pukul ${t.periode.toString().padLeft(2, '0')}:00 WIB',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 10,
                                  children: [
                                    if (t.tegangan20kv != null) _buildStat('Teg 20kV', '${t.tegangan20kv} kV'),
                                    if (t.tegangan150kv != null) _buildStat('Teg 150kV', '${t.tegangan150kv} kV'),
                                    if (t.vrn != null) _buildStat('Vrn', '${t.vrn} V'),
                                    if (t.vsn != null) _buildStat('Vsn', '${t.vsn} V'),
                                    if (t.vtn != null) _buildStat('Vtn', '${t.vtn} V'),
                                    if (t.vrs != null) _buildStat('Vrs', '${t.vrs} V'),
                                    if (t.vst != null) _buildStat('Vst', '${t.vst} V'),
                                    if (t.vtr != null) _buildStat('Vtr', '${t.vtr} V'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
