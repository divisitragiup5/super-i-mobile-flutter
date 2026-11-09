import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/features/line_walker/data/models/pembumian_model.dart';
import 'package:super_i_mobile/features/line_walker/data/models/ppl_model.dart';
import 'package:super_i_mobile/features/line_walker/data/models/kegiatan_sosial_model.dart';
import 'package:super_i_mobile/features/line_walker/data/models/waterpass_model.dart';
import 'package:super_i_mobile/core/utils/download_ba_helper.dart';

void main() {
  group('History Models Synchronization Tests', () {
    test('PembumianHistoryItemModel keeps rawJson and parses status properly', () {
      final json = {
        'id': 101,
        'towerId': 5,
        'tower': {'id': 5, 'nama': 'T.01 #A'},
        'createdAt': '2026-11-05T08:00:00Z',
        'ukurPembumianStatus': 'kritis',
        'kondisiPembumianStatus': 'normal',
        'legA': {
          'hasil': '3.5',
          'status': 'NORMAL',
          'pict': {'uri': 'photo_a.jpg'},
          'statusPict': {'uri': 'status_a.jpg'},
        },
      };

      final model = PembumianHistoryItemModel.fromJson(json);
      expect(model.id, 101);
      expect(model.towerId, 5);
      expect(model.namaTower, 'T.01 #A');
      expect(model.ukurPembumianStatus, 'kritis');
      expect(model.rawJson['legA']?['hasil'], '3.5');
    });

    test('WaterpassDetailModel parses safely and holds rawJson', () {
      final json = {
        'id': 202,
        'tower': {'id': 12, 'nama': 'T.12'},
        'createdAt': '2026-11-05T09:00:00Z',
        'waterpassX': {'hasil': 0.12, 'pict': {'uri': 'x.jpg'}},
        'waterpassY': {'hasil': '0.34', 'pict': {'uri': 'y.jpg'}},
      };

      final model = WaterpassDetailModel.fromJson(json);
      expect(model.id, 202);
      expect(model.hasilX, 0.12);
      expect(model.hasilY, 0.34);
      expect(model.hasilZ, isNull);
      expect(model.fotoXUrl, 'x.jpg');
      expect(model.rawJson['waterpassX']?['hasil'], 0.12);
    });

    test('PPLHistoryItemModel retains all legacy fields and rawJson', () {
      final json = {
        'id': 303,
        'towerId': 20,
        'identifier': 'ident-ppl-99',
        'tower': {'id': 20, 'nama': 'Tower 20'},
        'namaPekerjaan': 'Galian Kabel',
        'pihakPelaksana': 'PT ABC',
        'pplStatus': 'bahaya',
        'totalUpdate': 3,
        'belumTTDTLGI': 1,
        'sudahTTDTLGI': 2,
        'isLocked': false,
        'jenisObjek': 'Gedung',
        'pjPekerjaan': 'Budi',
        'noTeleponPJPekerjaan': '08123456789',
      };

      final model = PPLHistoryItemModel.fromJson(json);
      expect(model.identifier, 'ident-ppl-99');
      expect(model.totalUpdate, 3);
      expect(model.belumTTDTLGI, 1);
      expect(model.sudahTTDTLGI, 2);
      expect(model.isLocked, false);
      expect(model.rawJson['pjPekerjaan'], 'Budi');
    });

    test('KegiatanSosialHistoryItemModel parses correctly with all status badges', () {
      final json = {
        'id': 404,
        'towerId': 30,
        'identifier': 'ident-ks-55',
        'tower': {'id': 30, 'nama': 'Tower 30'},
        'namaAktivitas': 'Sosialisasi ROW',
        'kategoriAktivitas': 'WASPADA',
        'pelakuAktivitasSosial': 'Warga Desa',
        'totalUpdate': 2,
        'belumTTDTLGI': 0,
        'sudahTTDTLGI': 2,
        'isEditable': true,
        'temuan': 'Pohon mendekati konduktor',
        'jumlahTemuan': 2,
      };

      final model = KegiatanSosialHistoryItemModel.fromJson(json);
      expect(model.identifier, 'ident-ks-55');
      expect(model.towerId, 30);
      expect(model.namaTower, 'Tower 30');
      expect(model.kategoriAktivitas, 'WASPADA');
      expect(model.isEditable, true);
      expect(model.rawJson['jumlahTemuan'], 2);
    });

    test('DownloadBaHelper saves bytes and handles file name sanitation properly', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final bytes = [1, 2, 3, 4, 5];
      final path = await DownloadBaHelper.saveFile(
        bytes: bytes,
        rawFileName: 'BA Pembumian #Tower 10',
        contentType: 'application/pdf',
      );
      expect(path.endsWith('BA-Pembumian-Tower-10.pdf'), isTrue);
    });
  });
}
