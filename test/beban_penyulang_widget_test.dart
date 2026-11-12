import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/theme/app_theme.dart';
import 'package:super_i_mobile/core/widgets/input_container.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_realisasi_model.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/beban_penyulang_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/penyulang_item_card.dart';

void main() {
  group('PenyulangItemCard Widget Tests', () {
    testWidgets('renders PenyulangItemCard with name, statusCB and period chips', (tester) async {
      const penyulang = PenyulangModel(
        id: 1,
        nama: 'Penyulang Mawar',
        statusCB: 'ON',
        iMax: 600,
        rel: '2',
        garduIndukId: 5,
        garduIndukNama: 'GI Gandul',
      );

      final mappedPeriods = [
        const PenyulangMappedPeriod(
          periode: 7,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          draft: false,
          hasManuver: false,
          isDone: true,
          color: Color(0xFF22C55E),
        ),
        const PenyulangMappedPeriod(
          periode: 8,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          draft: false,
          hasManuver: false,
          isDone: false,
          color: Color(0xFF6B7280),
        ),
      ];

      bool viewClicked = false;
      bool inputClicked = false;
      PenyulangMappedPeriod? longPressedPeriod;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PenyulangItemCard(
              item: penyulang,
              mappedPeriods: mappedPeriods,
              onView: () => viewClicked = true,
              onInput: () => inputClicked = true,
              onPeriodLongPress: (p) => longPressedPeriod = p,
            ),
          ),
        ),
      );

      expect(find.text('Penyulang Mawar'), findsOneWidget);
      expect(find.text('GI Gandul'), findsOneWidget);
      expect(find.text('ON'), findsOneWidget);
      expect(find.text('07'), findsOneWidget);
      expect(find.text('08'), findsOneWidget);
      expect(find.text('Lihat'), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);

      // Tap 'Lihat'
      await tester.tap(find.text('Lihat'));
      await tester.pump();
      expect(viewClicked, isTrue);

      // Tap 'Input'
      await tester.tap(find.text('Input'));
      await tester.pump();
      expect(inputClicked, isTrue);

      // Long press chip '08'
      await tester.longPress(find.text('08'));
      await tester.pump();
      expect(longPressedPeriod, isNotNull);
      expect(longPressedPeriod?.periode, equals(8));
    });

    testWidgets('disables Input button when all periods are done or CB is OFF', (tester) async {
      const penyulang = PenyulangModel(
        id: 2,
        nama: 'Penyulang Melati',
        statusCB: 'OFF',
        iMax: 400,
        rel: '1',
        garduIndukId: 5,
        garduIndukNama: 'GI Gandul',
      );

      final mappedPeriods = [
        const PenyulangMappedPeriod(
          periode: 7,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          draft: false,
          hasManuver: false,
          isDone: false,
          color: Color(0xFF6B7280),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PenyulangItemCard(
              item: penyulang,
              mappedPeriods: mappedPeriods,
              onView: () {},
              onInput: () {},
              onPeriodLongPress: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('OFF'), findsOneWidget);

      final elevatedBtn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedBtn.onPressed, isNull); // disabled
    });
  });

  group('InputContainer & InputWithLabel Tests', () {
    testWidgets('renders InputContainer with label and child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InputContainer(
              label: 'INFO',
              child: InputWithLabel(
                label: 'Gardu Induk',
                child: Text('GI Gandul'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('Gardu Induk'), findsOneWidget);
      expect(find.text('GI Gandul'), findsOneWidget);
    });

    testWidgets('ElevatedButton in Row renders without infinite width error under AppTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Row(
              children: [
                const Expanded(child: Text('Item')),
                ElevatedButton(
                  onPressed: () {},
                  child: const Icon(Icons.delete),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('parseBebanPenyulangDrafts Tests', () {
    test('parses local drafts into clean DTO without forbidden fields', () {
      final localDrafts = [
        {
          'id': 101,
          'nama': 'Penyulang Mawar-GI Gandul',
          'data': {
            'id': 1,
            'garduIndukId': 5,
            'beban': '15.4',
            'foto': {'uri': '/path/to/foto.jpg'},
            'durasi': 2.5,
            'startTime': '2026-11-09T08:00:00Z',
            'periode': 8,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
          },
        },
      ];

      final result = parseBebanPenyulangDrafts(
        localDrafts: localDrafts,
        garduIndukId: 5,
        penyulangList: [],
      );

      expect(result.parsed.length, 1);
      final item = result.parsed.first;
      expect(item['draftId'], 101);
      expect(item['penyulangId'], 1);
      expect(item['beban'], 15); // rounded to int
      expect(item['durasi'], 2.5);
      expect(item['periode'], 8);
      expect(item['garduIndukId'], 5);
      // Ensure forbidden fields are not present in parsed item
      expect(item.containsKey('id'), isFalse);
      expect(item.containsKey('startTime'), isFalse);
    });

    test('correctly detects duplicate drafts against existing server beban', () {
      final localDrafts = [
        {
          'id': 102,
          'nama': 'Penyulang Mawar-GI Gandul',
          'data': {
            'id': 1,
            'garduIndukId': 5,
            'beban': 20,
            'foto': {'uri': '/path/to/foto.jpg'},
            'durasi': 1.0,
            'periode': 7,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
          },
        },
      ];

      final existingPenyulang = [
        const PenyulangModel(
          id: 1,
          nama: 'Penyulang Mawar',
          statusCB: 'ON',
          iMax: 600,
          rel: '1',
          garduIndukId: 5,
          garduIndukNama: 'GI Gandul',
          beban: [
            PenyulangBebanItemModel(
              id: 999,
              periode: 7,
              beban: 20,
              status: 'ON TIME',
              tanggal: 9,
              bulan: 11,
              tahun: 2026,
            ),
          ],
        ),
      ];

      final result = parseBebanPenyulangDrafts(
        localDrafts: localDrafts,
        garduIndukId: 5,
        penyulangList: existingPenyulang,
      );

      expect(result.parsed, isEmpty);
      expect(result.duplicates, contains(102));
    });
  });
}
