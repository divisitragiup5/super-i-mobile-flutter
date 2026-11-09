import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:super_i_mobile/core/errors/failures.dart';
import 'package:super_i_mobile/features/line_walker/data/models/ketenagakerjaan_model.dart';
import 'package:super_i_mobile/features/line_walker/domain/repositories/line_walker_repository.dart';
import 'package:super_i_mobile/features/line_walker/presentation/cubit/ketenagakerjaan_cubit.dart';

class FakeLineWalkerRepository implements LineWalkerRepository {
  List<KetenagakerjaanItemModel> detailResult = [];
  bool shouldFailDetail = false;
  String downloadResult = '/storage/Download/SURAT-TEGURAN.pdf';
  bool shouldFailDownload = false;

  @override
  Future<Either<Failure, List<KetenagakerjaanItemModel>>> getKetenagakerjaanDetail(
    int id, {
    int cursor = 0,
    String? timezone,
  }) async {
    if (shouldFailDetail) {
      return const Left(ServerFailure(message: 'Gagal memuat rincian'));
    }
    return Right(detailResult);
  }

  @override
  Future<Either<Failure, String>> downloadSuratKetenagakerjaan({
    required int id,
    required int minggu,
    required String bulan,
    required int tahun,
    required String status,
  }) async {
    if (shouldFailDownload) {
      return const Left(ServerFailure(message: 'Gagal mengunduh surat'));
    }
    return Right(downloadResult);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeLineWalkerRepository fakeRepository;
  late KetenagakerjaanCubit cubit;

  setUp(() {
    fakeRepository = FakeLineWalkerRepository();
    cubit = KetenagakerjaanCubit(fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  group('KetenagakerjaanItemModel JSON Parsing', () {
    test('parses correctly with full user and scoring details', () {
      final json = {
        'id': 101,
        'status': 'SURAT TEGURAN',
        'minggu': 2,
        'bulan': 'februari',
        'tahun': 2026,
        'score': 84.50,
        'petugasLineWalker': {
          'petugas': {
            'user': {
              'id': 42,
              'namaLengkap': 'Ahmad Petugas',
            }
          }
        },
        'kegiatanSosial': [
          {'poin': 2.5},
          {'poin': 1.0},
        ],
        'pengurang': [
          {'id': 1, 'type': 'Keterlambatan', 'poin': 5.0},
        ],
        'kepatuhan': '100%',
        'pointKepatuhan': 25.0,
        'kategoriKepatuhan': 'sesuai',
        'durasi': '02:30:00',
        'ketentuan': 2.5,
        'kinerja': 0.95,
        'pointDurasi': 20.0,
        'kategoriDurasiInspeksi': 'sesuai',
        'absensi': 'Hadir',
        'bantuanAbsensi': 'Tepat Waktu',
        'pointAbsensi': 25.0,
        'kategoriKehadiran': 'hadir',
        'coc': 'Mengikuti',
        'bantuanCOC': 'Aktif',
        'pointCOC': 20.0,
        'kategoriCOC': 'hadir',
      };

      final model = KetenagakerjaanItemModel.fromJson(json);

      expect(model.id, 101);
      expect(model.status, 'SURAT TEGURAN');
      expect(model.minggu, 2);
      expect(model.bulan, 'februari');
      expect(model.tahun, 2026);
      expect(model.score, 84.50);
      expect(model.userId, 42);
      expect(model.namaPetugas, 'Ahmad Petugas');
      expect(model.kegiatanSosial.length, 2);
      expect(model.pengurang.length, 1);
      expect(model.pengurang.first.type, 'Keterlambatan');
      expect(model.pengurang.first.poin, 5.0);
      expect(model.pointKepatuhan, 25.0);
      expect(model.pointDurasi, 20.0);
      expect(model.pointAbsensi, 25.0);
      expect(model.pointCOC, 20.0);
    });
  });

  group('KetenagakerjaanCubit', () {
    final tItem = KetenagakerjaanItemModel(
      id: 1,
      status: 'SURAT TEGURAN',
      minggu: 1,
      bulan: 'Januari',
      tahun: 2026,
      score: 75.0,
      userId: 42,
      namaPetugas: 'Ahmad Petugas',
    );

    test('loadDetail emits Loading then DetailLoaded with pagination flags', () async {
      fakeRepository.detailResult = [tItem];

      expectLater(
        cubit.stream,
        emitsInOrder([
          isA<KetenagakerjaanLoading>(),
          isA<KetenagakerjaanDetailLoaded>()
              .having((s) => s.items.length, 'items length', 1)
              .having((s) => s.hasReachedMax, 'hasReachedMax', true)
              .having((s) => s.nextCursor, 'nextCursor', 1),
        ]),
      );

      await cubit.loadDetail(42);
    });

    test('loadMoreDetail appends items correctly', () async {
      final firstPageItems = List.generate(
        10,
        (i) => KetenagakerjaanItemModel(
          id: i + 1,
          status: 'AMAN',
          minggu: 1,
          bulan: 'Januari',
          tahun: 2026,
          score: 90.0,
          userId: 42,
          namaPetugas: 'Ahmad Petugas',
        ),
      );

      final secondPageItem = KetenagakerjaanItemModel(
        id: 11,
        status: 'AMAN',
        minggu: 2,
        bulan: 'Januari',
        tahun: 2026,
        score: 95.0,
        userId: 42,
        namaPetugas: 'Ahmad Petugas',
      );

      fakeRepository.detailResult = firstPageItems;
      await cubit.loadDetail(42);

      final stateAfterLoad = cubit.state as KetenagakerjaanDetailLoaded;
      expect(stateAfterLoad.hasReachedMax, false);
      expect(stateAfterLoad.items.length, 10);

      fakeRepository.detailResult = [secondPageItem];
      await cubit.loadMoreDetail(42);

      expect(cubit.state, isA<KetenagakerjaanDetailLoaded>());
      final loadedState = cubit.state as KetenagakerjaanDetailLoaded;
      expect(loadedState.items.length, 11);
      expect(loadedState.items.last.id, 11);
      expect(loadedState.hasReachedMax, true);
    });

    test('downloadSurat calls repository.downloadSuratKetenagakerjaan and returns path', () async {
      fakeRepository.downloadResult = '/storage/Download/SURAT-TEGURAN.pdf';

      final path = await cubit.downloadSurat(tItem);
      expect(path, '/storage/Download/SURAT-TEGURAN.pdf');
    });

    test('downloadSurat throws Exception on failure', () async {
      fakeRepository.shouldFailDownload = true;

      expect(
        () => cubit.downloadSurat(tItem),
        throwsA(isA<Exception>()),
      );
    });
  });
}
