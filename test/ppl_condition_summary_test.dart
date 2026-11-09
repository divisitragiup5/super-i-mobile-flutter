import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:super_i_mobile/core/errors/failures.dart';
import 'package:super_i_mobile/features/home/data/models/ppl_condition_summary_model.dart';
import 'package:super_i_mobile/features/home/presentation/cubit/ppl_condition_summary_cubit.dart';
import 'package:super_i_mobile/features/home/presentation/widgets/summaries/ppl_summary_card.dart';
import 'package:super_i_mobile/features/line_walker/domain/repositories/line_walker_repository.dart';
import 'package:super_i_mobile/features/line_walker/presentation/widgets/history_detail_widgets.dart';

class MockLineWalkerRepository implements LineWalkerRepository {
  Either<Failure, PplConditionSummaryModel>? conditionSummaryResult;

  @override
  Future<Either<Failure, PplConditionSummaryModel>> getPplConditionSummary() async {
    return conditionSummaryResult ??
        Right(
          PplConditionSummaryModel(
            signatures: [
              PplSignatureItem(status: 'Sudah TTD', count: 10),
              PplSignatureItem(status: 'Belum TTD', count: 5),
            ],
            statuses: [
              PplStatusItem(kategoriObjek: 'Kritis', count: 2),
              PplStatusItem(kategoriObjek: 'Waspada', count: 3),
              PplStatusItem(kategoriObjek: 'Bahaya', count: 1),
              PplStatusItem(kategoriObjek: 'Aman', count: 9),
            ],
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('PplConditionSummaryModel', () {
    test('parses json correctly with signature and status arrays', () {
      final json = {
        'signature': [
          {
            'status': 'Sudah TTD',
            '_count': {'_all': 12},
          },
          {
            'status': 'Belum TTD',
            '_count': {'_all': 8},
          },
        ],
        'status': [
          {
            'kategoriObjek': 'Kritis',
            '_count': {'_all': 1},
          },
          {
            'kategoriObjek': 'Waspada',
            '_count': {'_all': 2},
          },
          {
            'kategoriObjek': 'Bahaya',
            '_count': {'_all': 3},
          },
          {
            'kategoriObjek': 'Aman',
            '_count': {'_all': 14},
          },
        ],
      };

      final model = PplConditionSummaryModel.fromJson(json);

      expect(model.signatures.length, 2);
      expect(model.signatures[0].status, 'Sudah TTD');
      expect(model.signatures[0].count, 12);
      expect(model.signatures[1].status, 'Belum TTD');
      expect(model.signatures[1].count, 8);
      expect(model.total, 20);

      expect(model.statuses.length, 4);
      expect(model.statuses[0].kategoriObjek, 'Kritis');
      expect(model.statuses[0].count, 1);
    });

    test('handles empty or malformed json gracefully', () {
      final model = PplConditionSummaryModel.fromJson({});
      expect(model.signatures, isEmpty);
      expect(model.statuses, isEmpty);
      expect(model.total, 0);
    });
  });

  group('PplConditionSummaryCubit', () {
    late MockLineWalkerRepository repository;
    late PplConditionSummaryCubit cubit;

    setUp(() {
      repository = MockLineWalkerRepository();
      cubit = PplConditionSummaryCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is PplConditionSummaryInitial', () {
      expect(cubit.state, isA<PplConditionSummaryInitial>());
    });

    test('fetchSummary emits Loading then Loaded on success', () async {
      final expected = [
        isA<PplConditionSummaryLoading>(),
        isA<PplConditionSummaryLoaded>().having(
          (s) => s.summary.total,
          'total',
          15,
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.fetchSummary();
    });

    test('fetchSummary emits Loading then Error on failure', () async {
      repository.conditionSummaryResult =
          const Left(ServerFailure(message: 'Network error'));

      final expected = [
        isA<PplConditionSummaryLoading>(),
        isA<PplConditionSummaryError>().having(
          (s) => s.message,
          'message',
          'Network error',
        ),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));

      await cubit.fetchSummary();
    });
  });

  group('PplSummaryCard Widget Test', () {
    late MockLineWalkerRepository repository;
    late PplConditionSummaryCubit cubit;

    setUp(() {
      repository = MockLineWalkerRepository();
      cubit = PplConditionSummaryCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    testWidgets('renders donut chart and statistics when data is present',
        (tester) async {
      await cubit.fetchSummary();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const PplSummaryCard(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PPL'), findsOneWidget);
      expect(find.text('Total Objek'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('10 Sudah TTD'), findsOneWidget);
      expect(find.text('5 Belum TTD'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders empty state card when data is empty',
        (tester) async {
      repository.conditionSummaryResult = Right(
        PplConditionSummaryModel(
          signatures: [],
          statuses: [],
        ),
      );
      await cubit.fetchSummary();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: cubit,
              child: const PplSummaryCard(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PPL'), findsOneWidget);
      expect(find.text('Data tidak ditemukan'), findsOneWidget);
      expect(
        find.text('Belum ada data monitoring kondisi & tanda tangan PPL'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });
  });

  group('HistoryEmptyCard', () {
    testWidgets('renders default text "Data tidak ditemukan"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryEmptyCard(),
          ),
        ),
      );
      expect(find.text('Data tidak ditemukan'), findsOneWidget);
    });

    testWidgets('renders custom message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HistoryEmptyCard(message: 'Tidak ada riwayat'),
          ),
        ),
      );
      expect(find.text('Tidak ada riwayat'), findsOneWidget);
    });
  });
}
