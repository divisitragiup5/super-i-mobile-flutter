import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class InputBebanTrafoPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String date;

  const InputBebanTrafoPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.date,
  });

  @override
  State<InputBebanTrafoPage> createState() => _InputBebanTrafoPageState();
}

class _InputBebanTrafoPageState extends State<InputBebanTrafoPage> {
  final _formKey = GlobalKey<FormState>();

  int _selectedPeriode = DateTime.now().hour;
  final _trafoIdController = TextEditingController(text: '1');
  final _namaTrafoController = TextEditingController(text: 'Trafo 1');
  final _arusController = TextEditingController();
  final _teganganController = TextEditingController();
  final _suhuWindingController = TextEditingController();
  final _suhuOliController = TextEditingController();

  @override
  void dispose() {
    _trafoIdController.dispose();
    _namaTrafoController.dispose();
    _arusController.dispose();
    _teganganController.dispose();
    _suhuWindingController.dispose();
    _suhuOliController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'trafoId': int.tryParse(_trafoIdController.text) ?? 1,
      'namaTrafo': _namaTrafoController.text,
      'periode': _selectedPeriode,
      'arus': double.tryParse(_arusController.text) ?? 0.0,
      if (_teganganController.text.isNotEmpty)
        'tegangan': double.tryParse(_teganganController.text),
      if (_suhuWindingController.text.isNotEmpty)
        'suhuWinding': double.tryParse(_suhuWindingController.text),
      if (_suhuOliController.text.isNotEmpty)
        'suhuOli': double.tryParse(_suhuOliController.text),
      'date': widget.date,
      'garduIndukId': widget.garduIndukId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Beban Trafo'),
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
                // Periode Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Jam / Periode (WIB)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _selectedPeriode,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: List.generate(24, (i) {
                            return DropdownMenuItem(
                              value: i,
                              child: Text('Pukul ${i.toString().padLeft(2, '0')}:00 WIB'),
                            );
                          }),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPeriode = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Trafo Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Informasi Trafo', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _namaTrafoController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Trafo *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _trafoIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ID Trafo *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pengukuran
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hasil Pengukuran', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _arusController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Arus (Ampere) *',
                            suffixText: 'A',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Arus wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _teganganController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Tegangan (kV)',
                            suffixText: 'kV',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _suhuWindingController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Suhu Winding (°C)',
                            suffixText: '°C',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _suhuOliController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Suhu Oli (°C)',
                            suffixText: '°C',
                            border: OutlineInputBorder(),
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
                              type: 'beban-trafo',
                              nama: '${_namaTrafoController.text} - ${widget.garduIndukNama}',
                              date: widget.date,
                              periode: _selectedPeriode,
                              data: data,
                            );
                            if (mounted) {
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
                            context.read<OpgiRealisasiCubit>().submitBebanTrafo(
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
