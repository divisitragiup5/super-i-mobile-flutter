import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../../core/theme/app_colors.dart';
import '../../data/models/history_penilaian_model.dart';

/// Model titik data grafik penilaian harian
class EvaluationChartPoint {
  final String xLabel;
  final double normalizedY; // 0..100 untuk skala koordinat y pada chart
  final double originalY; // Nilai asli aktual (bisa negatif atau > 100)

  const EvaluationChartPoint({
    required this.xLabel,
    required this.normalizedY,
    required this.originalY,
  });
}

/// Helper untuk mengekstrak dan menormalisasi titik data grafik
List<EvaluationChartPoint> extractEvaluationChartPoints(
  List<Map<String, dynamic>> points,
  String key,
) {
  final list = <EvaluationChartPoint>[];
  for (final p in points) {
    if (p[key] == null) continue;
    final numVal = p[key];
    final double original = (numVal is num)
        ? numVal.toDouble()
        : double.tryParse('$numVal') ?? 0.0;

    // Normalisasi ke domain 0 - 100 seperti di super-i-mobile
    final double normalized =
        original < 0 ? 0.0 : (original > 100 ? 100.0 : original);

    final int tanggal = (p['tanggal'] as num?)?.toInt() ?? 1;
    final int bulan = (p['bulan'] as num?)?.toInt() ?? 0;
    final int tahun =
        (p['tahun'] as num?)?.toInt() ?? DateTime.now().year;

    list.add(
      EvaluationChartPoint(
        xLabel: '$tanggal/${bulan + 1}/$tahun',
        normalizedY: normalized,
        originalY: original,
      ),
    );
  }
  return list;
}

/// Kartu Header Detail Penilaian (Menampilkan Gauges + Accordion Grafik Harian)
class PenilaianHeaderCard extends StatefulWidget {
  final GrafikBulananModel grafik;
  final int bulanFallback;

  const PenilaianHeaderCard({
    super.key,
    required this.grafik,
    required this.bulanFallback,
  });

  @override
  State<PenilaianHeaderCard> createState() => _PenilaianHeaderCardState();
}

class _PenilaianHeaderCardState extends State<PenilaianHeaderCard> {
  bool _showCharts = false;

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'AMAN':
        return const Color(0xFF10B981); // Green 500
      case 'SURAT TEGURAN':
        return const Color(0xFFF59E0B); // Amber 500
      case 'SURAT PERINGATAN':
        return const Color(0xFFEF4444); // Red 500
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatPerTanggal(GrafikBulananModel g) {
    String monthName = g.bulanString.trim();
    if (monthName.isEmpty) {
      final dt = DateTime(g.tahun, widget.bulanFallback + 1, g.perTanggal);
      monthName = DateFormat('MMMM', 'id_ID').format(dt);
    } else {
      // Capitalize first letter
      monthName = monthName[0].toUpperCase() + monthName.substring(1);
    }
    return 'Per Tanggal: ${g.perTanggal} $monthName ${g.tahun}';
  }

