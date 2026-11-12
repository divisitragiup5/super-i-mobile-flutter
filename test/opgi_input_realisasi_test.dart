import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_realisasi_model.dart';
import 'package:super_i_mobile/features/opgi/domain/repositories/opgi_repository.dart';
import 'package:super_i_mobile/features/opgi/presentation/cubit/opgi_realisasi_cubit.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/update_beban_trafo_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/update_tegangan_trafo_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/beban_trafo_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/beban_penyulang_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/tegangan_trafo_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/kwh_harian_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/penyulang_item_card.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/trafo_item_card.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/tegangan_trafo_item_card.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/kwh_item_card.dart';

import 'package:super_i_mobile/core/widgets/loading_indicator.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/data_beban_penyulang_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/update_kwh_harian_page.dart';

class _FakeOpgiRepository implements OpgiRepository {
  List<BebanPenyulangTodayItemModel> bebanPenyulangTodayItems = [];
  List<BebanTrafoTodayItemModel> bebanTrafoTodayItems = [];
  List<TeganganTrafoTodayItemModel> teganganTrafoTodayItems = [];
  List<KwhHarianModel> kwhHarianList = [];
  List<KwhHarianTodayItemModel> kwhHarianTodayItems = [];
  Map<String, dynamic>? nextUpdateBebanResponse;
  Map<String, dynamic>? nextUpdateTeganganResponse;
  Map<String, dynamic>? nextSubmitKwhResponse;
  Map<String, dynamic>? nextUpdateKwhResponse;

  @override
  Future<List<BebanPenyulangTodayItemModel>> getBebanPenyulangToday(
    int penyulangId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    return bebanPenyulangTodayItems;
  }

  @override
  Future<List<BebanTrafoTodayItemModel>> getBebanTrafoToday(
    int trafoId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    return bebanTrafoTodayItems;
  }

  @override
  Future<List<TeganganTrafoTodayItemModel>> getTeganganTrafoToday(
    int trafoId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    return teganganTrafoTodayItems;
  }

