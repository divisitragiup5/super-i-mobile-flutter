import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_background.dart';
import '../../data/models/opgi_realisasi_model.dart';
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
  List<PenyulangModel> _items = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    final state = context.read<OpgiRealisasiCubit>().state;
    if (state is BebanPenyulangLoaded) {
      _items = [...state.items]..sort((a, b) => a.noUrutCustom.compareTo(b.noUrutCustom));
    } else {
      context.read<OpgiRealisasiCubit>().loadBebanPenyulang(widget.garduIndukId);
    }
  }

  void _onSave() {
    final payload = <Map<String, dynamic>>[];
    for (int i = 0; i < _items.length; i++) {
      payload.add({
        'id': _items[i].id,
        'noUrutCustom': i + 1,
      });
    }

    context.read<OpgiRealisasiCubit>().updateUrutanPenyulang(
          widget.garduIndukId,
          payload,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Urutkan Penyulang'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _onSave,
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiRealisasiCubit, OpgiRealisasiState>(
          listener: (context, state) {
            if (state is OpgiRealisasiSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop(true);
            } else if (state is OpgiRealisasiError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            } else if (state is BebanPenyulangLoaded) {
              setState(() {
                _items = [...state.items]..sort((a, b) => a.noUrutCustom.compareTo(b.noUrutCustom));
              });
            }
          },
          builder: (context, state) {
            if (state is OpgiRealisasiLoading && _items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_items.isEmpty) {
              return const Center(
                child: Text('Tidak ada penyulang untuk diurutkan', style: TextStyle(color: Colors.grey)),
              );
            }

            return ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  final item = _items.removeAt(oldIndex);
                  _items.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      item.nama,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    subtitle: Text(
                      item.garduIndukNama,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
