import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/features/home/presentation/widgets/performance_trend_chart_sheet.dart';
import 'package:super_i_mobile/features/line_walker/data/models/line_walker_performance_model.dart';

void main() {
  group('LineWalkerPerformanceModel Trends Extraction Tests', () {
    test('getTrendPoints extracts and maps multiple trend keys correctly', () {
      final json = {
        'score': 88.5,
        'kategoriPerformaTenagaKerja': 'top-perform',
        'penilaian': ['PENCAPAIAN', 'COC', 'ABSENSI', 'DURASI'],
        'trends': [
          {
            'bulan': 'JANUARI',
            'tahun': 2026,
            'score': 80.254,
            'kepatuhan': 22.0,
            'coc': 18.5,
            'absensi': 25.0,
            'durasi': 14.75,
          },
          {
            'bulan': 'FEBRUARI',
            'tahun': 2026,
            'score': 88.50,
            'kepatuhan': 25.0,
            'coc': 20.0,
            'absensi': 25.0,
            'durasi': 18.5,
          },
        ],
      };

      final model = LineWalkerPerformanceModel.fromJson(json);

      expect(model.trends.length, 2);

      // 1. Score Points
      final scorePoints = model.getTrendPoints('score');
      expect(scorePoints.length, 2);
      expect(scorePoints[0].label, 'JAN 2026');
      expect(scorePoints[0].value, 80.25);
      expect(scorePoints[1].label, 'FEB 2026');
      expect(scorePoints[1].value, 88.50);

      // 2. Kepatuhan Points
      final kepatuhanPoints = model.getTrendPoints('kepatuhan');
      expect(kepatuhanPoints.length, 2);
      expect(kepatuhanPoints[0].value, 22.0);
      expect(kepatuhanPoints[1].value, 25.0);

      // 3. COC Points
      final cocPoints = model.getTrendPoints('coc');
      expect(cocPoints[0].value, 18.5);
      expect(cocPoints[1].value, 20.0);

      // 4. Absensi Points
      final absensiPoints = model.getTrendPoints('absensi');
      expect(absensiPoints[0].value, 25.0);
      expect(absensiPoints[1].value, 25.0);

      // 5. Durasi Points
      final durasiPoints = model.getTrendPoints('durasi');
      expect(durasiPoints[0].value, 14.75);
      expect(durasiPoints[1].value, 18.50);
    });

    test('getTrendPoints handles empty trends safely', () {
      const model = LineWalkerPerformanceModel(
        score: 0.0,
        kategoriPerformaTenagaKerja: 'top-perform',
        penilaian: [],
        trends: [],
      );

      expect(model.getTrendPoints('score'), isEmpty);
    });
  });

  group('PerformanceTrendChartSheet Widget Tests', () {
    testWidgets('renders empty state when points are empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceTrendChartSheet(
              title: 'Performa Tenaga Kerja',
              points: [],
            ),
          ),
        ),
      );

      expect(find.text('Performa Tenaga Kerja'), findsOneWidget);
      expect(find.text('Data tren performa belum tersedia'), findsOneWidget);
    });

    testWidgets('renders latest value, badge, and chart painter when points are provided', (tester) async {
      const points = [
        TrendDataPoint(label: 'JAN 2026', bulan: 'JANUARI', tahun: 2026, value: 75.0),
        TrendDataPoint(label: 'FEB 2026', bulan: 'FEBRUARI', tahun: 2026, value: 85.5),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PerformanceTrendChartSheet(
              title: 'Pencapaian Inspeksi',
              points: points,
            ),
          ),
        ),
      );

      expect(find.text('Pencapaian Inspeksi'), findsOneWidget);
      expect(find.text('Nilai Terakhir'), findsOneWidget);
      expect(find.text('85.50'), findsOneWidget);
      expect(find.text('+10.50'), findsOneWidget); // diff between 85.5 and 75.0
      expect(find.byType(CustomPaint), findsWidgets);

      // Test tapping on chart to select closest point
      await tester.tap(find.byType(CustomPaint).last);
      await tester.pump();
    });
  });
}