  @override
  Future<Map<String, dynamic>?> updateBebanTrafoMobile(
    int bebanId, {
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    return nextUpdateBebanResponse ?? {
      'id': bebanId,
      'beban': data['beban'],
      'durasi': data['durasi'],
    };
  }

  @override
  Future<Map<String, dynamic>?> updateTeganganTrafoMobile(
    int teganganId, {
    dynamic fileMV,
    dynamic fileHV,
    required Map<String, dynamic> data,
  }) async {
    return nextUpdateTeganganResponse ?? {
      'id': teganganId,
      'mv': data['mv'],
      'hv': data['hv'],
      'durasi': data['durasi'],
    };
  }

  @override
  Future<List<KwhHarianModel>> getKwhHarianList(
    int garduIndukId, {
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    return kwhHarianList;
  }

  @override
  Future<List<KwhHarianTodayItemModel>> getKwhHarianToday(
    int objectId, {
    required String type,
    required String kelompok,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    return kwhHarianTodayItems;
  }

  @override
  Future<Map<String, dynamic>?> submitKwhHarianSingle({
    required List<Map<String, dynamic>> filesWithJenis,
    required Map<String, dynamic> data,
  }) async {
    return nextSubmitKwhResponse ?? {
      'data': [
        {
          'id': 1,
          'jenis': 'H',
          'stand': 100.0,
        }
      ]
    };
  }

  @override
  Future<Map<String, dynamic>?> updateKwhHarianMobile(
    int id, {
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    return nextUpdateKwhResponse ?? {
      'id': id,
      'stand': data['stand'],
      'keterangan': data['keterangan'],
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Beban Trafo Tests', () {
    testWidgets('renders TrafoItemCard with name, capacity and period chips', (tester) async {
      const trafo = BebanTrafoModel(
        id: 10,
        nama: 'Trafo 1',
        iMax: 60.0,
        garduIndukId: 1,
        garduIndukNama: 'GI Gandul',
        beban: [],
      );

      final mappedPeriods = [
        const TrafoMappedPeriod(
          periode: 7,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          draft: false,
          isDone: true,
          color: Color(0xFF22C55E),
        ),
        const TrafoMappedPeriod(
          periode: 8,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          draft: false,
          isDone: false,
          color: Color(0xFF6B7280),
        ),
      ];

      bool viewTapped = false;
      bool inputTapped = false;
      TrafoMappedPeriod? longPressed;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrafoItemCard(
              item: trafo,
              mappedPeriods: mappedPeriods,
              onView: () => viewTapped = true,
              onInput: () => inputTapped = true,
              onPeriodLongPress: (p) => longPressed = p,
            ),
          ),
        ),
      );

      expect(find.text('Trafo 1'), findsOneWidget);
      expect(find.text('GI Gandul'), findsOneWidget);
      expect(find.text('iMax: 60 A'), findsOneWidget);
      expect(find.text('07'), findsOneWidget);
      expect(find.text('08'), findsOneWidget);
      expect(find.text('Lihat'), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);

      await tester.tap(find.text('Lihat'));
      await tester.pump();
      expect(viewTapped, isTrue);

      await tester.tap(find.text('Input'));
      await tester.pump();
      expect(inputTapped, isTrue);

      await tester.longPress(find.text('08'));
      await tester.pump();
      expect(longPressed, isNotNull);
      expect(longPressed?.periode, equals(8));
    });

    test('isValidDecimal correctly validates decimal inputs', () {
      expect(isValidDecimal('123'), isTrue);
      expect(isValidDecimal('123.45'), isTrue);
      expect(isValidDecimal('0.5'), isTrue);
      expect(isValidDecimal('abc'), isFalse);
      expect(isValidDecimal(''), isTrue);
      expect(isValidDecimal('12.34.56'), isFalse);
    });

    test('parseBebanTrafoDrafts extracts clean DTO without non-whitelisted fields', () {
      final rawDrafts = [
        {
          'id': 101,
          'nama': 'Trafo 1',
          'data': {
            'id': 10,
            'draftId': 101,
            'startTime': '2026-11-09T08:00:00Z',
            'garduIndukId': 1,
            'beban': 150.5,
            'durasi': 12.0,
            'periode': 7,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
            'foto': {'uri': '/data/user/0/app/cache/foto.jpg'},
          },
        },
      ];

      final result = parseBebanTrafoDrafts(
        localDrafts: rawDrafts,
        garduIndukId: 1,
        mappedData: const [],
      );

      expect(result.parsed.length, equals(1));
      expect(result.parsed.first['draftId'], equals(101));
      expect(result.parsed.first['file'], equals('/data/user/0/app/cache/foto.jpg'));

      final data = result.parsed.first['data'] as Map<String, dynamic>;
      expect(data.containsKey('id'), isFalse);
      expect(data.containsKey('draftId'), isFalse);
      expect(data.containsKey('startTime'), isFalse);
      expect(data['trafoId'], equals(10));
      expect(data['beban'], equals(151));
      expect(data['periode'], equals(7));
    });

    testWidgets('UpdateBebanTrafoPage leaves fields empty and requires new photo', (tester) async {
      final repo = _FakeOpgiRepository();
      final cubit = OpgiRealisasiCubit(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const UpdateBebanTrafoPage(
              params: {
                'id': 10,
                'nama': 'Trafo 1',
                'iMax': 60.0,
                'garduInduk': 'GI Gandul',
                'garduIndukId': 1,
                'periode': 7,
                'bebanId': 101,
                'lastBeban': 120, // should not prefill
              },
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);

      // Tap Simpan without photo -> shows error
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Foto wajib diambil'), findsOneWidget);
    });

    test('updateBebanTrafoMobile optimistically updates in-memory today list', () async {
      final repo = _FakeOpgiRepository();
      repo.bebanTrafoTodayItems = [
        const BebanTrafoTodayItemModel(
          id: 50,
          trafoId: 10,
          trafoNama: 'Trafo 1',
          periode: 7,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 100,
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadBebanTrafoToday(10, 1);
      expect(cubit.cachedBebanTrafoTodayList.first.beban, equals(100));

      // Call update
      await cubit.updateBebanTrafoMobile(
        bebanId: 50,
        file: 'dummy_photo.jpg',
        data: {'beban': 250},
      );

      // Verify optimistic update in memory
      expect(cubit.cachedBebanTrafoTodayList.first.beban, equals(250));
      expect(cubit.cachedBebanTrafoTodayList.first.trafoNama, equals('Trafo 1'));
    });
  });

  group('Tegangan Trafo Tests', () {
    testWidgets('renders TeganganTrafoItemCard with name and period chips', (tester) async {
      const item = TeganganTrafoModel(
        id: 20,
        nama: 'Trafo 2 (Tegangan)',
        garduIndukId: 1,
        garduIndukNama: 'GI Gandul',
        tegangan: [],
      );

      final mappedPeriods = [
        const TeganganTrafoMappedPeriod(
          periode: 10,
          tanggal: 9,
          bulan: 11,
          tahun: 2026,
          draft: false,
          isDone: true,
          color: Color(0xFF22C55E),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeganganTrafoItemCard(
              item: item,
              mappedPeriods: mappedPeriods,
              onView: () {},
              onInput: () {},
              onPeriodLongPress: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Trafo 2 (Tegangan)'), findsOneWidget);
      expect(find.text('GI Gandul'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    test('checkTeganganThresholds correctly flags normal and abnormal values', () {
      final normal = checkTeganganThresholds(isPS: false, mv: 20.5, hv: 150.0);
      expect(normal, isEmpty);

      final lowMv = checkTeganganThresholds(isPS: false, mv: 19.5, hv: 150.0);
      expect(lowMv.length, equals(1));
      expect(lowMv.first, contains('Tegangan MV kurang dari'));

      final lowHv = checkTeganganThresholds(isPS: false, mv: 20.5, hv: 130.0);
      expect(lowHv.length, equals(1));
      expect(lowHv.first, contains('Tegangan HV kurang dari'));
    });

    test('parseTeganganTrafoDrafts cleanses draft payload and handles MV/HV photos', () {
      final rawDrafts = [
        {
          'id': 202,
          'nama': 'Trafo 2',
          'data': {
            'id': 20,
            'draftId': 202,
            'garduIndukId': 1,
            'mv': 20.5,
            'hv': 150.0,
            'durasi': 10.0,
            'periode': 10,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
            'fotoMV': {'uri': '/cache/fotoMV.jpg'},
            'fotoHV': {'uri': '/cache/fotoHV.jpg'},
          },
        },
      ];

      final result = parseTeganganTrafoDrafts(
        localDrafts: rawDrafts,
        garduIndukId: 1,
        mappedData: const [],
      );

      expect(result.parsed.length, equals(1));
      expect(result.parsed.first['draftId'], equals(202));
      expect(result.parsed.first['fotoMV'], equals('/cache/fotoMV.jpg'));
      expect(result.parsed.first['fotoHV'], equals('/cache/fotoHV.jpg'));

      final data = result.parsed.first['data'] as Map<String, dynamic>;
      expect(data.containsKey('id'), isFalse);
      expect(data.containsKey('draftId'), isFalse);
      expect(data['trafoId'], equals(20));
      expect(data['mv'], equals(20.5));
      expect(data['hv'], equals(150.0));
    });

    testWidgets('UpdateTeganganTrafoPage leaves fields empty and requires new photos', (tester) async {
      final repo = _FakeOpgiRepository();
      final cubit = OpgiRealisasiCubit(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const UpdateTeganganTrafoPage(
              params: {
                'id': 20,
                'nama': 'Trafo 2',
                'garduInduk': 'GI Gandul',
                'garduIndukId': 1,
                'periode': 10,
                'teganganId': 202,
                'lastMv': 20.1, // should not prefill
                'lastHv': 150.0, // should not prefill
              },
            ),
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(textFields.length, equals(2));
      expect(textFields[0].controller?.text, isEmpty);
      expect(textFields[1].controller?.text, isEmpty);

      // Verify normal range text is rendered below inputs
      expect(find.text('Ambang batas normal tegangan MV: 20.24 - 20.76'), findsOneWidget);
      expect(find.text('Ambang batas normal tegangan HV: 142.5 - 157.5'), findsOneWidget);

      // Tap Simpan without photo -> shows error
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Foto MV wajib diambil'), findsOneWidget);
    });

    test('updateTeganganTrafoMobile optimistically updates in-memory today list', () async {
      final repo = _FakeOpgiRepository();
      repo.teganganTrafoTodayItems = [
        const TeganganTrafoTodayItemModel(
          id: 60,
          trafoId: 20,
          trafoNama: 'Trafo 2',
          periode: 10,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          mv: 20.1,
          hv: 150.0,
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadTeganganTrafoToday(20, 1);
      expect(cubit.cachedTeganganTrafoTodayList.first.mv, equals(20.1));
      expect(cubit.cachedTeganganTrafoTodayList.first.hv, equals(150.0));

      // Call update with new values
      await cubit.updateTeganganTrafoMobile(
        teganganId: 60,
        fotoMV: 'mv.jpg',
        fotoHV: 'hv.jpg',
        data: {'mv': 20.55, 'hv': 151.2},
      );

      // Verify optimistic update in memory
      expect(cubit.cachedTeganganTrafoTodayList.first.mv, equals(20.55));
      expect(cubit.cachedTeganganTrafoTodayList.first.hv, equals(151.2));
      expect(cubit.cachedTeganganTrafoTodayList.first.trafoNama, equals('Trafo 2'));
    });
  });

  group('Kwh Harian Tests', () {
    testWidgets('renders KwhItemCard with object details and status badge', (tester) async {
      const item = KwhHarianModel(
        id: 30,
        nama: 'KWH Trafo 1',
        type: 'TRAFO',
        kelompok: 'INCOMING',
        garduIndukId: 1,
        garduIndukNama: 'GI Gandul',
        overrideDone: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KwhItemCard(
              item: item,
              isDrafted: false,
              onView: () {},
              onInput: () {},
            ),
          ),
        ),
      );

      expect(find.text('KWH Trafo 1'), findsOneWidget);
      expect(find.text('GI Gandul - INCOMING'), findsOneWidget);
      expect(find.text('Lihat'), findsOneWidget);
      expect(find.text('Input'), findsOneWidget);

      final inputButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Input'));
      expect(inputButton.onPressed, isNull);
    });

    test('isStandValidDecimal validates number format correctly', () {
      expect(isStandValidDecimal([{'stand': '12345'}]), isTrue);
      expect(isStandValidDecimal([{'stand': '12345.67'}]), isTrue);
      expect(isStandValidDecimal([{'stand': 'xyz'}]), isFalse);
      expect(isStandValidDecimal([{'stand': '12,34'}]), isFalse);
    });

    test('isItemComplete checks completeness of stand and photo', () {
      expect(isItemComplete({'stand': '123', 'fotoStand': '/cache/pic.jpg'}), isTrue);
      expect(isItemComplete({'stand': '123', 'fotoStand': {'uri': '/cache/pic.jpg'}}), isTrue);
      expect(isItemComplete({'stand': '', 'fotoStand': '/cache/pic.jpg'}), isFalse);
      expect(isItemComplete({'stand': '123', 'fotoStand': ''}), isFalse);
    });

    test('parseKwhHarianDrafts extracts files and cleans draft payload', () {
      final rawDrafts = [
        {
          'id': 303,
          'nama': 'Penyulang Mawar',
          'data': {
            'draftId': 303,
            'objectId': 30,
            'type': 'PENYULANG',
            'kelompok': 'FEEDER',
            'garduIndukId': 1,
            'durasi': 15.0,
            'tanggal': 9,
            'bulan': 11,
            'tahun': 2026,
            'data': [
              {
                'jenis': 'H',
                'stand': '12500.5',
                'fotoStand': {'uri': '/cache/h.jpg'},
              },
            ],
          },
        },
      ];

      final result = parseKwhHarianDrafts(
        localDrafts: rawDrafts,
        garduIndukId: 1,
        mappedData: const [],
      );

      expect(result.parsed.length, equals(1));
      expect(result.parsed.first['draftId'], equals(303));

      final files = result.parsed.first['filesWithJenis'] as List<Map<String, dynamic>>;
      expect(files.length, equals(1));
      expect(files.first['file'], equals('/cache/h.jpg'));
      expect(files.first['jenis'], equals('H'));

      final data = result.parsed.first['data'] as Map<String, dynamic>;
      expect(data.containsKey('id'), isFalse);
      expect(data.containsKey('draftId'), isFalse);
      expect(data['objectId'], equals(30));
      expect(data['type'], equals('PENYULANG'));
      expect(data['kelompok'], equals('FEEDER'));
    });

    testWidgets('UpdateKwhHarianPage leaves fields empty and requires new photo', (tester) async {
      final repo = _FakeOpgiRepository();
      final cubit = OpgiRealisasiCubit(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: cubit,
            child: const UpdateKwhHarianPage(
              params: {
                'id': 1,
                'garduInduk': 'GI Gandul',
                'kelompok': 'FEEDER',
                'item': {
                  'id': 1,
                  'jenis': 'H',
                  'stand': 12500.0, // should not prefill
                  'keterangan': 'Old note', // should not prefill
                  'fotoStand': '/cache/old.jpg', // should not prefill
                },
              },
            ),
          ),
        ),
      );

      final textFields = tester.widgetList<TextField>(find.byType(TextField)).toList();
      expect(textFields.length, equals(2));
      expect(textFields[0].controller?.text, isEmpty); // Stand empty
      expect(textFields[1].controller?.text, isEmpty); // Keterangan empty

      // Tap Simpan without photo -> shows error
      await tester.ensureVisible(find.text('Simpan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Simpan'));
      await tester.pump();
      expect(find.text('Foto wajib diambil'), findsOneWidget);
    });

    test('submitKwhHarianSingle optimistically marks object isDone: true', () async {
      final repo = _FakeOpgiRepository();
      repo.kwhHarianList = [
        const KwhHarianModel(
          id: 30,
          nama: 'Penyulang Mawar',
          type: 'PENYULANG',
          kelompok: 'FEEDER',
          garduIndukId: 1,
          garduIndukNama: 'GI Gandul',
          overrideDone: false,
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadKwhHarian(1);
      expect(cubit.cachedKwhHarianList.first.isDone, isFalse);

      await cubit.submitKwhHarianSingle(
        filesWithJenis: [
          {'jenis': 'H', 'file': 'photo.jpg'}
        ],
        data: {
          'objectId': 30,
          'type': 'PENYULANG',
          'kelompok': 'FEEDER',
        },
      );

      expect(cubit.cachedKwhHarianList.first.isDone, isTrue);
    });

    test('updateKwhHarianMobile optimistically updates in-memory today list', () async {
      final repo = _FakeOpgiRepository();
      repo.kwhHarianTodayItems = [
        const KwhHarianTodayItemModel(
          id: 1,
          jenis: 'H',
          stand: 50.0,
          keterangan: 'Initial',
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadKwhHarianToday(30, type: 'PENYULANG', kelompok: 'FEEDER');
      expect(cubit.cachedKwhHarianTodayList.first.stand, equals(50.0));

      await cubit.updateKwhHarianMobile(
        id: 1,
        file: 'new_photo.jpg',
        data: {'stand': 75.5, 'keterangan': 'Updated'},
      );

      expect(cubit.cachedKwhHarianTodayList.first.stand, equals(75.5));
      expect(cubit.cachedKwhHarianTodayList.first.keterangan, equals('Updated'));
    });
  });

  group('Bulk Draft Progress LoadingIndicator Tests', () {
    testWidgets('renders LoadingIndicator matching super-i-mobile styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(
              text: 'Mengirim 3/10',
              progress: '30%',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Mengirim 3/10'), findsOneWidget);
      expect(find.text('30%'), findsOneWidget);
    });
  });

  group('Period Chip Direct Tap Tests', () {
    testWidgets('Tapping period chip on PenyulangItemCard calls onPeriodTap with selected period', (tester) async {
      PenyulangMappedPeriod? tappedPeriod;

      final mappedPeriods = [
        const PenyulangMappedPeriod(
          periode: 7,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          isDone: false,
          color: Colors.blue,
          draft: false,
          hasManuver: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PenyulangItemCard(
              item: const BebanPenyulangModel(
                id: 1,
                nama: 'Penyulang 1',
                garduIndukId: 1,
                garduIndukNama: 'GI Gandul',
                iMax: 600,
                statusCB: 'ON',
                rel: 'REL 1',
              ),
              mappedPeriods: mappedPeriods,
              onView: () {},
              onInput: () {},
              onPeriodTap: (p) => tappedPeriod = p,
            ),
          ),
        ),
      );

      await tester.tap(find.text('07'));
      await tester.pump();

      expect(tappedPeriod, isNotNull);
      expect(tappedPeriod?.periode, equals(7));
    });

    testWidgets('Tapping period chip on TrafoItemCard calls onPeriodTap with selected period', (tester) async {
      TrafoMappedPeriod? tappedPeriod;

      final mappedPeriods = [
        const TrafoMappedPeriod(
          periode: 14,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          isDone: false,
          color: Colors.blue,
          draft: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TrafoItemCard(
              item: const BebanTrafoModel(
                id: 1,
                nama: 'Trafo 1',
                garduIndukId: 1,
                garduIndukNama: 'GI Gandul',
                iMax: 1000,
              ),
              mappedPeriods: mappedPeriods,
              onView: () {},
              onInput: () {},
              onPeriodTap: (p) => tappedPeriod = p,
            ),
          ),
        ),
      );

      await tester.tap(find.text('14'));
      await tester.pump();

      expect(tappedPeriod, isNotNull);
      expect(tappedPeriod?.periode, equals(14));
    });

    testWidgets('Tapping period chip on TeganganTrafoItemCard calls onPeriodTap with selected period', (tester) async {
      TeganganTrafoMappedPeriod? tappedPeriod;

      final mappedPeriods = [
        const TeganganTrafoMappedPeriod(
          periode: 21,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          isDone: false,
          color: Colors.blue,
          draft: false,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TeganganTrafoItemCard(
              item: const TeganganTrafoModel(
                id: 1,
                nama: 'Trafo 1',
                garduIndukId: 1,
                garduIndukNama: 'GI Gandul',
              ),
              mappedPeriods: mappedPeriods,
              onView: () {},
              onInput: () {},
              onPeriodTap: (p) => tappedPeriod = p,
            ),
          ),
        ),
      );

      await tester.tap(find.text('21'));
      await tester.pump();

      expect(tappedPeriod, isNotNull);
      expect(tappedPeriod?.periode, equals(21));
    });
  });

  group('Optimistic Delete On Data Pages Tests', () {
    test('deleteBebanPenyulang optimistically keeps remaining item when 1 of 2 is deleted', () async {
      final repo = _FakeOpgiRepository();
      repo.bebanPenyulangTodayItems = [
        const BebanPenyulangTodayItemModel(
          id: 1,
          penyulangId: 10,
          penyulangNama: 'Penyulang A',
          periode: 7,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 120.0,
          status: 'ON TIME',
        ),
        const BebanPenyulangTodayItemModel(
          id: 2,
          penyulangId: 10,
          penyulangNama: 'Penyulang A',
          periode: 8,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 135.0,
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadBebanPenyulangToday(10, 1);
      expect(cubit.cachedBebanPenyulangTodayList.length, equals(2));

      await cubit.deleteBebanPenyulang(1);

      // Must have remaining item 2 (periode 8), NOT empty!
      expect(cubit.cachedBebanPenyulangTodayList.length, equals(1));
      expect(cubit.cachedBebanPenyulangTodayList.first.id, equals(2));
      expect(cubit.cachedBebanPenyulangTodayList.first.periode, equals(8));
    });

    test('deleteBebanTrafo optimistically keeps remaining item when 1 of 2 is deleted', () async {
      final repo = _FakeOpgiRepository();
      repo.bebanTrafoTodayItems = [
        const BebanTrafoTodayItemModel(
          id: 101,
          trafoId: 20,
          trafoNama: 'Trafo 1',
          periode: 9,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 250.0,
          status: 'ON TIME',
        ),
        const BebanTrafoTodayItemModel(
          id: 102,
          trafoId: 20,
          trafoNama: 'Trafo 1',
          periode: 10,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 280.0,
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadBebanTrafoToday(20, 1);
      expect(cubit.cachedBebanTrafoTodayList.length, equals(2));

      await cubit.deleteBebanTrafo(101);

      // Must have remaining item 102 (periode 10), NOT empty!
      expect(cubit.cachedBebanTrafoTodayList.length, equals(1));
      expect(cubit.cachedBebanTrafoTodayList.first.id, equals(102));
      expect(cubit.cachedBebanTrafoTodayList.first.periode, equals(10));
    });

    test('deleteTeganganTrafo optimistically keeps remaining item when 1 of 2 is deleted', () async {
      final repo = _FakeOpgiRepository();
      repo.teganganTrafoTodayItems = [
        const TeganganTrafoTodayItemModel(
          id: 201,
          trafoId: 20,
          trafoNama: 'Trafo 1',
          periode: 11,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          mv: 20.4,
          hv: 150.2,
          status: 'ON TIME',
        ),
        const TeganganTrafoTodayItemModel(
          id: 202,
          trafoId: 20,
          trafoNama: 'Trafo 1',
          periode: 12,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          mv: 20.5,
          hv: 151.0,
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);
      await cubit.loadTeganganTrafoToday(20, 1);
      expect(cubit.cachedTeganganTrafoTodayList.length, equals(2));

      await cubit.deleteTeganganTrafo(201);

      // Must have remaining item 202 (periode 12), NOT empty!
      expect(cubit.cachedTeganganTrafoTodayList.length, equals(1));
      expect(cubit.cachedTeganganTrafoTodayList.first.id, equals(202));
      expect(cubit.cachedTeganganTrafoTodayList.first.periode, equals(12));
    });

    testWidgets('DataBebanPenyulangPage keeps remaining item visible after deleting one item', (tester) async {
      final repo = _FakeOpgiRepository();
      repo.bebanPenyulangTodayItems = [
        const BebanPenyulangTodayItemModel(
          id: 1,
          penyulangId: 10,
          penyulangNama: 'Penyulang A',
          periode: 7,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 120.0,
          status: 'ON TIME',
        ),
        const BebanPenyulangTodayItemModel(
          id: 2,
          penyulangId: 10,
          penyulangNama: 'Penyulang A',
          periode: 8,
          tanggal: 10,
          bulan: 11,
          tahun: 2026,
          beban: 135.0,
          status: 'ON TIME',
        ),
      ];

      final cubit = OpgiRealisasiCubit(repo);

      tester.view.physicalSize = const Size(800, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OpgiRealisasiCubit>.value(
            value: cubit,
            child: const DataBebanPenyulangPage(
              params: {
                'id': 10,
                'nama': 'Penyulang A',
                'iMax': 600.0,
                'rel': 'REL 1',
                'statusCB': 'ON',
                'garduInduk': 'GI Gandul',
                'garduIndukId': 1,
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Periode: 07'), findsOneWidget);
      expect(find.text('Periode: 08'), findsOneWidget);

      // Tap delete on first item (Periode: 07)
      final deleteButtons = find.byIcon(Icons.delete_outline);
      expect(deleteButtons, findsNWidgets(2));
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      // Confirm in dialog
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Periode 07 should be gone, but Periode 08 must STILL BE VISIBLE!
      expect(find.text('Periode: 07'), findsNothing);
      expect(find.text('Periode: 08'), findsOneWidget);
      expect(find.text('Belum ada data beban hari ini untuk penyulang ini'), findsNothing);
    });
  });
}

