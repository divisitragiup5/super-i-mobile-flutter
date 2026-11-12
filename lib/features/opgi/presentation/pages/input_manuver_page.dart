// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/field_pict_input.dart';
import '../../../../core/widgets/input_container.dart';
import '../../../../core/storage/local_database.dart';
import '../constants/opgi_manuver_constants.dart';
import '../cubit/opgi_manuver_cubit.dart';
import '../widgets/multi_select_chips.dart';

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

  String _tipeManuver = 'GANGGUAN';
  int? _penyulangId;
  DateTime _waktu = DateTime.now();
  String _objek = 'PMT';
  String? _status;
  String? _posisi;
  List<String> _jenisGangguan = [];
  String? _operasi;
  final _keteranganController = TextEditingController();

  List<Map<String, dynamic>> _arusList = [
    {'type': 'Ia', 'satuan': 'A', 'value': ''},
  ];

  File? _dokumentasiFile;
  int? _draftId;

  List<Map<String, dynamic>> _penyulangOptions = [];
  bool _isLoadingPenyulang = true;

  @override
  void initState() {
    super.initState();
    _loadPenyulang();
    _loadDraftIfAvailable();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _loadPenyulang() async {
    try {
      await context
          .read<OpgiManuverCubit>()
          .loadPenyulangList(widget.garduIndukId);
    } catch (_) {}
  }

  Future<void> _loadDraftIfAvailable() async {
    try {
      final drafts = await LocalDatabase.instance.getUnfinishItemGi(
        nama: widget.garduIndukNama,
        type: 'manuver',
      );
      if (drafts.isNotEmpty) {
        final draft = drafts.first;
        final data = draft['data'] as Map<String, dynamic>? ?? {};
        setState(() {
          _draftId = draft['id'] as int?;
          if (data['tipeManuver'] != null) _tipeManuver = data['tipeManuver'];
          if (data['penyulangId'] != null) _penyulangId = data['penyulangId'] as int?;
          if (data['waktu'] != null) {
            _waktu = AppTimeUtils.parseToLocal(data['waktu'].toString()) ?? _waktu;
          }
          if (data['objek'] != null) _objek = data['objek'];
          _status = data['status'];
          _posisi = data['posisi'];
          _operasi = data['operasi'];
          if (data['keteranganPekerjaan'] != null) {
            _keteranganController.text = data['keteranganPekerjaan'].toString();
          }
          if (data['jenisGangguan'] is List) {
            _jenisGangguan = (data['jenisGangguan'] as List)
                .map((e) => e.toString())
                .toList();
          }
          if (data['arus'] is List && (data['arus'] as List).isNotEmpty) {
            _arusList = (data['arus'] as List).map((a) {
              return {
                'type': a['type']?.toString() ?? 'Ia',
                'satuan': a['satuan']?.toString() ?? 'A',
                'value': a['value']?.toString() ?? '',
              };
            }).toList();
          }
          if (data['dokumentasi_path'] != null) {
            final f = File(data['dokumentasi_path'].toString());
            if (f.existsSync()) {
              _dokumentasiFile = f;
            }
          }
        });
      }
    } catch (_) {}
  }

  bool get _isOnlyUFR =>
      _jenisGangguan.length == 1 && _jenisGangguan.first == 'UFR';

  bool get _showStatus {
    if (_tipeManuver == 'PEKERJAAN') return true;
    if ((_tipeManuver == 'GANGGUAN' || _tipeManuver == 'TRIP OVERLOAD') &&
        _objek == 'PMT') {
      return true;
    }
    return false;
  }

  bool get _showPosisi {
    if ((_tipeManuver == 'GANGGUAN' || _tipeManuver == 'TRIP OVERLOAD') &&
        _objek.isNotEmpty &&
        _status != 'CLOSE') {
      return true;
    }
    return false;
  }

  bool get _showJenisGangguan {
    if ((_tipeManuver == 'GANGGUAN' || _tipeManuver == 'TRIP OVERLOAD') &&
        _objek == 'PMT' &&
        _status == 'OPEN') {
      return true;
    }
    return false;
  }

  bool get _showOperasi {
    if (_tipeManuver == 'PEKERJAAN' && _objek == 'PMT' && _status == 'OPEN') {
      return true;
    }
    return false;
  }

  bool get _showKeterangan {
    if (_tipeManuver == 'PEKERJAAN' && _status != 'CLOSE') {
      return true;
    }
    return false;
  }

  bool get _showArus {
    if (_objek != 'PMT' || _isOnlyUFR) return false;
    if (_tipeManuver == 'GANGGUAN' || _tipeManuver == 'TRIP OVERLOAD') {
      return true;
    }
    if (_tipeManuver == 'PEKERJAAN' && _status != null) {
      return true;
    }
    return false;
  }

  String get _arusContainerLabel {
    if (_tipeManuver == 'PEKERJAAN') {
      if (_status == 'OPEN') return 'ARUS SEBELUM DILEPAS';
      if (_status == 'CLOSE') return 'ARUS SETELAH DIMASUKKAN';
      return 'ARUS';
    } else {
      if (_status == 'OPEN') return 'ARUS GANGGUAN';
      if (_status == 'CLOSE') return 'ARUS NORMAL';
      return 'ARUS';
    }
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _waktu,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_waktu),
    );
    if (pickedTime == null) return;

    final selected = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    if (!mounted) return;
    if (selected.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu tidak boleh melebihi saat ini')),
      );
      return;
    }

    setState(() => _waktu = selected);
  }

  void _addArus() {
    if (_arusList.length >= 4) return;
    final existingTypes = _arusList.map((a) => a['type']).toSet();
    String newType = 'Ia';
    for (final t in OpgiManuverConstants.typeArus) {
      if (!existingTypes.contains(t)) {
        newType = t;
        break;
      }
    }
    setState(() {
      _arusList.add({'type': newType, 'satuan': 'A', 'value': ''});
    });
  }

  void _removeArus(int index) {
    if (_arusList.length <= 1) return;
    setState(() {
      _arusList.removeAt(index);
    });
  }

  Future<void> _onSaveDraft() async {
    try {
      final data = {
        'tipeManuver': _tipeManuver,
        'penyulangId': _penyulangId,
        'waktu': _waktu.toIso8601String(),
        'objek': _objek,
        'status': _status,
        'posisi': _posisi,
        'operasi': _operasi,
        'jenisGangguan': _jenisGangguan,
        'keteranganPekerjaan': _keteranganController.text,
        'arus': _arusList,
        'dokumentasi_path': _dokumentasiFile?.path,
      };

      await context.read<OpgiManuverCubit>().saveDraftManuver(
            nama: widget.garduIndukNama,
            data: data,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Simpan draft berhasil!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terdapat kesalahan saat menyimpan draft'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_penyulangId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penyulang wajib dipilih'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_showStatus && (_status == null || _status!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status wajib dipilih'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_showPosisi && (_posisi == null || _posisi!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posisi wajib dipilih'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_showJenisGangguan && _jenisGangguan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis gangguan'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_showOperasi && (_operasi == null || _operasi!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih operasi (Local / Remote)'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_showKeterangan && _keteranganController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keterangan pekerjaan wajib diisi'), backgroundColor: AppColors.danger),
      );
      return;
    }

    if (_showArus) {
      if (_arusList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Masukkan data arus'), backgroundColor: AppColors.danger),
        );
        return;
      }
      final types = _arusList.map((a) => a['type']).toList();
      if (types.toSet().length != types.length) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tipe arus tidak boleh sama'), backgroundColor: AppColors.danger),
        );
        return;
      }
      for (final a in _arusList) {
        if (a['value'] == null || a['value'].toString().trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Semua nilai arus harus diisi angka'), backgroundColor: AppColors.danger),
          );
          return;
        }
      }
    }

    if (_dokumentasiFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto dokumentasi wajib diambil'), backgroundColor: AppColors.danger),
      );
      return;
    }

    // Format payload
    final payload = <String, dynamic>{
      'timezone': AppTimeUtils.deviceTimezone,
      'penyulangId': _penyulangId,
      'tipeManuver': _tipeManuver,
      'waktu': _waktu.toIso8601String(),
      'objek': _objek,
    };

    if (_showStatus && _status != null) payload['status'] = _status;
    if (_showPosisi && _posisi != null) payload['posisi'] = _posisi;
    if (_showJenisGangguan && _jenisGangguan.isNotEmpty) {
      payload['jenisGangguan'] = _jenisGangguan;
    }
    if (_showOperasi && _operasi != null) payload['operasi'] = _operasi;
    if (_showKeterangan) {
      payload['keteranganPekerjaan'] = _keteranganController.text.trim();
    }

    if (_showArus && !_isOnlyUFR) {
      payload['arus'] = _arusList.map((a) {
        return {
          'type': a['type'],
          'satuan': a['satuan'],
          'value': num.tryParse(a['value'].toString()) ?? 0,
        };
      }).toList();
    }

    context.read<OpgiManuverCubit>().submitManuver(
          payload,
          _dokumentasiFile,
          _draftId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kegiatan Manuver'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Simpan Draft',
            onPressed: _onSaveDraft,
          ),
        ],
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiManuverCubit, OpgiManuverState>(
          listener: (context, state) {
            if (state is OpgiManuverPenyulangLoaded) {
              setState(() {
                _penyulangOptions = state.penyulangList;
                _isLoadingPenyulang = false;
                if (_penyulangId == null && _penyulangOptions.isNotEmpty) {
                  _penyulangId = _penyulangOptions.first['id'] as int?;
                }
              });
            } else if (state is OpgiManuverSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
              );
              Navigator.of(context).pop(true);
            } else if (state is OpgiManuverError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.danger),
              );
            }
          },
          builder: (context, state) {
            final isSubmitting = state is OpgiManuverLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Container INFO
                    InputContainer(
                      label: 'INFO',
                      child: InputWithLabel(
                        label: 'Gardu Induk',
                        child: Text(
                          widget.garduIndukNama,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),

                    // Container MANUVER
                    InputContainer(
                      label: 'MANUVER',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipe Manuver
                          InputWithLabel(
                            label: 'Tipe Manuver',
                            child: DropdownButtonFormField<String>(
                              value: _tipeManuver,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: OpgiManuverConstants.tipeManuver.map((opt) {
                                return DropdownMenuItem(value: opt.value, child: Text(opt.label));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null && v != _tipeManuver) {
                                  setState(() {
                                    _tipeManuver = v;
                                    _status = null;
                                    _posisi = null;
                                    _operasi = null;
                                    _jenisGangguan = [];
                                    _keteranganController.clear();
                                    _arusList = [
                                      {'type': 'Ia', 'satuan': 'A', 'value': ''},
                                    ];
                                  });
                                }
                              },
                            ),
                          ),

                          // Penyulang
                          InputWithLabel(
                            label: 'Penyulang',
                            child: _isLoadingPenyulang
                                ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                                : DropdownButtonFormField<int>(
                                    value: _penyulangOptions.any((p) => p['id'] == _penyulangId)
                                        ? _penyulangId
                                        : null,
                                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih penyulang'),
                                    items: _penyulangOptions.map((p) {
                                      return DropdownMenuItem<int>(
                                        value: p['id'] as int,
                                        child: Text(p['nama']?.toString() ?? '-'),
                                      );
                                    }).toList(),
                                    onChanged: (v) => setState(() => _penyulangId = v),
                                  ),
                          ),

                          // Waktu
                          InputWithLabel(
                            label: 'Waktu',
                            child: InkWell(
                              onTap: _pickDateTime,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFD1D5DB)),
                                  color: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      DateFormat('dd MMMM yyyy HH:mm', 'id').format(_waktu),
                                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                                    ),
                                    const Icon(Icons.calendar_today, size: 18, color: Color(0xFF64748B)),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Objek
                          InputWithLabel(
                            label: 'Objek',
                            child: DropdownButtonFormField<String>(
                              value: _objek,
                              decoration: const InputDecoration(border: OutlineInputBorder()),
                              items: OpgiManuverConstants.objek.map((opt) {
                                return DropdownMenuItem(value: opt.value, child: Text(opt.label));
                              }).toList(),
                              onChanged: (v) {
                                if (v != null && v != _objek) {
                                  setState(() {
                                    _objek = v;
                                    _status = null;
                                    _posisi = null;
                                    _operasi = null;
                                    _jenisGangguan = [];
                                    _keteranganController.clear();
                                    _arusList = [
                                      {'type': 'Ia', 'satuan': 'A', 'value': ''},
                                    ];
                                  });
                                }
                              },
                            ),
                          ),

                          // Status
                          if (_showStatus) ...[
                            () {
                              final statusOpts = OpgiManuverConstants.getStatusForObjek(_objek);
                              final safeStatus = statusOpts.any((o) => o.value == _status) ? _status : null;
                              return InputWithLabel(
                                label: 'Status',
                                child: DropdownButtonFormField<String>(
                                  value: safeStatus,
                                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih status'),
                                  items: statusOpts.map((opt) {
                                    return DropdownMenuItem(value: opt.value, child: Text(opt.label));
                                  }).toList(),
                                  onChanged: (v) => setState(() => _status = v),
                                ),
                              );
                            }(),
                          ],

                          // Posisi
                          if (_showPosisi) ...[
                            () {
                              final posisiOpts = OpgiManuverConstants.getPosisiForObjek(_objek);
                              final safePosisi = posisiOpts.any((o) => o.value == _posisi) ? _posisi : null;
                              return InputWithLabel(
                                label: 'Posisi',
                                child: DropdownButtonFormField<String>(
                                  value: safePosisi,
                                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih posisi'),
                                  items: posisiOpts.map((opt) {
                                    return DropdownMenuItem(value: opt.value, child: Text(opt.label));
                                  }).toList(),
                                  onChanged: (v) => setState(() => _posisi = v),
                                ),
                              );
                            }(),
                          ],

                          // Jenis Gangguan
                          if (_showJenisGangguan) ...[
                            InputWithLabel(
                              label: 'Jenis Gangguan',
                              child: MultiSelectChips(
                                label: 'Pilih Jenis Gangguan',
                                hint: 'Pilih jenis gangguan',
                                options: OpgiManuverConstants.jenisGangguan,
                                selectedValues: _jenisGangguan,
                                onChanged: (selected) => setState(() => _jenisGangguan = selected),
                              ),
                            ),
                          ],

                          // Operasi
                          if (_showOperasi) ...[
                            () {
                              final opOpts = OpgiManuverConstants.operasi;
                              final safeOp = opOpts.any((o) => o.value == _operasi) ? _operasi : null;
                              return InputWithLabel(
                                label: 'Operasi',
                                child: DropdownButtonFormField<String>(
                                  value: safeOp,
                                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih operasi'),
                                  items: opOpts.map((opt) {
                                    return DropdownMenuItem(value: opt.value, child: Text(opt.label));
                                  }).toList(),
                                  onChanged: (v) => setState(() => _operasi = v),
                                ),
                              );
                            }(),
                          ],

                          // Keterangan Pekerjaan
                          if (_showKeterangan) ...[
                            InputWithLabel(
                              label: 'Keterangan Pekerjaan',
                              child: AppTextField(
                                controller: _keteranganController,
                                hint: 'Tulis keterangan pekerjaan',
                                maxLines: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Container ARUS
                    if (_showArus) ...[
                      InputContainer(
                        label: _arusContainerLabel,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ..._arusList.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final arus = entry.value;

                              return Container(
                                margin: EdgeInsets.only(top: idx > 0 ? 12 : 0),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  color: const Color(0xFFF8FAFC),
                                ),
                                child: Column(
                                  children: [
                                    InputWithLabel(
                                      label: 'Type',
                                      child: DropdownButtonFormField<String>(
                                        value: arus['type'] as String?,
                                        decoration: const InputDecoration(border: OutlineInputBorder()),
                                        items: OpgiManuverConstants.typeArus.map((t) {
                                          return DropdownMenuItem(value: t, child: Text(t));
                                        }).toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => arus['type'] = v);
                                          }
                                        },
                                      ),
                                    ),
                                    InputWithLabel(
                                      label: 'Satuan',
                                      child: DropdownButtonFormField<String>(
                                        value: arus['satuan'] as String?,
                                        decoration: const InputDecoration(border: OutlineInputBorder()),
                                        items: OpgiManuverConstants.satuanArus.map((s) {
                                          return DropdownMenuItem(value: s, child: Text(s));
                                        }).toList(),
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() => arus['satuan'] = v);
                                          }
                                        },
                                      ),
                                    ),
                                    InputWithLabel(
                                      label: 'Value',
                                      child: TextFormField(
                                        initialValue: arus['value']?.toString(),
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'Masukkan nilai arus',
                                        ),
                                        onChanged: (v) => arus['value'] = v,
                                      ),
                                    ),
                                    if (_arusList.length > 1)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          icon: const Icon(Icons.delete, color: AppColors.danger, size: 16),
                                          label: const Text('Hapus Arus', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                                          onPressed: () => _removeArus(idx),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }),
                            if (_arusList.length < 4) ...[
                              const SizedBox(height: 12),
                              AppButton(
                                text: 'Tambah Arus',
                                variant: ButtonVariant.outlined,
                                height: 38,
                                onPressed: _addArus,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Container DOKUMENTASI
                    InputContainer(
                      label: 'DOKUMENTASI',
                      child: FieldPictInput(
                        label: 'Foto Dokumentasi',
                        placeholder: 'Ambil Foto Manuver',
                        isRequired: true,
                        pictureFile: _dokumentasiFile,
                        onChange: (file) => setState(() => _dokumentasiFile = file),
                      ),
                    ),

                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Simpan',
                      isLoading: isSubmitting,
                      onPressed: isSubmitting ? null : _onSubmit,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
