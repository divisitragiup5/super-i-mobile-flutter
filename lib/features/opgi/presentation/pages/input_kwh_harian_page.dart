import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class InputKwhHarianPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String date;

  const InputKwhHarianPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.date,
  });

  @override
  State<InputKwhHarianPage> createState() => _InputKwhHarianPageState();
}

class _InputKwhHarianPageState extends State<InputKwhHarianPage> {
  final _formKey = GlobalKey<FormState>();

  final _penyulangIdController = TextEditingController(text: '1');
  final _namaPenyulangController = TextEditingController(text: 'Penyulang 1');
  final _standAwalController = TextEditingController();
  final _standAkhirController = TextEditingController();
  final _faktorKaliController = TextEditingController(text: '1.0');
  double _calculatedTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _standAwalController.addListener(_calculateTotal);
    _standAkhirController.addListener(_calculateTotal);
    _faktorKaliController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final awal = double.tryParse(_standAwalController.text) ?? 0.0;
    final akhir = double.tryParse(_standAkhirController.text) ?? 0.0;
    final faktor = double.tryParse(_faktorKaliController.text) ?? 1.0;
    setState(() {
      _calculatedTotal = (akhir - awal) * faktor;
      if (_calculatedTotal < 0) _calculatedTotal = 0;
    });
  }

  @override
  void dispose() {
    _penyulangIdController.dispose();
    _namaPenyulangController.dispose();
    _standAwalController.dispose();
    _standAkhirController.dispose();
    _faktorKaliController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'penyulangId': int.tryParse(_penyulangIdController.text) ?? 1,
      'namaPenyulang': _namaPenyulangController.text,
      'standAwal': double.tryParse(_standAwalController.text) ?? 0.0,
      'standAkhir': double.tryParse(_standAkhirController.text) ?? 0.0,
      'faktorKali': double.tryParse(_faktorKaliController.text) ?? 1.0,
      'totalKwh': _calculatedTotal,
      'date': widget.date,
      'garduIndukId': widget.garduIndukId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input KWH Harian'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<OpgiRealisasiCubit, OpgiRealisasiState>(
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
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Penyulang', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _namaPenyulangController,
                          decoration: const InputDecoration(labelText: 'Nama Penyulang *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _penyulangIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ID Penyulang *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Stand Meter
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pencatatan Stand Meter', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _standAwalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Stand Awal *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _standAkhirController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Stand Akhir *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _faktorKaliController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Faktor Kali *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total kWh Terhitung:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '${_calculatedTotal.toStringAsFixed(1)} kWh',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Simpan Draft'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            final data = _buildPayload();
                            await context.read<OpgiRealisasiCubit>().saveDraft(
                              type: 'kwh-harian',
                              nama: '${_namaPenyulangController.text} - ${widget.garduIndukNama}',
                              date: widget.date,
                              data: data,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Draft berhasil disimpan offline')),
                              );
                              Navigator.of(context).pop(true);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Kirim ke Server'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final data = _buildPayload();
                            context.read<OpgiRealisasiCubit>().submitKwhHarian(
                              widget.garduIndukId,
                              [data],
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
