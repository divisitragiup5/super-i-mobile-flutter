import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/opgi_realisasi_cubit.dart';

class InputTeganganTrafoPage extends StatefulWidget {
  final int garduIndukId;
  final String garduIndukNama;
  final String date;

  const InputTeganganTrafoPage({
    super.key,
    required this.garduIndukId,
    required this.garduIndukNama,
    required this.date,
  });

  @override
  State<InputTeganganTrafoPage> createState() => _InputTeganganTrafoPageState();
}

class _InputTeganganTrafoPageState extends State<InputTeganganTrafoPage> {
  final _formKey = GlobalKey<FormState>();

  int _selectedPeriode = DateTime.now().hour;
  final _trafoIdController = TextEditingController(text: '1');
  final _namaTrafoController = TextEditingController(text: 'Trafo 1');
  final _tegangan20kvController = TextEditingController();
  final _tegangan150kvController = TextEditingController();
  final _vrnController = TextEditingController();
  final _vsnController = TextEditingController();
  final _vtnController = TextEditingController();
  final _vrsController = TextEditingController();
  final _vstController = TextEditingController();
  final _vtrController = TextEditingController();

  @override
  void dispose() {
    _trafoIdController.dispose();
    _namaTrafoController.dispose();
    _tegangan20kvController.dispose();
    _tegangan150kvController.dispose();
    _vrnController.dispose();
    _vsnController.dispose();
    _vtnController.dispose();
    _vrsController.dispose();
    _vstController.dispose();
    _vtrController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    return {
      'trafoId': int.tryParse(_trafoIdController.text) ?? 1,
      'namaTrafo': _namaTrafoController.text,
      'periode': _selectedPeriode,
      if (_tegangan20kvController.text.isNotEmpty)
        'tegangan20kv': double.tryParse(_tegangan20kvController.text),
      if (_tegangan150kvController.text.isNotEmpty)
        'tegangan150kv': double.tryParse(_tegangan150kvController.text),
      if (_vrnController.text.isNotEmpty)
        'vrn': double.tryParse(_vrnController.text),
      if (_vsnController.text.isNotEmpty)
        'vsn': double.tryParse(_vsnController.text),
      if (_vtnController.text.isNotEmpty)
        'vtn': double.tryParse(_vtnController.text),
      if (_vrsController.text.isNotEmpty)
        'vrs': double.tryParse(_vrsController.text),
      if (_vstController.text.isNotEmpty)
        'vst': double.tryParse(_vstController.text),
      if (_vtrController.text.isNotEmpty)
        'vtr': double.tryParse(_vtrController.text),
      'date': widget.date,
      'garduIndukId': widget.garduIndukId,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Tegangan Trafo'),
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

                // Trafo info
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
                          decoration: const InputDecoration(labelText: 'Nama Trafo *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _trafoIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'ID Trafo *', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Tegangan Bus
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tegangan Sistem', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _tegangan20kvController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Teg 20kV', suffixText: 'kV', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _tegangan150kvController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Teg 150kV', suffixText: 'kV', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phasa ke Netral
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tegangan Phasa ke Netral (Volt)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _vrnController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Vrn', suffixText: 'V', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _vsnController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Vsn', suffixText: 'V', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _vtnController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Vtn', suffixText: 'V', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Phasa ke Phasa
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tegangan Phasa ke Phasa (Volt)', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _vrsController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Vrs', suffixText: 'V', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _vstController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Vst', suffixText: 'V', border: OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _vtrController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(labelText: 'Vtr', suffixText: 'V', border: OutlineInputBorder()),
                              ),
                            ),
                          ],
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
                              type: 'tegangan-trafo',
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
                            context.read<OpgiRealisasiCubit>().submitTeganganTrafo(
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
