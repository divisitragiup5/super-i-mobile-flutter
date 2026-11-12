import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_anomali_model.dart';
import 'package:super_i_mobile/features/opgi/domain/repositories/opgi_repository.dart';
import 'package:super_i_mobile/features/opgi/presentation/cubit/opgi_anomali_cubit.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/anomali_gi_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/data_anomali_gi_page.dart';

class _FakeAnomaliRepository implements OpgiRepository {
  List<AnomaliReportModel> history = [];
  List<AnomaliKondisiModel> conditions = [];
  List<Map<String, dynamic>> assets = [];

  bool submitAnomaliCalled = false;
  bool submitKondisiCalled = false;
  bool updateKondisiCalled = false;
  bool deleteAnomaliCalled = false;
  bool deleteKondisiCalled = false;

  @override
  Future<List<AnomaliReportModel>> getAnomaliHistory(int garduIndukId,
      {int? cursor}) async {
    return history;
  }

  @override
  Future<List<AnomaliKondisiModel>> getKondisiAnomaliHistory(int anomaliId,
      {int? cursor}) async {
    return conditions;
  }

  @override
  Future<List<Map<String, dynamic>>> getAnomaliAssets(
      int garduIndukId, String jenisAsset) async {
    return assets;
  }

  @override
  Future<void> submitAnomali({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  }) async {
    submitAnomaliCalled = true;
  }

  @override
  Future<void> submitAnomaliKondisi({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  }) async {
    submitKondisiCalled = true;
  }

  @override
  Future<void> updateAnomaliKondisi(
      int kondisiId, Map<String, dynamic> data) async {
    updateKondisiCalled = true;
  }

  @override
  Future<void> deleteAnomali(int id) async {
    deleteAnomaliCalled = true;
    history.removeWhere((item) => item.id == id);
  }

  @override
  Future<void> deleteAnomaliKondisi(int id) async {
    deleteKondisiCalled = true;
    conditions.removeWhere((item) => item.id == id);
  }

  // Unused methods in this test suite
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Anomali Models Tests', () {
    test('AnomaliReportModel parses backend JSON correctly', () {
      final json = {
        'id': 101,
        'jenisAsset': 'PENYULANG',
        'assetId': 12,
        'entitas': 'KUBIKEL',
        'penyulang': {
          'id': 12,
          'nama': 'Penyulang Mawar',
          'garduInduk': {'id': 5, 'nama': 'GI Gambir'},
        },
        'operator': {
          'petugas': {
            'user': {'namaLengkap': 'Budi Santoso'}
          }
        },
        'createdAt': '2026-11-12T10:00:00.000Z',
        'kondisi': [
          {
            'id': 201,
            'anomaliId': 101,
            'urgensi': 'BAHAYA',
            'tindakan': 'ON PROGRES',
            'keterangan': 'Indikator panas berlebih',
            'bukti': {'path': '/images/foto1.jpg'},
            'vidioBukti': '/videos/vid1.mp4',
            'createdAt': '2026-11-12T10:30:00.000Z',
          }
        ],
      };

      final model = AnomaliReportModel.fromJson(json);

      expect(model.id, 101);
      expect(model.assetNama, 'Penyulang Mawar');
      expect(model.namaGarduInduk, 'GI Gambir');
      expect(model.namaPetugas, 'Budi Santoso');
      expect(model.latestUrgensi, 'BAHAYA');
      expect(model.latestTindakan, 'ON PROGRES');
      expect(model.latestKeterangan, 'Indikator panas berlebih');
      expect(model.latestFotoBuktiUrl, '/images/foto1.jpg');
      expect(model.latestVideoBuktiUrl, '/videos/vid1.mp4');
      expect(model.isSelesai, false);
      expect(model.kondisiList.length, 1);
      expect(model.kondisiList.first.isLast, true);
    });

