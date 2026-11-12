import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_i_mobile/features/opgi/data/models/gardu_induk_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_anomali_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_il1_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_manuver_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_realisasi_model.dart';
import 'package:super_i_mobile/features/opgi/domain/repositories/opgi_repository.dart';
import 'package:super_i_mobile/features/opgi/presentation/cubit/opgi_il1_cubit.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/il1_kubikel_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/il1_trafo_ps_utils.dart';
import 'package:super_i_mobile/features/opgi/presentation/utils/il1_sipil_utils.dart';

class _FakeOpgiRepository implements OpgiRepository {
  List<Il1KubikelItem> kubikelList = [];
  Il1KubikelTodayDetailModel? kubikelToday;
  Map<String, dynamic>? nextKubikelSingleResponse;

  List<Il1TrafoPsItem> trafoPsList = [];
  Il1TrafoPsTodayDetailModel? trafoPsToday;
  Map<String, dynamic>? nextTrafoPsSingleResponse;

  List<Il1SipilItem> sipilList = [];
  Il1SipilTodayDetailModel? sipilToday;
  Map<String, dynamic>? nextSipilSingleResponse;

  // Unused Realisasi & Manuver stubs
  @override
  Future<List<GarduIndukModel>> getGarduIndukList({String timezone = 'Asia/Jakarta'}) async => [];
  @override
  Future<List<BebanTrafoModel>> getBebanTrafoInput(int garduIndukId, String date) async => [];
  @override
  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {}
  @override
  Future<List<BebanTrafoModel>> getBebanTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<List<BebanTrafoTodayItemModel>> getBebanTrafoToday(int trafoId, {required int garduIndukId, String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<Map<String, dynamic>?> submitBebanTrafoSingle({required dynamic file, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> updateBebanTrafoMobile(int bebanId, {required dynamic file, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> deleteBebanTrafo(int bebanId) async => null;
  @override
  Future<List<PenyulangModel>> getPenyulangList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date, {bool forceRefresh = false}) async => [];
  @override
  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {}
  @override
  Future<Map<String, dynamic>?> submitBebanPenyulangSingle({required dynamic file, required Map<String, dynamic> data}) async => null;
  @override
  Future<List<BebanPenyulangTodayItemModel>> getBebanPenyulangToday(int penyulangId, {required int garduIndukId, String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<Map<String, dynamic>?> updateBebanPenyulangMobile(int bebanId, {required dynamic file, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> deleteBebanPenyulang(int bebanId) async => null;
  @override
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) async {}
  @override
  Future<void> updateUrutanPenyulangCustom(List<Map<String, dynamic>> items) async {}
  @override
  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date) async => [];
  @override
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {}
  @override
  Future<List<KwhHarianModel>> getKwhHarianList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<List<KwhHarianTodayItemModel>> getKwhHarianToday(int objectId, {required String type, required String kelompok, String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<Map<String, dynamic>?> submitKwhHarianSingle({required List<Map<String, dynamic>> filesWithJenis, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> updateKwhHarianMobile(int id, {required dynamic file, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> deleteKwhHarianToday(List<int> ids) async => null;
  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date) async => [];
  @override
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {}
  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<List<TeganganTrafoTodayItemModel>> getTeganganTrafoToday(int trafoId, {required int garduIndukId, String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => [];
  @override
  Future<Map<String, dynamic>?> submitTeganganTrafoSingle({required dynamic fileMV, required dynamic fileHV, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> updateTeganganTrafoMobile(int teganganId, {dynamic fileMV, dynamic fileHV, required Map<String, dynamic> data}) async => null;
  @override
  Future<Map<String, dynamic>?> deleteTeganganTrafo(int teganganId) async => null;
  @override
  Future<List<ManuverItemModel>> getManuverList(int garduIndukId, {String? timezone, bool forceRefresh = false}) async => [];
  @override
  Future<List<ManuverItemModel>> getManuverHistory(int garduIndukId, {int? cursor}) async => [];
  @override
  Future<List<ManuverProgressModel>> getManuverProgress(int manuverId, {String? timezone, bool forceRefresh = false}) async => [];
  @override
  Future<Map<String, dynamic>> submitManuver(Map<String, dynamic> data, [dynamic imageFile]) async => {};
  @override
  Future<Map<String, dynamic>> submitManuverProgress(Map<String, dynamic> data, [dynamic imageFile]) async => {};
  @override
  Future<Map<String, dynamic>> updateManuverProgress(int progressId, Map<String, dynamic> data) async => {};
  @override
  Future<Map<String, dynamic>> deleteManuver(int manuverId) async => {'success': true, 'message': 'Berhasil menghapus manuver'};
  @override
  Future<Map<String, dynamic>> deleteManuverProgress(int progressId) async => {'success': true, 'message': 'Berhasil menghapus progress'};
  @override
  Future<List<Map<String, dynamic>>> getPenyulangByGi(int garduIndukId) async => [];
  @override
  Future<List<AnomaliReportModel>> getAnomaliHistory(int garduIndukId, {int? cursor}) async => [];
  @override
  Future<List<Map<String, dynamic>>> getAnomaliAssets(int garduIndukId, String jenisAsset) async => [];
  @override
  Future<void> submitAnomali({required Map<String, dynamic> data, XFile? imageFile, XFile? videoFile}) async {}
  @override
  Future<void> submitAnomaliKondisi({required Map<String, dynamic> data, XFile? imageFile, XFile? videoFile}) async {}
  @override
  Future<void> deleteAnomali(int id) async {}
  @override
  Future<void> deleteAnomaliKondisi(int id) async {}

  // IL1 Kubikel
  @override
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    return kubikelList;
  }

  @override
  Future<Il1KubikelTodayDetailModel?> getIl1KubikelToday(int penyulangId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    return kubikelToday;
  }

  @override
  Future<void> submitIl1Kubikel({required Map<String, dynamic> data, required List<XFile> files}) async {}

  @override
  Future<Map<String, dynamic>?> submitIl1KubikelSingle({required Map<String, dynamic> data, dynamic fotoBuktiInspeksi, dynamic fotoAnomali, String timezone = 'Asia/Jakarta'}) async {
    return nextKubikelSingleResponse ?? {'id': 101, 'status': 'NORMAL', ...data};
  }

  @override
  Future<Map<String, dynamic>?> updateIl1Kubikel(int id, Map<String, dynamic> data, {dynamic fotoAnomali}) async {
    return {'id': id, 'status': 'SESUAI STANDAR', ...data};
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1Kubikel(int id) async => null;

  @override
  Future<List<Map<String, dynamic>>> getTrafoList(int garduIndukId) async => [
    {'id': 1, 'nama': 'Trafo 1'},
  ];

  @override
  Future<List<Map<String, dynamic>>> getRelList(int garduIndukId) async => [
    {'id': 1, 'rel': 'Rel 1'},
  ];

  // IL1 Trafo PS
  @override
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    return trafoPsList;
  }

  @override
  Future<Il1TrafoPsTodayDetailModel?> getIl1TrafoPsToday(int trafoId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    return trafoPsToday;
  }

  @override
  Future<void> submitIl1TrafoPs({required Map<String, dynamic> data, required XFile file}) async {}

  @override
  Future<Map<String, dynamic>?> submitIl1TrafoPsSingle({required Map<String, dynamic> data, dynamic fotoBuktiInspeksi, String timezone = 'Asia/Jakarta'}) async {
    return nextTrafoPsSingleResponse ?? {'id': 201, 'status': 'NORMAL', ...data};
  }

  @override
  Future<Map<String, dynamic>?> updateIl1TrafoPs(int id, Map<String, dynamic> data) async {
    return {'id': id, 'status': 'SESUAI STANDAR', ...data};
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1TrafoPs(int id) async => null;

  // IL1 Sipil
  @override
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    return sipilList;
  }

  @override
  Future<Il1SipilTodayDetailModel?> getIl1SipilToday(int sipilId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    return sipilToday;
  }

  @override
  Future<void> submitIl1Sipil({required Map<String, dynamic> data, required XFile file}) async {}

  @override
  Future<Map<String, dynamic>?> submitIl1SipilSingle({required Map<String, dynamic> data, dynamic fotoBuktiInspeksi, String timezone = 'Asia/Jakarta'}) async {
    return nextSipilSingleResponse ?? {'id': 301, 'status': 'SESUAI STANDAR', ...data};
  }

  @override
  Future<Map<String, dynamic>?> updateIl1Sipil(int id, Map<String, dynamic> data) async {
    return {'id': id, 'status': 'SESUAI STANDAR', ...data};
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1Sipil(int id) async => null;
}

void main() {
  group('IL1 Utilities Tests', () {
    test('Il1KubikelUtils validation and draft parser', () {
      final validData = <String, dynamic>{
        'fotoBuktiInspeksi': {'uri': '/path/to/foto.jpg'},
        'merkKubikel': 'Schneider',
        'statusPMT': 'CLOSE',
        'rackPMT': 'RACK IN',
        'keteranganPMT': ['NORMAL'],
        'kondisiSF6PMT': 'GOOD',
        'indikatorPegasMekanikPMT': 'CHARGE',
        'bendaAsing': 'TIDAK',
        'binatang': 'TIDAK',
        'tetesanAir': 'TIDAK',
        'desis': 'TIDAK',
        'bau': 'TIDAK',
        'kondisiLVPanel': 'BERSIH',
        'lampuLVPanel': 'NYALA',
        'indikatorPMTClose': 'NYALA',
        'indikatorPMTOpen': 'TIDAK',
        'indikatorTeganganKubikel': 'NYALA',
        'tampilanLCDRelayOCR': 'NORMAL',
        'indikatorHealthyRelayOCR': 'NYALA',
        'pembacaanArusNetralRelayOCR': 0.0,
        'keteranganRelayUFR': 'TIDAK ADA',
        'tampilanLCDKWHMeter': 'NORMAL',
        'tombolKWHMeter': 'NORMAL',
        'kondisiAlarm': 'ADA',
        'keteranganAnomali': 'TIDAK ADA',
        'garduIndukId': 10,
        'penyulangId': 101,
      };

      expect(Il1KubikelUtils.validateIl1Kubikel(validData), isTrue);

      final invalidData = Map<String, dynamic>.from(validData);
      invalidData.remove('fotoBuktiInspeksi');
      expect(Il1KubikelUtils.validateIl1Kubikel(invalidData), isFalse);

      final ufrData = Map<String, dynamic>.from(validData);
      ufrData['keteranganRelayUFR'] = 'ADA';
      expect(Il1KubikelUtils.validateIl1Kubikel(ufrData), isFalse);
      ufrData['tampilanLCDRelayUFR'] = 'NORMAL';
      ufrData['pembacaanTeganganRelayUFR'] = 110.0;
      ufrData['selectorUFR'] = 1;
      expect(Il1KubikelUtils.validateIl1Kubikel(ufrData), isTrue);

      final drafts = [
        {
          'id': 1,
          'nama': 'Penyulang 1-GI Sawahan',
          'data': validData,
        },
      ];
      final mapped = [
        const Il1KubikelItem(id: 101, nama: 'Penyulang 1', kode: 'P1', rel: 'Rel 1'),
      ];

      final res = Il1KubikelUtils.parseIl1KubikelDrafts(drafts, 10, mapped);
      expect(res.parsed.length, equals(1));
      expect(res.duplicates.length, equals(0));
    });

    test('Il1TrafoPsUtils validation and draft parser', () {
      final validData = <String, dynamic>{
        'fotoBuktiInspeksi': {'uri': '/path/to/trafo.jpg'},
        'merkTrafo': 'Trafindo',
        'tahunPembuatanTrafo': '2019',
        'noSeriTrafo': '12345',
        'kapasitasTrafo': '1000 kVA',
        'tapTrafo': '3',
        'jenisTrafo': 'INDOOR',
        'kebocoranBodyTrafo': ['TRAFO TIDAK ADA KEBOCORAN DI BODY TRAFO'],
        'kondisiFisikTrafo': ['MULUS BERSIH'],
        'kondisiRumahTrafo': ['ADA DAN BAIK'],
        'garduIndukId': 10,
        'trafoId': 201,
      };

      expect(Il1TrafoPsUtils.validateIl1TrafoPs(validData), isTrue);

      final invalidData = Map<String, dynamic>.from(validData);
      invalidData.remove('kebocoranBodyTrafo');
      expect(Il1TrafoPsUtils.validateIl1TrafoPs(invalidData), isFalse);

      final drafts = [
        {
          'id': 2,
          'nama': 'Trafo PS 1-GI Sawahan',
          'data': validData,
        },
      ];
      final mapped = [
        const Il1TrafoPsItem(id: 201, nama: 'Trafo PS 1'),
      ];

      final res = Il1TrafoPsUtils.parseIl1TrafoPsDrafts(drafts, 10, mapped);
      expect(res.parsed.length, equals(1));
    });

    test('Il1SipilUtils validation and draft parser', () {
      final validData = <String, dynamic>{
        'fotoBuktiInspeksi': {'uri': '/path/to/sipil.jpg'},
        'kondisiLampuPenerangan': 'BAIK',
        'jenisLampuPenerangan': 'LED',
        'jumlahLampuPenerangan': 10,
        'jumlahLampuPeneranganMati': 0,
        'keteranganLampuPenerangan': 'Baik',
        'kondisiRuangan': 'TIDAK',
        'jumlahACMenyalaNormal': 2,
        'jumlahACWindOnly': 0,
        'jumlahACBocor': 0,
        'keteranganAc': 'Dingin',
        'kondisiAtap': 'TIDAK',
        'mainholeTergenangAir': 'TIDAK',
        'powerSupplyAC': 'ADA',
        'kebersihanPanelDCBC': 'BERSIH',
        'kebersihanRuangBaterai': 'BERSIH',
        'suhuRuangBaterai': 25.0,
        'kelembabanRuangBaterai': 50.0,
        'kebersihanBaterai': 'BERSIH',
        'kebocoranBaterai': 'TIDAK',
        'exhaustFan': 'BERFUNGSI',
        'kondisiRuangBaterai': 'TIDAK',
        'teganganBeban': 110.0,
        'arusBeban': 5.0,
        'kondisiRectifier': 'BAIK',
        'kebersihanRuangRectifier': 'BERSIH',
        'suhuRuangRectifier': 25.0,
        'kelembabanRuangRectifier': 50.0,
        'kebersihanPanel': 'BERSIH',
        'kondisiMMI': 'BAIK',
        'kondisiMouseKomputer': 'BAIK',
        'kondisiKeyboardKomputer': 'BAIK',
        'kondisiInternet': 'BAIK',
        'kondisiRadio': 'BAIK',
        'kondisiYealink': 'BAIK',
        'garduIndukId': 10,
      };

      expect(Il1SipilUtils.validateIl1Sipil(validData), isTrue);

      final bocorData = Map<String, dynamic>.from(validData);
      bocorData['kondisiAtap'] = 'BOCOR';
      expect(Il1SipilUtils.validateIl1Sipil(bocorData), isFalse);
      bocorData['letakKebocoranAtap'] = 'Pojok Kiri';
      expect(Il1SipilUtils.validateIl1Sipil(bocorData), isTrue);

      final drafts = [
        {
          'id': 3,
          'nama': 'CELL-Gedung Kontrol',
          'data': validData,
        },
      ];
      final mapped = [
        const Il1SipilItem(id: 301, garduIndukId: 10, nama: 'Gedung Kontrol', gedung: 'CELL'),
      ];

      final res = Il1SipilUtils.parseIl1SipilDrafts(drafts, 10, mapped);
      expect(res.parsed.length, equals(1));
    });
  });

  group('OpgiIl1Cubit Tests', () {
    late _FakeOpgiRepository repo;
    late OpgiIl1Cubit cubit;

    setUp(() {
      repo = _FakeOpgiRepository();
      cubit = OpgiIl1Cubit(repo);
    });

    tearDown(() {
      cubit.close();
    });

    test('loadKubikel populates cachedKubikelList', () async {
      repo.kubikelList = [
        const Il1KubikelItem(id: 1, nama: 'Penyulang 1', kode: 'P1', rel: 'Rel 1'),
      ];

      await cubit.loadKubikel(10);
      expect(cubit.cachedKubikelList.length, equals(1));
      expect(cubit.cachedKubikelList.first.nama, equals('Penyulang 1'));
    });

    test('submitKubikelSingle updates in-memory list optimistically', () async {
      repo.kubikelList = [
        const Il1KubikelItem(id: 1, nama: 'Penyulang 1', kode: 'P1', rel: 'Rel 1'),
      ];
      await cubit.loadKubikel(10);

      await cubit.submitKubikelSingle(
        data: {
          'penyulangId': 1,
          'garduIndukId': 10,
          'status': 'SESUAI STANDAR',
        },
      );

      expect(cubit.cachedKubikelList.first.il1, isNotEmpty);
      expect(cubit.cachedKubikelList.first.status, equals('SESUAI STANDAR'));
    });

    test('submitTrafoPsSingle updates in-memory list optimistically', () async {
      repo.trafoPsList = [
        const Il1TrafoPsItem(id: 201, nama: 'Trafo PS 1'),
      ];
      await cubit.loadTrafoPs(10);

      await cubit.submitTrafoPsSingle(
        data: {
          'trafoId': 201,
          'garduIndukId': 10,
        },
      );

      expect(cubit.cachedTrafoPsList.first.il1TrafoPS, isNotEmpty);
      expect(cubit.cachedTrafoPsList.first.status, equals('NORMAL'));
    });

    test('submitSipilSingle updates in-memory list optimistically', () async {
      repo.sipilList = [
        const Il1SipilItem(id: 301, garduIndukId: 10, nama: 'Gedung Kontrol', gedung: 'CELL'),
      ];
      await cubit.loadSipil(10);

      await cubit.submitSipilSingle(
        data: {
          'sipilId': 301,
          'garduIndukId': 10,
          'status': 'SESUAI STANDAR',
        },
      );

      expect(cubit.cachedSipilList.first.il1Sipil, isNotEmpty);
      expect(cubit.cachedSipilList.first.status, equals('SESUAI STANDAR'));
    });

    test('deleteKubikel optimistically removes inspection from list and detail', () async {
      repo.kubikelList = [
        const Il1KubikelItem(
          id: 1,
          nama: 'Penyulang 1',
          kode: 'P1',
          rel: 'Rel 1',
          last: {'id': 99, 'status': 'NORMAL'},
          il1: [{'id': 99, 'status': 'NORMAL'}],
        ),
      ];
      await cubit.loadKubikel(10);

      await cubit.deleteKubikel(99, penyulangId: 1);

      expect(cubit.cachedKubikelToday, isNull);
      expect(cubit.cachedKubikelList.first.il1, isEmpty);
      expect(cubit.cachedKubikelList.first.last, isNull);
    });

    test('deleteTrafoPs optimistically removes inspection from list and detail', () async {
      repo.trafoPsList = [
        const Il1TrafoPsItem(
          id: 201,
          nama: 'Trafo PS 1',
          last: {'id': 99, 'status': 'NORMAL'},
          il1TrafoPS: [{'id': 99, 'status': 'NORMAL'}],
        ),
      ];
      await cubit.loadTrafoPs(10);

      await cubit.deleteTrafoPs(99, trafoId: 201);

      expect(cubit.cachedTrafoPsToday, isNull);
      expect(cubit.cachedTrafoPsList.first.il1TrafoPS, isEmpty);
      expect(cubit.cachedTrafoPsList.first.last, isNull);
    });

    test('deleteSipil optimistically removes inspection from list and detail', () async {
      repo.sipilList = [
        const Il1SipilItem(
          id: 301,
          garduIndukId: 10,
          nama: 'Gedung Kontrol',
          gedung: 'CELL',
          last: {'id': 99, 'status': 'SESUAI STANDAR'},
          il1Sipil: [{'id': 99, 'status': 'SESUAI STANDAR'}],
        ),
      ];
      await cubit.loadSipil(10);

      await cubit.deleteSipil(99, sipilId: 301);

      expect(cubit.cachedSipilToday, isNull);
      expect(cubit.cachedSipilList.first.il1Sipil, isEmpty);
      expect(cubit.cachedSipilList.first.last, isNull);
    });
  });
}
