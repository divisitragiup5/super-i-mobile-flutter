import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/features/distribusi/data/models/sutm_form_constants.dart';
import 'package:super_i_mobile/features/distribusi/data/models/sutm_inspection_payload.dart';
import 'package:super_i_mobile/features/distribusi/data/models/sutm_workorder_model.dart';
import 'package:super_i_mobile/features/distribusi/presentation/pages/validasi_detail_workorder_page.dart';

void main() {
  group('SutmInspectionPayload Tests', () {
    test('buildJsonPayload correctly formats standard fields and nested rows', () {
      final formValues = <String, dynamic>{
        '1_jenis_tiang': 'Beton',
        '1_tinggi_tiang': '12 Meter',
        '1_kondisi_tiang': 'Baik',
        '2_thermal_sambungan_min': '28.0',
        '2_thermal_sambungan_fasa_r_max': '30.5',
        '2_pd_terminasi_fasa_r': 'Baik',
        '7_rows': [
          {
            'jenisEntitas': 'Pohon',
            'jarak': '< 2.5 Meter',
            'fasa': 'R',
            'latitude': -6.2000,
            'longitude': 106.8166,
          }
        ],
      };

      final payload = SutmInspectionPayload.buildJsonPayload(
        formValues: formValues,
        workOrderSutmItemId: 123,
        sutmId: 456,
        latitude: -6.2000,
        longitude: 106.8166,
        startTime: DateTime(2026, 11, 13, 8, 0),
        endTime: DateTime(2026, 11, 13, 9, 0),
      );

      expect(payload['workOrderSUTMItemId'], 123);
      expect(payload['sutmId'], 456);
      expect(payload['jenisTiang'], 'Beton');
      expect((payload['kondisiTiang'] as Map<String, dynamic>)['kondisi'], contains('Baik'));

      final thermal = payload['thermalSambungan'] as List<dynamic>;
      expect(thermal.length, 1);
      expect(thermal.first['fasa'], 'R');
      expect((thermal.first['thermal'] as Map<String, dynamic>)['max'], 30.5);

      final pd = payload['partialDischargeTerminasi'] as List<dynamic>;
      expect(pd.length, 1);
      expect(pd.first['fasa'], 'R');
      expect(pd.first['partialDischarge'], 'Baik');

      final rowList = payload['row'] as List<dynamic>;
      expect(rowList.length, 1);
      expect(rowList.first['jenisEntitas'], 'Pohon');
      expect(rowList.first['jarak'], '< 2.5 Meter');
    });

    test('buildFormData attaches files and JSON string', () {
      final formValues = <String, dynamic>{
        '1_jenis_tiang': 'Beton',
      };

      final formData = SutmInspectionPayload.buildFormData(
        formValues: formValues,
        workOrderSutmItemId: 10,
        sutmId: 20,
        latitude: -6.2,
        longitude: 106.8,
        startTime: DateTime(2026, 11, 13, 8, 0),
        endTime: DateTime(2026, 11, 13, 9, 0),
      );

      expect(formData.fields.any((f) => f.key == 'data'), isTrue);
    });
  });

  group('Attachment requirement logic tests', () {
    bool isAttachmentRequired({
      required String key,
      required Map<String, dynamic> formValues,
      required String mode,
    }) {
      if (mode == 'validate') return false;

      // Always required
      if (key == 'jenisKonstruksiFoto' || key == 'jenisKonduktorFoto') {
        return true;
      }

      // Ukur pembumian / grounding foto
      if (key == 'ukurKawatPembumianFoto') {
        final val = formValues['hasil_ukur_pembumian'];
        return val != null && val.toString().trim().isNotEmpty;
      }
      if (key == 'ukurGroundingFoto') {
        final val = formValues['hasil_ukur_grounding'];
        return val != null && val.toString().trim().isNotEmpty;
      }

      // ROW photos
      if (key.startsWith('rowFoto')) {
        return true;
      }

      // Default condition: required if value != 'Baik' and value != 'Tidak Ada'
      final val = formValues[key]?.toString();
      if (val != null && val.isNotEmpty && val != 'Baik' && val != 'Tidak Ada') {
        return true;
      }

      return false;
    }

    test('jenisKonstruksiFoto and jenisKonduktorFoto always required in normal mode', () {
      expect(
        isAttachmentRequired(
          key: 'jenisKonstruksiFoto',
          formValues: {},
          mode: 'normal',
        ),
        isTrue,
      );
      expect(
        isAttachmentRequired(
          key: 'jenisKonduktorFoto',
          formValues: {},
          mode: 'normal',
        ),
        isTrue,
      );
    });

    test('Photos are optional in validate mode', () {
      expect(
        isAttachmentRequired(
          key: 'jenisKonstruksiFoto',
          formValues: {},
          mode: 'validate',
        ),
        isFalse,
      );
    });

    test('Anomaly photos are required when value is not Baik or Tidak Ada', () {
      expect(
        isAttachmentRequired(
          key: 'kondisiTiangFoto',
          formValues: {'kondisiTiangFoto': 'Retak'},
          mode: 'normal',
        ),
        isTrue,
      );
      expect(
        isAttachmentRequired(
          key: 'kondisiTiangFoto',
          formValues: {'kondisiTiangFoto': 'Baik'},
          mode: 'normal',
        ),
        isFalse,
      );
    });

    test('Measurement photos are required only if measurement field has value', () {
      expect(
        isAttachmentRequired(
          key: 'ukurGroundingFoto',
          formValues: {'hasil_ukur_grounding': '4.2'},
          mode: 'normal',
        ),
        isTrue,
      );
      expect(
        isAttachmentRequired(
          key: 'ukurGroundingFoto',
          formValues: {'hasil_ukur_grounding': ''},
          mode: 'normal',
        ),
        isFalse,
      );
    });
  });

  group('SutmFormConstants consistency', () {
    test('Dropdown choices match expected values', () {
      expect(SutmFormConstants.jenisTiangOptions, contains('Beton'));
      expect(SutmFormConstants.tinggiTiangOptions, contains('12 Meter'));
      expect(SutmFormConstants.kondisiTiangOptions, contains('Retak'));
      expect(SutmFormConstants.jenisKonstruksiOptions, contains('TM 1'));
      expect(SutmFormConstants.jenisKonduktorOptions, contains('A3C'));
      expect(SutmFormConstants.crossArmOptions, contains('Bengkuk'));
      expect(SutmFormConstants.rowJenisEntitasOptions, contains('Pohon'));
    });
  });

  group('ValidasiDetailWorkorderPage Widget Tests', () {
    testWidgets('Renders workorder details and SUTM items with navigation arrow', (tester) async {
      const mockWo = SutmWorkOrderItem(
        id: 101,
        status: 'SUBMITTED',
        items: [
          SutmItemModel(
            id: 1,
            sutmId: 10,
            idAsset: 'SUTM-001',
            nama: 'Tiang 01 Feeder Melati',
            status: 'INSPECTED',
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ValidasiDetailWorkorderPage(workOrder: mockWo),
        ),
      );

      expect(find.text('Validasi WO #101'), findsOneWidget);
      expect(find.text('Total SUTM: 1 Item'), findsOneWidget);
      expect(find.text('Tiang 01 Feeder Melati'), findsOneWidget);
      expect(find.text('SUTM-001 • Status: INSPECTED'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsOneWidget);
    });
  });
}