    test('AnomaliReportModel parses trafo and handles SELESAI', () {
      final json = {
        'id': 102,
        'jenisAsset': 'TRAFO',
        'assetId': 3,
        'entitas': 'TRAFO',
        'trafo': {
          'id': 3,
          'nama': 'Trafo 1',
          'garduInduk': {'id': 5, 'nama': 'GI Gambir'},
        },
        'urgensi': 'AMAN',
        'tindakan': 'SELESAI',
        'keterangan': 'Sudah diperbaiki',
      };

      final model = AnomaliReportModel.fromJson(json);

      expect(model.assetNama, 'Trafo 1');
      expect(model.isSelesai, true);
    });
  });

  group('OpgiAnomaliCubit Tests', () {
    late _FakeAnomaliRepository repo;
    late OpgiAnomaliCubit cubit;

    setUp(() {
      repo = _FakeAnomaliRepository();
      cubit = OpgiAnomaliCubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadHistory emits loaded state with items', () async {
      repo.history = [
        const AnomaliReportModel(
          id: 1,
          jenisAsset: 'PENYULANG',
          assetId: 10,
          assetNama: 'Feeder 1',
          entitas: 'KUBIKEL',
          urgensi: 'AMAN',
          tindakan: 'SELESAI',
          keterangan: 'Normal',
        ),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OpgiAnomaliLoading>(),
          isA<OpgiAnomaliLoaded>().having(
            (s) => s.items.length,
            'items length',
            1,
          ),
        ]),
      );

      await cubit.loadHistory(5);
    });

    test('loadKondisiHistory emits loaded conditions', () async {
      repo.conditions = [
        const AnomaliKondisiModel(
          id: 50,
          anomaliId: 1,
          urgensi: 'INVESTIGASI LANJUTAN',
          tindakan: 'ON PROGRES',
          keterangan: 'Menunggu sparepart',
          isLast: true,
        ),
      ];

      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OpgiAnomaliLoading>(),
          isA<OpgiAnomaliKondisiLoaded>().having(
            (s) => s.conditions.length,
            'conditions length',
            1,
          ),
        ]),
      );

      await cubit.loadKondisiHistory(1);
    });

    test('updateAnomaliKondisi calls repository and emits success', () async {
      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<OpgiAnomaliLoading>(),
          isA<OpgiAnomaliSuccess>().having(
            (s) => s.message,
            'message',
            'Kondisi anomali berhasil diperbarui',
          ),
        ]),
      );

      await cubit.updateAnomaliKondisi(
        kondisiId: 50,
        data: {
          'urgensi': 'AMAN',
          'tindakan': 'SELESAI',
          'keterangan': 'Sudah selesai',
        },
      );

      expect(repo.updateKondisiCalled, true);
    });
  });

  group('Anomali Pages Widget Tests', () {
    late _FakeAnomaliRepository repo;

    setUp(() {
      repo = _FakeAnomaliRepository();
    });

    testWidgets('AnomaliGiPage renders header, Info card and anomali cards',
        (tester) async {
      repo.history = [
        const AnomaliReportModel(
          id: 1,
          jenisAsset: 'PENYULANG',
          assetId: 10,
          assetNama: 'Penyulang Kenanga',
          entitas: 'KUBIKEL',
          urgensi: 'BAHAYA',
          tindakan: 'ON PROGRES',
          keterangan: 'Ada suara mendesis',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OpgiAnomaliCubit>(
            create: (_) => OpgiAnomaliCubit(repo),
            child: const AnomaliGiPage(
              garduIndukId: 5,
              garduIndukNama: 'GI Gandul',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Anomali - GI Gandul'), findsOneWidget);
      expect(find.text('GI Gandul'), findsOneWidget);
      expect(find.text('Tambah Anomali'), findsOneWidget);
      expect(find.text('Penyulang Kenanga (KUBIKEL)'), findsOneWidget);
      expect(find.text('BAHAYA'), findsOneWidget);
      expect(find.text('Lihat'), findsOneWidget);
    });

    testWidgets('DataAnomaliGiPage renders detail info and conditions',
        (tester) async {
      const anomali = AnomaliReportModel(
        id: 1,
        jenisAsset: 'TRAFO',
        assetId: 2,
        assetNama: 'Trafo 2',
        entitas: 'TRAFO',
        urgensi: 'INVESTIGASI LANJUTAN',
        tindakan: 'ON PROGRES',
        keterangan: 'Suhu oli tinggi',
        namaPetugas: 'Siti Operator',
      );

      repo.conditions = [
        const AnomaliKondisiModel(
          id: 11,
          anomaliId: 1,
          urgensi: 'INVESTIGASI LANJUTAN',
          tindakan: 'ON PROGRES',
          keterangan: 'Pengecekan cooling fan',
          isLast: true,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OpgiAnomaliCubit>(
            create: (_) => OpgiAnomaliCubit(repo),
            child: const DataAnomaliGiPage(
              anomaliId: 1,
              garduIndukNama: 'GI Gandul',
              garduIndukId: 5,
              anomaliData: anomali,
              initialProgress: 'ON PROGRES',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Detail Anomali - Trafo 2'), findsOneWidget);
      expect(find.text('TRAFO'), findsNWidgets(2)); // jenis asset & entitas
      expect(find.text('Trafo 2'), findsOneWidget);
      expect(find.text('Siti Operator'), findsOneWidget);
      expect(find.text('Tambah Kondisi Anomali'), findsOneWidget);
      expect(find.text('Pengecekan cooling fan'), findsOneWidget);
      expect(find.text('Update'), findsOneWidget);
    });
  });
}
