import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class KwhHarianPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const KwhHarianPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<KwhHarianPage> createState() => _KwhHarianPageState();
}

class _KwhHarianPageState extends State<KwhHarianPage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    context.read<OpgiRealisasiCubit>().loadKwhHarian(widget.garduIndukId, dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('KWH Harian - ${widget.garduIndukNama}'),
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
        label: const Text('Input KWH Harian'),
        onPressed: () async {
          final res = await context.push(
            '/input-kwh-harian',
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
                if (state is KwhHarianLoaded) {
                  final items = state.items;
                  final drafts = state.localDrafts;

                  if (items.isEmpty && drafts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_chart_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('Belum ada data KWH Harian pada tanggal ini'),
                        ],
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Draft Section
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
                                context.read<OpgiRealisasiCubit>().submitKwhHarian(widget.garduIndukId, payload);
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
                      ...items.map((k) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  k.namaPenyulang,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _buildStat('Stand Awal', '${k.standAwal}'),
                                    _buildStat('Stand Akhir', '${k.standAkhir}'),
                                    _buildStat('Faktor Kali', '${k.faktorKali}'),
                                    if (k.totalKwh != null)
                                      _buildStat('Total kWh', '${k.totalKwh?.toStringAsFixed(1)}'),
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
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }
}
