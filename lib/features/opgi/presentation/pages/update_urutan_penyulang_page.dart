import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class UpdateUrutanPenyulangPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const UpdateUrutanPenyulangPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<UpdateUrutanPenyulangPage> createState() => _UpdateUrutanPenyulangPageState();
}

class _UpdateUrutanPenyulangPageState extends State<UpdateUrutanPenyulangPage> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    final state = context.read<OpgiRealisasiCubit>().state;
    if (state is BebanPenyulangLoaded) {
      final seen = <int>{};
      final uniqueList = <Map<String, dynamic>>[];
      for (final p in state.items) {
        if (!seen.contains(p.penyulangId)) {
          seen.add(p.penyulangId);
          uniqueList.add({
            'penyulangId': p.penyulangId,
            'nama': p.namaPenyulang,
            'urutan': p.urutan,
          });
        }
      }
      _items = uniqueList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urutkan Penyulang'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              final payload = <Map<String, dynamic>>[];
              for (int i = 0; i < _items.length; i++) {
                payload.add({
                  'penyulangId': _items[i]['penyulangId'],
                  'urutan': i + 1,
                });
              }
              context.read<OpgiRealisasiCubit>().updateUrutanPenyulang(
                widget.garduIndukId,
                payload,
              );
              Navigator.of(context).pop(true);
            },
            child: const Text('Simpan Urutan'),
          ),
        ),
      ),
      body: _items.isEmpty
          ? const Center(child: Text('Tidak ada penyulang untuk diurutkan'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  key: ValueKey(item['penyulangId']),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                      child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                    title: Text(item['nama'] as String? ?? '-'),
                    trailing: const Icon(Icons.drag_handle),
                  ),
                );
              },
            ),
    );
  }
}
