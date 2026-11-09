import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_manuver_cubit.dart';

class InputManuverPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;

  const InputManuverPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
  });

  @override
  State<InputManuverPage> createState() => _InputManuverPageState();
}

class _InputManuverPageState extends State<InputManuverPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaPeralatanController = TextEditingController();
  final _dispatcherController = TextEditingController();
  final _pelaksanaController = TextEditingController();
  final _keteranganController = TextEditingController();

  String _tipeManuver = 'PEMELIHARAAN';
  String _objek = 'PMT';
  String _tindakan = 'BUKA';
  String _status = 'OPEN';

  @override
  void dispose() {
    _namaPeralatanController.dispose();
    _dispatcherController.dispose();
    _pelaksanaController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Manuver 20kV'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<OpgiManuverCubit, OpgiManuverState>(
        listener: (context, state) {
          if (state is OpgiManuverSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.of(context).pop(true);
          } else if (state is OpgiManuverError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Data Manuver', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _namaPeralatanController,
                          decoration: const InputDecoration(labelText: 'Nama Peralatan / Bay / Penyulang *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _tipeManuver,
                          decoration: const InputDecoration(labelText: 'Tipe Manuver', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'PEMELIHARAAN', child: Text('PEMELIHARAAN')),
                            DropdownMenuItem(value: 'GANGGUAN', child: Text('GANGGUAN')),
                            DropdownMenuItem(value: 'TRIP OVERLOAD', child: Text('TRIP OVERLOAD')),
                            DropdownMenuItem(value: 'PENGATURAN TEGANGAN', child: Text('PENGATURAN TEGANGAN')),
                          ],
                          onChanged: (v) => setState(() => _tipeManuver = v ?? _tipeManuver),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _objek,
                          decoration: const InputDecoration(labelText: 'Objek Manuver', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'PMT', child: Text('PMT')),
                            DropdownMenuItem(value: 'PMS REL', child: Text('PMS REL')),
                            DropdownMenuItem(value: 'PMS LINE', child: Text('PMS LINE')),
                            DropdownMenuItem(value: 'GROUNDING', child: Text('GROUNDING')),
                          ],
                          onChanged: (v) => setState(() => _objek = v ?? _objek),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _tindakan,
                                decoration: const InputDecoration(labelText: 'Tindakan', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'BUKA', child: Text('BUKA')),
                                  DropdownMenuItem(value: 'TUTUP', child: Text('TUTUP')),
                                  DropdownMenuItem(value: 'LEPAS', child: Text('LEPAS')),
                                  DropdownMenuItem(value: 'MASUK', child: Text('MASUK')),
                                ],
                                onChanged: (v) => setState(() => _tindakan = v ?? _tindakan),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: const InputDecoration(labelText: 'Status Akhir', border: OutlineInputBorder()),
                                items: const [
                                  DropdownMenuItem(value: 'OPEN', child: Text('OPEN')),
                                  DropdownMenuItem(value: 'CLOSE', child: Text('CLOSE')),
                                ],
                                onChanged: (v) => setState(() => _status = v ?? _status),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Petugas & Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dispatcherController,
                          decoration: const InputDecoration(labelText: 'Dispatcher Dispatch', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pelaksanaController,
                          decoration: const InputDecoration(labelText: 'Pelaksana Manuver', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _keteranganController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Keterangan Tambahan', border: OutlineInputBorder()),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Simpan Manuver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final now = DateTime.now().toIso8601String();
                      context.read<OpgiManuverCubit>().submitManuver({
                        'garduIndukId': widget.garduIndukId,
                        'namaPeralatan': _namaPeralatanController.text,
                        'tipeManuver': _tipeManuver,
                        'objek': _objek,
                        'tindakan': _tindakan,
                        'status': _status,
                        'waktuManuver': now,
                        'dispatcher': _dispatcherController.text.isNotEmpty ? _dispatcherController.text : null,
                        'pelaksana': _pelaksanaController.text.isNotEmpty ? _pelaksanaController.text : null,
                        'keterangan': _keteranganController.text.isNotEmpty ? _keteranganController.text : null,
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
