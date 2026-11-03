import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class InputBebanPenyulangPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String date;

  const InputBebanPenyulangPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.date,
  });

  @override
  State<InputBebanPenyulangPage> createState() => _InputBebanPenyulangPageState();
}

class _InputBebanPenyulangPageState extends State<InputBebanPenyulangPage> {
  final _formKey = GlobalKey<FormState>();

  int _selectedPeriode = DateTime.now().hour;
  final _penyulangIdController = TextEditingController(text: '1');
  final _namaPenyulangController = TextEditingController(text: 'Penyulang 1');
  final _arusRController = TextEditingController();
  final _arusSController = TextEditingController();
  final _arusTController = TextEditingController();
  final _arusNController = TextEditingController();
  final _dayaMwController = TextEditingController();
  final _dayaMvarController = TextEditingController();
  final _cosPhiController = TextEditingController();

  @override
  void dispose() {
    _penyulangIdController.dispose();
    _namaPenyulangController.dispose();
    _arusRController.dispose();
    _arusSController.dispose();
    _arusTController.dispose();
    _arusNController.dispose();
    _dayaMwController.dispose();
    _dayaMvarController.dispose();
    _cosPhiController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'penyulangId': int.tryParse(_penyulangIdController.text) ?? 1,
      'namaPenyulang': _namaPenyulangController.text,
      'periode': _selectedPeriode,
      'arusR': double.tryParse(_arusRController.text) ?? 0.0,
      'arusS': double.tryParse(_arusSController.text) ?? 0.0,
      'arusT': double.tryParse(_arusTController.text) ?? 0.0,
      'arusN': double.tryParse(_arusNController.text) ?? 0.0,
      if (_dayaMwController.text.isNotEmpty)
        'dayaMw': double.tryParse(_dayaMwController.text),
      if (_dayaMvarController.text.isNotEmpty)
        'dayaMvar': double.tryParse(_dayaMvarController.text),
      if (_cosPhiController.text.isNotEmpty)
        'cosPhi': double.tryParse(_cosPhiController.text),
      'date': widget.date,
      'garduIndukId': widget.garduIndukId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Beban Penyulang'),
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
                // Periode
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

                // Penyulang info
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
                          decoration: const InputDecoration(
                            labelText: 'Nama Penyulang *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _penyulangIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'ID Penyulang *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Arus
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Arus (Ampere)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _arusRController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Arus R *', suffixText: 'A', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _arusSController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Arus S *', suffixText: 'A', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _arusTController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Arus T *', suffixText: 'A', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _arusNController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Arus N *', suffixText: 'A', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Daya
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Daya & Cos Phi (Opsional)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dayaMwController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Daya (MW)', suffixText: 'MW', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _dayaMvarController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Daya (MVAR)', suffixText: 'MVAR', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cosPhiController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Cos Phi', border: OutlineInputBorder()),
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
                              type: 'beban-penyulang',
                              nama: '${_namaPenyulangController.text} - ${widget.garduIndukNama}',
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
                            context.read<OpgiRealisasiCubit>().submitBebanPenyulang(
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
