// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../../../../core/utils/app_url_utils.dart';
import '../../../../core/widgets/app_background.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/input_container.dart';
import '../constants/opgi_manuver_constants.dart';
import '../cubit/opgi_manuver_cubit.dart';
import '../widgets/multi_select_chips.dart';

class UpdateManuverProgressPage extends StatefulWidget {
  final String garduInduk;
  final int garduIndukId;
  final int manuverId;
  final String nama; // Penyulang nama
  final String tipeManuver;
  final int penyulangId;
  final Map<String, dynamic> currentData;
  final bool isLastProgress;

  const UpdateManuverProgressPage({
    super.key,
    required this.garduInduk,
    required this.garduIndukId,
    required this.manuverId,
    required this.nama,
    required this.tipeManuver,
    required this.penyulangId,
    required this.currentData,
    this.isLastProgress = false,
  });

  @override
  State<UpdateManuverProgressPage> createState() => _UpdateManuverProgressPageState();
}

class _UpdateManuverProgressPageState extends State<UpdateManuverProgressPage> {
  final _formKey = GlobalKey<FormState>();

  late int _progressId;
  late DateTime _waktu;
  late String _objek;
  String? _status;
  String? _posisi;
  List<String> _jenisGangguan = [];
  String? _operasi;
  final _keteranganController = TextEditingController();

  List<Map<String, dynamic>> _arusList = [];
  String? _dokumentasiUrl;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  void _initValues() {
    final d = widget.currentData;
    _progressId = (d['id'] as num?)?.toInt() ?? 0;

    if (d['waktu'] != null) {
      _waktu = AppTimeUtils.parseToLocal(d['waktu'].toString()) ?? DateTime.now();
    } else {
      _waktu = DateTime.now();
    }

    _objek = d['objek']?.toString() ?? 'PMT';
    _status = d['status']?.toString();
    _posisi = d['posisi']?.toString();
    _operasi = d['operasi']?.toString();
    if (d['keteranganPekerjaan'] != null) {
      _keteranganController.text = d['keteranganPekerjaan'].toString();
    }

    if (d['jenisGangguan'] is List) {
      _jenisGangguan = (d['jenisGangguan'] as List).map((e) => e.toString()).toList();
    }

    if (d['arus'] is List && (d['arus'] as List).isNotEmpty) {
      _arusList = (d['arus'] as List).map((a) {
        return {
          'type': a['type']?.toString() ?? 'Ia',
          'satuan': a['satuan']?.toString() ?? 'A',
          'value': a['value']?.toString() ?? '',
        };
      }).toList();
    } else {
      _arusList = [
        {'type': 'Ia', 'satuan': 'A', 'value': ''},
      ];
    }

    final doc = d['dokumentasi'];
    if (doc is Map<String, dynamic>) {
      _dokumentasiUrl = doc['uri']?.toString() ?? doc['url']?.toString();
    } else if (doc is String) {
      _dokumentasiUrl = doc;
    }
  }

  bool get _isOnlyUFR =>
      _jenisGangguan.length == 1 && _jenisGangguan.first == 'UFR';

  bool get _showStatus {
    if (widget.tipeManuver == 'PEKERJAAN') return true;
    if ((widget.tipeManuver == 'GANGGUAN' || widget.tipeManuver == 'TRIP OVERLOAD') &&
        _objek == 'PMT') {
      return true;
    }
    return false;
  }

  bool get _showPosisi {
    if ((widget.tipeManuver == 'GANGGUAN' || widget.tipeManuver == 'TRIP OVERLOAD') &&
        _objek.isNotEmpty &&
        _status != 'CLOSE') {
      return true;
    }
    return false;
  }

  bool get _showJenisGangguan {
    if ((widget.tipeManuver == 'GANGGUAN' || widget.tipeManuver == 'TRIP OVERLOAD') &&
        _objek == 'PMT' &&
        _status == 'OPEN') {
      return true;
    }
    return false;
  }

  bool get _showOperasi {
    if (widget.tipeManuver == 'PEKERJAAN' && _objek == 'PMT' && _status == 'OPEN') {
      return true;
    }
    return false;
  }

