import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_colors.dart';
import '../utils/app_url_utils.dart';

/// Komponen input tanda tangan digital terpadu yang menyamakan alur persis dengan
/// komponen `Signature` dan `ImageDisplay` pada aplikasi legacy `super-i-mobile`.
class FieldSignatureInput extends StatelessWidget {
  final String label;
  final bool isRequired;
  final File? signatureFile;
  final String? signatureUrl;
  final String? signerName;
  final ValueChanged<File?> onSignatureChanged;
  final ValueChanged<String>? onNameChanged;
  final String? error;
  final bool readOnlyName;

  const FieldSignatureInput({
    super.key,
    required this.label,
    this.isRequired = false,
    this.signatureFile,
    this.signatureUrl,
    this.signerName,
    required this.onSignatureChanged,
    this.onNameChanged,
    this.error,
    this.readOnlyName = false,
  });

  bool get hasSignature =>
      signatureFile != null || (signatureUrl != null && signatureUrl!.isNotEmpty);

  void _openSignatureModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _SignatureModal(
        title: label,
        initialName: signerName ?? '',
        isRequired: isRequired,
        readOnlyName: readOnlyName,
        onSave: (file, name) {
          onSignatureChanged(file);
          onNameChanged?.call(name);
        },
      ),
    );
  }

  void _handleDelete() {
    onSignatureChanged(null);
    onNameChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Header
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Tampilan 1: Sudah ada TTD (ImageDisplay Card)
        if (hasSignature)
          _buildSignedCard(context)
        // Tampilan 2: Belum ada TTD (Input Button)
        else
          _buildUnsignedButton(context),

        // Pesan Error jika ada
        if (error != null && error!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: const TextStyle(
              color: AppColors.danger,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Tombol input saat belum ada tanda tangan (persis Button variant="ghost" di super-i-mobile)
  Widget _buildUnsignedButton(BuildContext context) {
    return InkWell(
      onTap: () => _openSignatureModal(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: error != null ? AppColors.danger : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tanda tangan',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              Icons.edit_note,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Kartu preview tanda tangan setelah tersimpan (persis ImageDisplay di super-i-mobile)
  Widget _buildSignedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error != null ? AppColors.danger : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Gambar TTD
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: signatureFile != null
                  ? Image.file(
                      signatureFile!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Image.network(
                      AppUrlUtils.ensureHttps(signatureUrl ?? ''),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
            ),
          ),

          // Nama Penandatangan di bawah gambar
          if (signerName != null && signerName!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              signerName!.trim(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Baris tombol: Hapus & Edit
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: _handleDelete,
                    child: const Text(
                      'Hapus',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _openSignatureModal(context),
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modal Input Nama dan Kanvas Tanda Tangan
class _SignatureModal extends StatefulWidget {
  final String title;
  final String initialName;
  final bool isRequired;
  final bool readOnlyName;
  final void Function(File file, String name) onSave;

  const _SignatureModal({
    required this.title,
    required this.initialName,
    required this.isRequired,
    required this.readOnlyName,
    required this.onSave,
  });

  @override
  State<_SignatureModal> createState() => _SignatureModalState();
}

class _SignatureModalState extends State<_SignatureModal> {
  late final TextEditingController _nameController;
  final List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];
  String? _nameError;
  String? _canvasError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _canvasError = null;
      _currentLine = [details.localPosition];
      _lines.add(_currentLine);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentLine.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // Jika hanya satu titik (tap), tambahkan titik offset kecil agar terlihat sebagai dot
    if (_currentLine.length == 1) {
      setState(() {
        _currentLine.add(
          Offset(_currentLine.first.dx + 0.1, _currentLine.first.dy + 0.1),
        );
      });
    }
    _currentLine = [];
  }

  void _clearCanvas() {
    setState(() {
      _lines.clear();
      _currentLine.clear();
      _canvasError = null;
    });
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (widget.isRequired && name.isEmpty) {
      setState(() => _nameError = 'Nama penandatangan wajib diisi');
      return;
    }

    if (_lines.isEmpty) {
      setState(() => _canvasError = 'Goreskan tanda tangan pada area kanvas');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Render gambar dari goresan kanvas ke resolusi tinggi
      const double width = 600;
      const double height = 300;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, width, height));

      // Latar belakang putih bersih
      final bgPaint = Paint()..color = Colors.white;
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

      // Gambar garis tanda tangan dengan goresan halus (anti-aliased)
      final linePaint = Paint()
        ..color = Colors.black
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 4.0;

      for (final line in _lines) {
        if (line.isEmpty) continue;
        if (line.length == 1) {
          canvas.drawCircle(line[0], 2.0, linePaint);
        } else {
          for (int i = 0; i < line.length - 1; i++) {
            canvas.drawLine(line[i], line[i + 1], linePaint);
          }
        }
      }

      final picture = recorder.endRecording();
      final uiImage = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Gagal mengonversi tanda tangan ke PNG');
      }

      final bytes = byteData.buffer.asUint8List();

      // 2. Simpan ke file PNG sementara di cache directory (persis super-i-mobile)
      final tempDir = await getTemporaryDirectory();
      final fileName = 'signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        widget.onSave(file, name);
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SIGNATURE ERROR] $e');
      }
      if (mounted) {
        setState(() {
          _isSaving = false;
          _canvasError = 'Gagal menyimpan tanda tangan';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const Divider(height: 16),

            // 1. Input Nama Penandatangan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  readOnly: widget.readOnlyName,
                  decoration: InputDecoration(
                    hintText: 'Tulis nama',
                    errorText: _nameError,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Kanvas Tanda Tangan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tanda tangan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _canvasError != null
                          ? AppColors.danger
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: CustomPaint(
                        painter: _CanvasPainter(lines: _lines),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),

                if (_canvasError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _canvasError!,
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // Tombol Hapus Kanvas (Merah) persis super-i-mobile
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                      ),
                      onPressed: _lines.isEmpty ? null : _clearCanvas,
                      child: const Text(
                        'Hapus',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 3. Tombol Simpan
            SizedBox(
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSaving ? null : _handleSave,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<List<Offset>> lines;

  _CanvasPainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3.0;

    for (final line in lines) {
      if (line.isEmpty) continue;
      if (line.length == 1) {
        canvas.drawCircle(line[0], 1.5, paint);
      } else {
        for (int i = 0; i < line.length - 1; i++) {
          canvas.drawLine(line[i], line[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) => true;
}

/// Backward compatibility alias agar kode lama yang memanggil `FieldSignaturePad.show` tidak error
class FieldSignaturePad {
  static Future<String?> show(
    BuildContext context, {
    String title = 'Tanda Tangan Digital',
    String signerName = '',
  }) async {
    String? resultBase64;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) => _SignatureModal(
        title: title,
        initialName: signerName,
        isRequired: false,
        readOnlyName: false,
        onSave: (file, name) async {
          final bytes = await file.readAsBytes();
          resultBase64 = 'data:image/png;base64,${base64Encode(bytes)}';
        },
      ),
    );
    return resultBase64;
  }
}
