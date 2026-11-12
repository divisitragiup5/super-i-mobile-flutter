import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:super_i_mobile/core/errors/failures.dart';
import 'package:super_i_mobile/features/home/data/models/opgi_score_today_model.dart';
import 'package:super_i_mobile/features/home/domain/entities/sutm_inspeksi_score_entity.dart';
import 'package:super_i_mobile/features/home/domain/entities/sutm_pemeliharaan_score_entity.dart';
import 'package:super_i_mobile/features/home/domain/repositories/home_summary_repository.dart';
import 'package:super_i_mobile/features/home/presentation/cubit/opgi_score_cubit.dart';
import 'package:super_i_mobile/features/home/presentation/cubit/opgi_score_state.dart';
import 'package:super_i_mobile/features/home/presentation/widgets/summaries/opgi_score_summary_card.dart';

class _FakeHomeSummaryRepository implements HomeSummaryRepository {
  Either<Failure, OpgiScoreTodayModel?> opgiResult =
      const Right(null);

  @override
  Future<Either<Failure, OpgiScoreTodayModel?>> getOpgiScoreToday({
    String? timezone,
  }) async {
    return opgiResult;
  }

  @override
  Future<Either<Failure, SutmInspeksiScoreEntity>> getSutmInspeksiScoreToday({
    String? timezone,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SutmPemeliharaanScoreEntity>>
      getSutmPemeliharaanScoreToday({String? timezone}) {
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('id', null);
  });

  group('OpgiScoreTodayModel Unit Tests', () {
    test('parses complete backend JSON correctly with local timezone conversion', () {
      final json = {
        'tanggal': 12,
        'bulan': 10, // November in JS (0-indexed)
        'tahun': 2026,
        'createdAt': '2026-11-12T07:15:00.000Z',
        'main': [
          {'label': 'NILAI HARIAN', 'point': 96.5},
          {'label': 'POINT ABSENSI', 'point': 100},
          {'label': 'POINT PERFORNA', 'point': 93.0},
        ],
        'detail': [
          {
            'label': 'BEBAN PENYULANG',
            'target': 24,
            'stat': {
              'realisasi': 24,
              'totalPoint': 100.0,
            },
          },
          {
            'label': 'BEBAN TRAFO',
            'target': 12,
            'stat': {
              'realisasi': 9,
              'totalPoint': 75.0,
            },
          },
        ],
      };

      final model = OpgiScoreTodayModel.fromJson(json);

      expect(model.tanggal, 12);
      expect(model.bulan, 10);
      expect(model.tahun, 2026);
      expect(model.createdAt, isNotNull);
      // Ensure formatted date uses Indonesian format
      expect(model.formattedDate, contains('November 2026'));

      expect(model.nilaiHarian.label, 'NILAI HARIAN');
      expect(model.nilaiHarian.point, 96.5);

      expect(model.pointAbsensi.label, 'POINT ABSENSI');
      expect(model.pointAbsensi.point, 100.0);

      expect(model.pointPerforma.label, 'POINT PERFORNA');
      expect(model.pointPerforma.point, 93.0);

      expect(model.detail.length, 2);
      expect(model.detail[0].label, 'BEBAN PENYULANG');
      expect(model.detail[0].target, 24);
      expect(model.detail[0].realisasi, 24);
      expect(model.detail[0].score, 100.0);

      expect(model.detail[1].label, 'BEBAN TRAFO');
      expect(model.detail[1].target, 12);
      expect(model.detail[1].realisasi, 9);
      expect(model.detail[1].score, 75.0);
    });

    test('handles JSON string for main and detail gracefully (raw SQL queries)', () {
      final json = {
        'tanggal': 15,
        'bulan': 5,
        'tahun': 2026,
        'main': '[{"label":"NILAI HARIAN","point":"88.2"}]',
        'detail':
            '[{"label":"IL1 KUBIKEL","target":10,"stat":{"realisasi":5,"totalPoint":50}}]',
      };

      final model = OpgiScoreTodayModel.fromJson(json);

      expect(model.main.length, 1);
      expect(model.nilaiHarian.point, 88.2);
      expect(model.detail.length, 1);
      expect(model.detail[0].label, 'IL1 KUBIKEL');
      expect(model.detail[0].score, 50.0);
    });

    test('converts 0-indexed JS month correctly when createdAt is null', () {
      final json = {
        'tanggal': 5,
        'bulan': 0, // January in 0-indexed JS
        'tahun': 2026,
      };

      final model = OpgiScoreTodayModel.fromJson(json);
      expect(model.localDateTime.month, 1);
      expect(model.localDateTime.day, 5);
      expect(model.localDateTime.year, 2026);
      expect(model.formattedDate, contains('Januari 2026'));
    });
  });

  group('OpgiScoreCubit Tests', () {
    late _FakeHomeSummaryRepository fakeRepo;
    late OpgiScoreCubit cubit;

    setUp(() {
      fakeRepo = _FakeHomeSummaryRepository();
      cubit = OpgiScoreCubit(repository: fakeRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('emits [Loading, Loaded] when repository succeeds', () async {
      const dummyModel = OpgiScoreTodayModel(
        tanggal: 12,
        bulan: 10,
        tahun: 2026,
        main: [OpgiScoreMainItemModel(label: 'NILAI HARIAN', point: 90.0)],
      );

      fakeRepo.opgiResult = const Right(dummyModel);

      final expectedStates = [
        isA<OpgiScoreLoading>(),
        isA<OpgiScoreLoaded>().having((s) => s.score?.nilaiHarian.point, 'point', 90.0),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchScore();
    });

    test('emits [Loading, Error] when repository returns Failure', () async {
      fakeRepo.opgiResult = const Left(ServerFailure(message: 'Internal server error'));

      final expectedStates = [
        isA<OpgiScoreLoading>(),
        isA<OpgiScoreError>().having((s) => s.message, 'message', 'Internal server error'),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.fetchScore();
    });
  });

  group('OpgiScoreSummaryCard Widget Tests', () {
    late _FakeHomeSummaryRepository fakeRepo;
    late OpgiScoreCubit cubit;

    setUp(() {
      fakeRepo = _FakeHomeSummaryRepository();
      cubit = OpgiScoreCubit(repository: fakeRepo);
    });

    tearDown(() {
      cubit.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider<OpgiScoreCubit>.value(
            value: cubit,
            child: const SingleChildScrollView(
              child: OpgiScoreSummaryCard(),
            ),
          ),
        ),
      );
    }

    testWidgets('renders loading state indicator', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      cubit.emit(OpgiScoreLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state and triggers retry', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      cubit.emit(const OpgiScoreError(message: 'Koneksi gagal'));
      await tester.pump();

      expect(find.text('Koneksi gagal'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));
      await tester.pump();
    });

    testWidgets('renders empty state when score data is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      cubit.emit(const OpgiScoreLoaded(score: null));
      await tester.pump();

      expect(find.text('Penilaian Kinerja'), findsOneWidget);
      expect(find.text('Data tidak ditemukan'), findsOneWidget);
    });

    testWidgets('renders loaded state with gauges and expands accordion grid',
        (tester) async {
      final score = OpgiScoreTodayModel(
        tanggal: 12,
        bulan: 10,
        tahun: 2026,
        main: const [
          OpgiScoreMainItemModel(label: 'NILAI HARIAN', point: 96.5),
          OpgiScoreMainItemModel(label: 'POINT ABSENSI', point: 100.0),
          OpgiScoreMainItemModel(label: 'POINT PERFORMA', point: 93.0),
        ],
        detail: const [
          OpgiScoreDetailItemModel(
            label: 'BEBAN PENYULANG',
            target: 24,
            realisasi: 24,
            totalPoint: 100.0,
            score: 100.0,
          ),
          OpgiScoreDetailItemModel(
            label: 'BEBAN TRAFO',
            target: 12,
            realisasi: 9,
            totalPoint: 75.0,
            score: 75.0,
          ),
        ],
      );

      await tester.pumpWidget(createWidgetUnderTest());

      cubit.emit(OpgiScoreLoaded(score: score));
      await tester.pump();

      expect(find.text('Penilaian Kinerja'), findsOneWidget);
      expect(find.text('NILAI HARIAN'), findsOneWidget);
      expect(find.text('POINT ABSENSI'), findsOneWidget);
      expect(find.text('POINT PERFORMA'), findsOneWidget);

      // Accordion toggle button initially says "Lebih lengkap"
      expect(find.text('Lebih lengkap'), findsOneWidget);
      expect(find.text('BEBAN PENYULANG'), findsNothing);

      // Tap toggle to expand
      await tester.tap(find.text('Lebih lengkap'));
      await tester.pumpAndSettle();

      // Now expanded
      expect(find.text('Lebih sedikit'), findsOneWidget);
      expect(find.text('BEBAN PENYULANG'), findsOneWidget);
      expect(find.text('(T) 24 / 24 (R)'), findsOneWidget);
      expect(find.text('BEBAN TRAFO'), findsOneWidget);
      expect(find.text('(T) 12 / 9 (R)'), findsOneWidget);
    });
  });
}