  bool get _showKeterangan {
    if (widget.tipeManuver == 'PEKERJAAN' && _status != 'CLOSE') {
      return true;
    }
    return false;
  }

  bool get _showArus {
    if (_objek != 'PMT' || _isOnlyUFR) return false;
    if (widget.tipeManuver == 'GANGGUAN' || widget.tipeManuver == 'TRIP OVERLOAD') {
      return true;
    }
    if (widget.tipeManuver == 'PEKERJAAN' && _status != null) {
      return true;
    }
    return false;
  }

  String get _arusContainerLabel {
    if (widget.tipeManuver == 'PEKERJAAN') {
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

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

    // Payload for patch
    final payload = <String, dynamic>{
      'timezone': AppTimeUtils.deviceTimezone,
      'waktu': _waktu.toIso8601String(),
      'objek': _objek,
      'tipeManuver': widget.tipeManuver,
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

    context.read<OpgiManuverCubit>().updateManuverProgress(_progressId, payload);
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.white,
                    child: const Text('Gagal memuat gambar'),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = AppUrlUtils.getFullImageUrl(_dokumentasiUrl);

    // CRITICAL DETAIL: Status 'CLOSE' only available if this is the last progress!
    final availableStatusOptions = OpgiManuverConstants.getStatusForObjek(
      _objek,
      excludeClose: !widget.isLastProgress,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Progress Manuver'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: AppBackground(
        child: BlocConsumer<OpgiManuverCubit, OpgiManuverState>(
          listener: (context, state) {
            if (state is OpgiManuverSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: AppColors.primary),
              );
              // CRITICAL DETAIL: If status is CLOSE, return 'CLOSE' to pop twice all the way to Manuver list
              if (state.status?.toUpperCase() == 'CLOSE' || _status?.toUpperCase() == 'CLOSE') {
                Navigator.of(context).pop('CLOSE');
              } else {
                Navigator.of(context).pop(true);
              }
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InputWithLabel(
                            label: 'Gardu Induk',
                            child: Text(
                              widget.garduInduk,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          InputWithLabel(
                            label: 'Tipe Gangguan / Manuver',
                            child: Text(
                              widget.tipeManuver,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          InputWithLabel(
                            label: 'Penyulang',
                            child: Text(
                              widget.nama,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Container MANUVER
                    InputContainer(
                      label: 'MANUVER',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tipe Manuver (Disabled)
                          InputWithLabel(
                            label: 'Tipe Manuver',
                            child: DropdownButtonFormField<String>(
                              value: widget.tipeManuver,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: widget.tipeManuver,
                                  child: Text(widget.tipeManuver),
                                ),
                              ],
                              onChanged: null,
                            ),
                          ),

                          // Penyulang (Disabled)
                          InputWithLabel(
                            label: 'Penyulang',
                            child: DropdownButtonFormField<String>(
                              value: widget.nama,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: widget.nama,
                                  child: Text(widget.nama),
                                ),
                              ],
                              onChanged: null,
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
                              final safeStatus = availableStatusOptions.any((o) => o.value == _status)
                                  ? _status
                                  : null;
                              return InputWithLabel(
                                label: 'Status',
                                child: DropdownButtonFormField<String>(
                                  value: safeStatus,
                                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Pilih status'),
                                  items: availableStatusOptions.map((opt) {
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
                              final safePosisi = posisiOpts.any((o) => o.value == _posisi)
                                  ? _posisi
                                  : null;
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
                              final safeOp = opOpts.any((o) => o.value == _operasi)
                                  ? _operasi
                                  : null;
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

                    // Container DOKUMENTASI (Read-only for update)
                    if (fullImageUrl.isNotEmpty) ...[
                      InputContainer(
                        label: 'DOKUMENTASI',
                        child: InputWithLabel(
                          label: 'Foto Dokumentasi (Tersimpan)',
                          child: GestureDetector(
                            onTap: () => _showImagePreview(context, fullImageUrl),
                            child: Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    fullImageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Text('Gagal memuat foto', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.fullscreen, color: Colors.white, size: 14),
                                          SizedBox(width: 4),
                                          Text('Perbesar', style: TextStyle(color: Colors.white, fontSize: 10)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),
                    AppButton(
                      text: 'Simpan Perubahan',
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
