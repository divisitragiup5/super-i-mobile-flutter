import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Komponen tanda tangan digital interaktif (Digital Signature Pad)
class FieldSignaturePad extends StatefulWidget {
  final String title;
  final String signerName;

  const FieldSignaturePad({
    super.key,
    this.title = 'Tanda Tangan Digital',
    this.signerName = '',
  });

  /// Helper untuk membuka dialog tanda tangan dan mengembalikan String Base64 PNG
  static Future<String?> show(
    BuildContext context, {
    String title = 'Tanda Tangan Digital',
    String signerName = '',
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FieldSignaturePad(
        title: title,
        signerName: signerName,
      ),
    );
  }

  @override
  State<FieldSignaturePad> createState() => _FieldSignaturePadState();
}

class _FieldSignaturePadState extends State<FieldSignaturePad> {
  final List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
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
    _currentLine = [];
  }

  void _clear() {
    setState(() {
      _lines.clear();
      _currentLine.clear();
    });
  }

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() {
        _lines.removeLast();
      });
    }
  }

  Future<void> _save() async {
    if (_lines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan buat tanda tangan terlebih dahulu')),
      );
      return;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, 400, 200));

    // Latar belakang putih
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 400, 200), bgPaint);

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;

    for (final line in _lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], linePaint);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(400, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData != null && mounted) {
      final bytes = byteData.buffer.asUint8List();
      final base64String = 'data:image/png;base64,${base64Encode(bytes)}';
      Navigator.pop(context, base64String);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.signerName.isNotEmpty)
                        Text(
                          widget.signerName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Area Kanvas Gambar Tanda Tangan
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    painter: _SignaturePainter(lines: _lines),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Tombol Toolbar
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: _undo,
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Undo'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Hapus'),
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _save,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> lines;

  _SignaturePainter({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
