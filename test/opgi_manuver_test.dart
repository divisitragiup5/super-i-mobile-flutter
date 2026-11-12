import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/constants/role_constants.dart';
import 'package:super_i_mobile/core/utils/app_time_utils.dart';
import 'package:super_i_mobile/features/home/presentation/models/menu_item_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_manuver_model.dart';
import 'package:super_i_mobile/features/opgi/presentation/constants/opgi_manuver_constants.dart';
import 'package:super_i_mobile/features/opgi/presentation/cubit/opgi_manuver_cubit.dart';

void main() {
  group('OPGI Manuver Model Deserialization Tests', () {
    test('ManuverItemModel.fromJson parses raw dynamic map safely', () {
      final rawDynamicMap = <dynamic, dynamic>{
        'id': 101,
        'tipeManuver': 'GANGGUAN',
        'createdAt': '2026-11-12T10:00:00Z',
        'penyulang': <dynamic, dynamic>{
          'id': 55,
          'nama': 'Penyulang Cempaka',
        },
        'progres': <dynamic>[
          <dynamic, dynamic>{
            'id': 201,
            'objek': 'PMT',
            'status': 'OPEN',
            'posisi': 'TRIP',
            'jenisGangguan': <dynamic>['OC', 'GF'],
            'arus': <dynamic>[
              <dynamic, dynamic>{'type': 'Ia', 'satuan': 'A', 'value': 250},
            ],
            'operator': <dynamic, dynamic>{
              'petugas': <dynamic, dynamic>{
                'user': <dynamic, dynamic>{
                  'namaLengkap': 'Budi Santoso',
                },
              },
            },
            'dokumentasi': <dynamic, dynamic>{
              'uri': '/uploads/evidence1.jpg',
            },
          },
        ],
        'isDisabled': false,
      };

      final model = ManuverItemModel.fromJson(Map<String, dynamic>.from(rawDynamicMap));

      expect(model.id, 101);
      expect(model.tipeManuver, 'GANGGUAN');
      expect(model.penyulang.id, 55);
      expect(model.penyulang.nama, 'Penyulang Cempaka');
      expect(model.progres.length, 1);
      expect(model.isClose, false);

      final p = model.progres.first;
      expect(p.id, 201);
      expect(p.objek, 'PMT');
      expect(p.status, 'OPEN');
      expect(p.posisi, 'TRIP');
      expect(p.jenisGangguan, ['OC', 'GF']);
      expect(p.arus.length, 1);
      expect(p.arus.first.type, 'Ia');
      expect(p.arus.first.value, 250);
      expect(p.operator?.namaLengkap, 'Budi Santoso');
      expect(p.dokumentasi?.uri, '/uploads/evidence1.jpg');
    });

    test('ManuverItemModel.isClose is true when first progress is CLOSE', () {
      final raw = <String, dynamic>{
        'id': 102,
        'tipeManuver': 'PEKERJAAN',
        'penyulang': {'id': 1, 'nama': 'P1'},
        'progres': [
          {'id': 202, 'objek': 'PMT', 'status': 'CLOSE'},
        ],
      };

      final model = ManuverItemModel.fromJson(raw);
      expect(model.isClose, true);
    });
  });

  group('OPGI Manuver Constants & Options Tests', () {
    test('getStatusForObjek filters options by selected objek correctly', () {
      final pmtStatus = OpgiManuverConstants.getStatusForObjek('PMT');
      expect(pmtStatus.map((e) => e.value).toList(), containsAll(['OPEN', 'CLOSE']));

      final pmsRellStatus = OpgiManuverConstants.getStatusForObjek('PMS RELL + KABEL');
      expect(pmsRellStatus.map((e) => e.value).toList(), containsAll(['RACK IN', 'RACK OUT']));

      final pmsTanahStatus = OpgiManuverConstants.getStatusForObjek('PMS TANAH');
      expect(pmsTanahStatus.map((e) => e.value).toList(), containsAll(['KELUAR', 'MASUK']));
    });

    test('getStatusForObjek excludes CLOSE when excludeClose is true', () {
      final pmtStatusWithClose = OpgiManuverConstants.getStatusForObjek('PMT', excludeClose: false);
      expect(pmtStatusWithClose.any((s) => s.value == 'CLOSE'), isTrue);

      final pmtStatusWithoutClose = OpgiManuverConstants.getStatusForObjek('PMT', excludeClose: true);
      expect(pmtStatusWithoutClose.any((s) => s.value == 'CLOSE'), isFalse);
    });

    test('getPosisiForObjek filters options by selected objek correctly', () {
      final pmtPosisi = OpgiManuverConstants.getPosisiForObjek('PMT');
      expect(pmtPosisi.map((e) => e.value).toList(), ['TRIP']);

      final pmsRellPosisi = OpgiManuverConstants.getPosisiForObjek('PMS RELL + KABEL');
      expect(pmsRellPosisi.map((e) => e.value).toList(), ['RACK IN', 'RACK OUT']);
    });
  });

  group('OPGI Manuver Role Access Tests', () {
    test('Manuver menu allows operator, koordinator, team leader, and adminSuper', () {
      final manuverMenu = MenuItemModel.allMenus.firstWhere((m) => m.label == 'Manuver');
      expect(manuverMenu.allowedRoles, contains(AppRoles.operatorGi20kv));
      expect(manuverMenu.allowedRoles, contains(AppRoles.koordinatorGi20kv));
      expect(manuverMenu.allowedRoles, contains(AppRoles.teamLeaderGi));
      expect(manuverMenu.allowedRoles, contains(AppRoles.adminSuper));
    });
  });

  group('OPGI Manuver Deletion Logic Tests', () {
    bool canDelete({required bool isClose, required bool isAdminSuper}) {
      return isAdminSuper || !isClose;
    }

    test('Admin Super can delete item even when isClose is true', () {
      expect(canDelete(isClose: true, isAdminSuper: true), isTrue);
    });

    test('Non-admin user cannot delete item when isClose is true', () {
      expect(canDelete(isClose: true, isAdminSuper: false), isFalse);
    });

    test('Non-admin user can delete item when isClose is false', () {
      expect(canDelete(isClose: false, isAdminSuper: false), isTrue);
    });

    test('OpgiManuverSuccess preserves items and drafts when emitted', () {
      final sampleItem = ManuverItemModel.fromJson({
        'id': 101,
        'tipeManuver': 'GANGGUAN',
        'penyulang': {'id': 1, 'nama': 'Express 1'},
        'progres': [],
      });
      final state = OpgiManuverSuccess(
        'Berhasil dihapus',
        items: [sampleItem],
        drafts: [{'id': 99}],
      );

      expect(state.items, isNotNull);
      expect(state.items!.length, 1);
      expect(state.items!.first.id, 101);
      expect(state.drafts!.length, 1);
    });

    test('OpgiManuverSuccess preserves progress items when emitted', () {
      final sampleProgress = ManuverProgressModel.fromJson({
        'id': 202,
        'objek': 'PMT',
        'status': 'OPEN',
      });
      final state = OpgiManuverSuccess(
        'Progress berhasil dihapus',
        progressItems: [sampleProgress],
      );

      expect(state.progressItems, isNotNull);
      expect(state.progressItems!.length, 1);
      expect(state.progressItems!.first.id, 202);
    });
  });

  group('AppTimeUtils Timezone & Formatting Tests', () {
    test('deviceTimezone returns an Indonesian timezone string based on offset', () {
      final tz = AppTimeUtils.deviceTimezone;
      expect(['Asia/Jakarta', 'Asia/Makassar', 'Asia/Jayapura'], contains(tz));
    });

    test('parseToLocal converts UTC ISO string to local DateTime', () {
      const utcString = '2026-11-12T05:30:00Z';
      final localDt = AppTimeUtils.parseToLocal(utcString);

      expect(localDt, isNotNull);
      expect(localDt!.isUtc, isFalse);
      // Verify timezone offset is correctly applied
      final expectedHour = (5 + DateTime.now().timeZoneOffset.inHours) % 24;
      expect(localDt.hour, expectedHour);
    });

    test('parseToLocal returns null on null, empty, or invalid input', () {
      expect(AppTimeUtils.parseToLocal(null), isNull);
      expect(AppTimeUtils.parseToLocal(''), isNull);
      expect(AppTimeUtils.parseToLocal('   '), isNull);
      expect(AppTimeUtils.parseToLocal('not-a-valid-date'), isNull);
    });

    test('formatLocal formats UTC string into user local time format', () {
      const utcString = '2026-11-12T05:30:00Z';
      final formatted = AppTimeUtils.formatLocal(utcString, pattern: 'HH:mm');

      final expectedHour = (5 + DateTime.now().timeZoneOffset.inHours) % 24;
      final expectedHourStr = expectedHour.toString().padLeft(2, '0');
      expect(formatted, '$expectedHourStr:30');
    });

    test('formatLocal returns fallback for invalid or empty input', () {
      expect(AppTimeUtils.formatLocal(null, fallback: '-'), '-');
      expect(AppTimeUtils.formatLocal('', fallback: 'N/A'), 'N/A');
    });
  });
}