  void _openFullscreen() {
    PenilaianChartFullscreenDialog.show(
      context,
      title: _formatPerTanggal(widget.grafik),
      points: widget.grafik.points,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.grafik.status);
    final perTanggalText = _formatPerTanggal(widget.grafik);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Row (Per Tanggal & Status)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  perTanggalText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Text(
                widget.grafik.status,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Three Circular Gauges
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildGaugeItem(
                label: 'Point Absensi',
                value: widget.grafik.pointAbsensi,
              ),
              _buildGaugeItem(
                label: 'Point Performa',
                value: widget.grafik.pointPerforma,
              ),
              _buildGaugeItem(
                label: 'Nilai Kinerja',
                value: widget.grafik.nilaiKinerja,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Toggle Bar (Sembunyikan / Tampilkan + Separator + Fullscreen Icon)
          Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _showCharts = !_showCharts;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _showCharts ? 'Sembunyikan' : 'Tampilkan',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Icon(
                        _showCharts
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: const Color(0xFF64748B),
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _openFullscreen,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.fullscreen,
                    color: Color(0xFF64748B),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          // 4. Expandable Charts Box
          if (_showCharts) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSingleChartSection(
                    title: 'Nilai Harian',
                    points: extractEvaluationChartPoints(
                      widget.grafik.points,
                      'nilaiHarian',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSingleChartSection(
                    title: 'Point Absensi',
                    points: extractEvaluationChartPoints(
                      widget.grafik.points,
                      'pointAbsensi',
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSingleChartSection(
                    title: 'Point Performa',
                    points: extractEvaluationChartPoints(
                      widget.grafik.points,
                      'pointPerforma',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGaugeItem({
    required String label,
    required double value,
  }) {
    // Normalisasi progress: nilai negatif atau 0 tidak mengisi arc
    final double clamped = (value / 100.0).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 84,
          height: 84,
          child: CustomPaint(
            painter: _CircularGaugePainter(
              progress: clamped,
              trackColor: const Color(0xFFFED7AA), // Light peach/orange track
              progressColor: const Color(0xFFF97316), // Orange 500
              strokeWidth: 5.5,
            ),
            child: Center(
              child: Text(
                value.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleChartSection({
    required String title,
    required List<EvaluationChartPoint> points,
    bool isFullscreen = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        if (points.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Data belum tersedia',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final double minWidth = points.length * 48.0;
              final double actualWidth =
                  math.max(constraints.maxWidth, minWidth);
              final double chartHeight = isFullscreen ? 240.0 : 155.0;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: actualWidth > constraints.maxWidth
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: actualWidth,
                  height: chartHeight,
                  child: CustomPaint(
                    size: Size(actualWidth, chartHeight),
                    painter: EvaluationLineChartPainter(points: points),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// CustomPainter untuk menggambar Gauge Lingkaran persis seperti di React Native SVG
class _CircularGaugePainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircularGaugePainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // 2. Active Progress Arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2; // Mulai dari atas jam 12
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor;
  }
}

/// CustomPainter untuk menggambar grafik garis evaluasi harian (VictoryChart style)
class EvaluationLineChartPainter extends CustomPainter {
  final List<EvaluationChartPoint> points;

  EvaluationLineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const double leftPadding = 24.0;
    const double rightPadding = 24.0;
    const double topPadding = 24.0;
    const double bottomPadding = 48.0;

    final double chartWidth = size.width - leftPadding - rightPadding;
    final double chartHeight = size.height - topPadding - bottomPadding;
    final double yBaseline = topPadding + chartHeight;

    // 1. Gambar Garis Sumbu X Horizontal (Baseline)
    final axisPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(leftPadding - 8, yBaseline),
      Offset(size.width - rightPadding + 8, yBaseline),
      axisPaint,
    );

    // 2. Hitung Titik Koordinat
    final List<Offset> coords = [];
    final double stepX =
        points.length > 1 ? chartWidth / (points.length - 1) : 0.0;

    for (int i = 0; i < points.length; i++) {
      final double x = points.length > 1
          ? leftPadding + i * stepX
          : leftPadding + chartWidth / 2;

      // Domain chart [0, 100]
      final double normY = points[i].normalizedY / 100.0;
      final double y = yBaseline - (normY * chartHeight);
      coords.add(Offset(x, y));
    }

    // 3. Gambar Garis Kurva Halus (Monotone Cubic Bezier)
    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6) // Vibrant Blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (coords.length > 1) {
      final path = Path();
      path.moveTo(coords.first.dx, coords.first.dy);

      for (int i = 0; i < coords.length - 1; i++) {
        final p0 = coords[i];
        final p1 = coords[i + 1];
        final cp1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
        final cp2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
      canvas.drawPath(path, linePaint);
    } else if (coords.length == 1) {
      canvas.drawLine(
        Offset(coords.first.dx - 12, coords.first.dy),
        Offset(coords.first.dx + 12, coords.first.dy),
        linePaint,
      );
    }

    // 4. Gambar Titik Scatter (Circles), Nilai di Atas, dan Label Tanggal Sumbu X
    final dotPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.fill;

    final tickPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.0;

    for (int i = 0; i < points.length; i++) {
      final p = coords[i];
      final item = points[i];

      // Gambar Tick di sumbu X
      canvas.drawLine(
        Offset(p.dx, yBaseline),
        Offset(p.dx, yBaseline + 4.5),
        tickPaint,
      );

      // Gambar Titik Scatter
      canvas.drawCircle(p, 4.0, dotPaint);

      // Gambar Label Nilai Asli (misal: "20.00", "-20.00") di atas titik
      final valSpan = TextSpan(
        text: item.originalY.toStringAsFixed(2),
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      );
      final valTp = TextPainter(
        text: valSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      valTp.layout();
      final double valY = math.max(2.0, p.dy - valTp.height - 4);
      valTp.paint(canvas, Offset(p.dx - valTp.width / 2, valY));

      // Gambar Tanggal Sumbu X berotasi ~60 derajat
      final dateSpan = TextSpan(
        text: item.xLabel,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 8.5,
          fontWeight: FontWeight.w500,
        ),
      );
      final dateTp = TextPainter(
        text: dateSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      dateTp.layout();

      canvas.save();
      canvas.translate(p.dx, yBaseline + 6);
      canvas.rotate(math.pi / 3); // 60 derajat
      dateTp.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant EvaluationLineChartPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}

/// Dialog Layar Penuh (Fullscreen Landscape) untuk melihat grafik secara mendetail
class PenilaianChartFullscreenDialog extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> points;

  const PenilaianChartFullscreenDialog({
    super.key,
    required this.title,
    required this.points,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required List<Map<String, dynamic>> points,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PenilaianChartFullscreenDialog(
          title: title,
          points: points,
        ),
      ),
    );
  }

  @override
  State<PenilaianChartFullscreenDialog> createState() =>
      _PenilaianChartFullscreenDialogState();
}

class _PenilaianChartFullscreenDialogState
    extends State<PenilaianChartFullscreenDialog> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nilaiHarian =
        extractEvaluationChartPoints(widget.points, 'nilaiHarian');
    final pointAbsensi =
        extractEvaluationChartPoints(widget.points, 'pointAbsensi');
    final pointPerforma =
        extractEvaluationChartPoints(widget.points, 'pointPerforma');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen_exit),
            tooltip: 'Tutup Layar Penuh',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFullscreenChartCard('Nilai Harian', nilaiHarian),
              const SizedBox(height: 24),
              _buildFullscreenChartCard('Point Absensi', pointAbsensi),
              const SizedBox(height: 24),
              _buildFullscreenChartCard('Point Performa', pointPerforma),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullscreenChartCard(
    String title,
    List<EvaluationChartPoint> points,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 12),
          if (points.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Data belum tersedia',
                  style: TextStyle(color: Color(0xFF94A3B8)),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final double minWidth = points.length * 56.0;
                final double actualWidth =
                    math.max(constraints.maxWidth, minWidth);
                const double chartHeight = 220.0;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: actualWidth,
                    height: chartHeight,
                    child: CustomPaint(
                      size: Size(actualWidth, chartHeight),
                      painter: EvaluationLineChartPainter(points: points),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
