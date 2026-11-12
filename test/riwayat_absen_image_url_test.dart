import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/constants/api_constants.dart';
import 'package:super_i_mobile/core/utils/app_url_utils.dart';
import 'package:super_i_mobile/features/riwayat_absen/data/models/riwayat_absen_model.dart';
import 'package:super_i_mobile/features/riwayat_absen/presentation/pages/riwayat_absen_detail_page.dart';

void main() {
  group('AppUrlUtils Image URL Normalization Tests', () {
    test('returns exact URL if already starting with http:// or https://', () {
      expect(
        AppUrlUtils.getFullImageUrl('https://example.com/foto.jpg'),
        'https://example.com/foto.jpg',
      );
      expect(
        AppUrlUtils.getFullImageUrl('http://example.com/foto.jpg'),
        'http://example.com/foto.jpg',
      );
    });

    test('adds base URL from ApiConstants when path is relative or lacks schema', () {
      final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
      
      final result1 = AppUrlUtils.getFullImageUrl('/media/images/absensi/foto_in.jpg');
      expect(result1, '$base/media/images/absensi/foto_in.jpg');

      final result2 = AppUrlUtils.getFullImageUrl('media/images/absensi/foto_out.jpg');
      expect(result2, '$base/media/images/absensi/foto_out.jpg');
    });

    test('normalizes Windows backslashes properly', () {
      final base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');
      final result = AppUrlUtils.getFullImageUrl(r'media\images\absensi\foto.jpg');
      expect(result, '$base/media/images/absensi/foto.jpg');
    });

    test('handles empty or null URL gracefully', () {
      expect(AppUrlUtils.getFullImageUrl(null), '');
      expect(AppUrlUtils.getFullImageUrl(''), '');
      expect(AppUrlUtils.getFullImageUrl('   '), '');
    });
  });

  group('RiwayatAbsenItemModel JSON Parsing', () {
    test('parses pictureIn, pictureOut, and fotoBuktiPremi correctly from Map or String', () {
      final jsonMap = {
        'id': 123,
        'keterangan': 'HADIR',
        'pictureIn': {'uri': '/media/images/absensi/in.jpg'},
        'pictureOut': {'uri': '/media/images/absensi/out.jpg'},
        'fotoBuktiPremi': {'uri': '/media/images/absensi/bukti.jpg'},
        'premi': 'ON',
      };

      final model = RiwayatAbsenItemModel.fromJson(jsonMap);
      expect(model.pictureInUri, '/media/images/absensi/in.jpg');
      expect(model.pictureOutUri, '/media/images/absensi/out.jpg');
      expect(model.fotoBuktiPremi, '/media/images/absensi/bukti.jpg');

      final jsonString = {
        'id': 124,
        'keterangan': 'SAKIT',
        'pictureIn': '/media/images/absensi/in2.jpg',
        'pictureOut': '/media/images/absensi/out2.jpg',
        'fotoBuktiPremi': '/media/images/absensi/bukti2.jpg',
        'premi': 'OFF',
      };

      final model2 = RiwayatAbsenItemModel.fromJson(jsonString);
      expect(model2.pictureInUri, '/media/images/absensi/in2.jpg');
      expect(model2.pictureOutUri, '/media/images/absensi/out2.jpg');
      expect(model2.fotoBuktiPremi, '/media/images/absensi/bukti2.jpg');
    });
  });

  group('RiwayatAbsenDetailPage Widget Tests', () {
    testWidgets('renders RiwayatAbsenDetailPage with relative image paths without crashing', (tester) async {
      final item = RiwayatAbsenItemModel(
        id: 1,
        keterangan: 'HADIR',
        jamMasuk: 8,
        menitMasuk: 0,
        jamKeluar: 17,
        menitKeluar: 0,
        createdAt: '2026-05-10T08:00:00Z',
        absenMasuk: '2026-05-10T08:00:00Z',
        absenKeluar: '2026-05-10T17:00:00Z',
        statusIn: 'ON TIME',
        statusOut: 'ON TIME',
        durasiKerja: 540,
        premi: 'ON',
        pictureInUri: '/media/images/absensi/in.jpg',
        pictureOutUri: '/media/images/absensi/out.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RiwayatAbsenDetailPage(item: item),
        ),
      );

      expect(find.text('Detail Absensi'), findsOneWidget);
      expect(find.text('INFORMASI ABSENSI'), findsOneWidget);
      expect(find.text('Perbesar'), findsNWidgets(2));
    });

    testWidgets('renders RiwayatAbsenDetailPage for SAKIT/OFF with document thumbnail', (tester) async {
      final item = RiwayatAbsenItemModel(
        id: 2,
        keterangan: 'SAKIT',
        jamMasuk: 8,
        menitMasuk: 0,
        jamKeluar: 17,
        menitKeluar: 0,
        createdAt: '2026-05-10T08:00:00Z',
        premi: 'OFF',
        diagnosaSakit: 'Demam',
        fotoBuktiPremi: 'media/images/absensi/surat_dokter.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RiwayatAbsenDetailPage(item: item),
        ),
      );

      expect(find.text('Dokumen Bukti:'), findsOneWidget);
      expect(find.text('Diagnosa Sakit'), findsOneWidget);
      expect(find.text('Demam'), findsOneWidget);
      expect(find.text('Perbesar'), findsOneWidget);
    });
  });
}
