import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/features/history_penilaian/data/models/history_penilaian_model.dart';
import 'package:super_i_mobile/features/history_penilaian/presentation/widgets/penilaian_header_card.dart';

void main() {
  group('Penilaian Historical Chart Extraction Tests', () {
    test('extractEvaluationChartPoints normalizes y values and retains originalY', () {
      final rawPoints = [
        {
          'tanggal': 1,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 20.0,
          'pointAbsensi': 60.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 2,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 40.0,
          'pointAbsensi': 100.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 3,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 120.0, // > 100
          'pointAbsensi': 100.0,
          'pointPerforma': -20.0,
        },
      ];

      final harianPoints =
          extractEvaluationChartPoints(rawPoints, 'nilaiHarian');
      expect(harianPoints.length, 3);
      expect(harianPoints[0].xLabel, '1/11/2026');
      expect(harianPoints[0].originalY, 20.0);
      expect(harianPoints[0].normalizedY, 20.0);

      expect(harianPoints[2].originalY, 120.0);
      expect(harianPoints[2].normalizedY, 100.0); // clamped to 100

      final performaPoints =
          extractEvaluationChartPoints(rawPoints, 'pointPerforma');
      expect(performaPoints[0].originalY, -20.0);
      expect(performaPoints[0].normalizedY, 0.0); // clamped to 0 for negative
    });
  });

  group('PenilaianHeaderCard Widget Tests', () {
    final mockGrafik = GrafikBulananModel(
      nilaiKinerja: 35.0,
      pointAbsensi: 90.0,
      pointPerforma: -20.0,
      status: 'SURAT PERINGATAN',
      perTanggal: 6,
      bulanString: 'November',
      tahun: 2026,
      points: [
        {
          'tanggal': 1,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 20.0,
          'pointAbsensi': 60.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 2,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 40.0,
          'pointAbsensi': 100.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 3,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 40.0,
          'pointAbsensi': 100.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 4,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 30.0,
          'pointAbsensi': 80.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 5,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 40.0,
          'pointAbsensi': 100.0,
          'pointPerforma': -20.0,
        },
        {
          'tanggal': 6,
          'bulan': 10,
          'tahun': 2026,
          'nilaiHarian': 40.0,
          'pointAbsensi': 100.0,
          'pointPerforma': -20.0,
        },
      ],
    );

    testWidgets('renders gauges, per tanggal, status, and toggle bar',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PenilaianHeaderCard(
                grafik: mockGrafik,
                bulanFallback: 10,
              ),
            ),
          ),
        ),
      );

      // Header row
      expect(find.text('Per Tanggal: 6 November 2026'), findsOneWidget);
      expect(find.text('SURAT PERINGATAN'), findsOneWidget);

      // Gauges values
      expect(find.text('90.00'), findsOneWidget);
      expect(find.text('-20.00'), findsOneWidget);
      expect(find.text('35.00'), findsOneWidget);

      // Gauges labels
      expect(find.text('Point Absensi'), findsOneWidget);
      expect(find.text('Point Performa'), findsOneWidget);
      expect(find.text('Nilai Kinerja'), findsOneWidget);

      // Toggle Bar initial state
      expect(find.text('Tampilkan'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);

      // Charts should not be visible yet
      expect(find.text('Nilai Harian'), findsNothing);

      // Tap Tampilkan to expand
      await tester.tap(find.text('Tampilkan'));
      await tester.pumpAndSettle();

      // Now toggle shows Sembunyikan
      expect(find.text('Sembunyikan'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_up), findsOneWidget);

      // All 3 chart titles must be visible
      expect(find.text('Nilai Harian'), findsOneWidget);
      expect(find.text('Point Absensi'), findsNWidgets(2)); // Gauge + Chart title
      expect(find.text('Point Performa'), findsNWidgets(2)); // Gauge + Chart title

      // Tap Sembunyikan to collapse
      await tester.tap(find.text('Sembunyikan'));
      await tester.pumpAndSettle();

      expect(find.text('Tampilkan'), findsOneWidget);
      expect(find.text('Nilai Harian'), findsNothing);
    });

    testWidgets('opens PenilaianChartFullscreenDialog when fullscreen icon is tapped',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PenilaianHeaderCard(
              grafik: mockGrafik,
              bulanFallback: 10,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.fullscreen));
      await tester.pumpAndSettle();

      // In fullscreen dialog, all 3 charts are displayed
      expect(find.text('Nilai Harian'), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);

      // Tap exit
      await tester.tap(find.byIcon(Icons.fullscreen_exit));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.fullscreen_exit), findsNothing);
    });
  });
}
