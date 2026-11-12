import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_i_mobile/features/opgi/data/models/gardu_induk_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_anomali_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_il1_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_manuver_model.dart';
import 'package:super_i_mobile/features/opgi/data/models/opgi_realisasi_model.dart';
import 'package:super_i_mobile/features/opgi/domain/repositories/opgi_repository.dart';
import 'package:super_i_mobile/features/opgi/presentation/constants/opgi_il1_constants.dart';
import 'package:super_i_mobile/features/opgi/presentation/cubit/opgi_il1_cubit.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/il1_hub_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/il1_kubikel_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/il1_trafo_ps_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/pages/il1_sipil_page.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/il1_dropdown_field.dart';
import 'package:super_i_mobile/features/opgi/presentation/widgets/il1_multi_select_field.dart';

class _MockOpgiRepo implements OpgiRepository {
  List<Il1KubikelItem> mockKubikel = [];
  List<Il1TrafoPsItem> mockTrafoPs = [];
  List<Il1SipilItem> mockSipil = [];

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
  Future<List<AnomaliKondisiModel>> getKondisiAnomaliHistory(int anomaliId, {int? cursor}) async => [];
  @override
  Future<List<Map<String, dynamic>>> getAnomaliAssets(int garduIndukId, String jenisAsset) async => [];
  @override
  Future<void> submitAnomali({required Map<String, dynamic> data, XFile? imageFile, XFile? videoFile}) async {}
  @override
  Future<void> submitAnomaliKondisi({required Map<String, dynamic> data, XFile? imageFile, XFile? videoFile}) async {}
  @override
  Future<void> updateAnomaliKondisi(int kondisiId, Map<String, dynamic> data) async {}
  @override
  Future<void> deleteAnomali(int id) async {}
  @override
  Future<void> deleteAnomaliKondisi(int id) async {}

  @override
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => mockKubikel;

  @override
  Future<Il1KubikelTodayDetailModel?> getIl1KubikelToday(int penyulangId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => null;

  @override
  Future<void> submitIl1Kubikel({required Map<String, dynamic> data, required List<XFile> files}) async {}

  @override
  Future<Map<String, dynamic>?> submitIl1KubikelSingle({required Map<String, dynamic> data, dynamic fotoBuktiInspeksi, dynamic fotoAnomali, String timezone = 'Asia/Jakarta'}) async => null;

  @override
  Future<Map<String, dynamic>?> updateIl1Kubikel(int id, Map<String, dynamic> data, {dynamic fotoAnomali}) async => null;

  @override
  Future<Map<String, dynamic>?> deleteIl1Kubikel(int id) async => null;

  @override
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => mockTrafoPs;

  @override
  Future<Il1TrafoPsTodayDetailModel?> getIl1TrafoPsToday(int trafoId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => null;

  @override
  Future<void> submitIl1TrafoPs({required Map<String, dynamic> data, required XFile file}) async {}

  @override
  Future<Map<String, dynamic>?> submitIl1TrafoPsSingle({required Map<String, dynamic> data, dynamic fotoBuktiInspeksi, String timezone = 'Asia/Jakarta'}) async => null;

  @override
  Future<Map<String, dynamic>?> updateIl1TrafoPs(int id, Map<String, dynamic> data) async => null;

  @override
  Future<Map<String, dynamic>?> deleteIl1TrafoPs(int id) async => null;

  @override
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => mockSipil;

  @override
  Future<Il1SipilTodayDetailModel?> getIl1SipilToday(int sipilId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async => null;

  @override
  Future<void> submitIl1Sipil({required Map<String, dynamic> data, required XFile file}) async {}

  @override
  Future<Map<String, dynamic>?> submitIl1SipilSingle({required Map<String, dynamic> data, dynamic fotoBuktiInspeksi, String timezone = 'Asia/Jakarta'}) async => null;

  @override
  Future<Map<String, dynamic>?> updateIl1Sipil(int id, Map<String, dynamic> data) async => null;

  @override
  Future<Map<String, dynamic>?> deleteIl1Sipil(int id) async => null;

  @override
  Future<List<Map<String, dynamic>>> getTrafoList(int garduIndukId) async => [];

  @override
  Future<List<Map<String, dynamic>>> getRelList(int garduIndukId) async => [];
}

void main() {
  group('IL1 Hub Page Tests', () {
    testWidgets('renders all 3 module cards and QR scanner buttons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Il1HubPage(
            garduIndukId: 10,
            garduIndukNama: 'GI Sawahan',
          ),
        ),
      );

      expect(find.text('Inspeksi Level 1 - GI Sawahan'), findsOneWidget);
      expect(find.text('IL1 KUBIKEL'), findsOneWidget);
      expect(find.text('IL1 TRAFO PS'), findsOneWidget);
      expect(find.text('IL1 SIPIL'), findsOneWidget);

      // Verify QR scanner icon buttons
      expect(find.byIcon(Icons.qr_code_scanner), findsNWidgets(2));
    });
  });

  group('IL1 Kubikel Page Tests', () {
    testWidgets('renders kubikel list items with status badges and action buttons', (tester) async {
      final repo = _MockOpgiRepo();
      repo.mockKubikel = [
        const Il1KubikelItem(
          id: 1,
          nama: 'Penyulang Mawar',
          kode: 'MWR',
          rel: 'Rel 1',
          status: 'NORMAL',
          last: {'id': 10, 'status': 'NORMAL'},
          il1: [{'id': 10, 'status': 'NORMAL'}],
        ),
        const Il1KubikelItem(
          id: 2,
          nama: 'Penyulang Melati',
          kode: 'MLT',
          rel: 'Rel 2',
        ),
      ];
      final cubit = OpgiIl1Cubit(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OpgiIl1Cubit>.value(
            value: cubit,
            child: const Il1KubikelPage(
              garduIndukId: 10,
              garduIndukNama: 'GI Sawahan',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Penyulang Mawar'), findsOneWidget);
      expect(find.text('Penyulang Melati'), findsOneWidget);
      expect(find.text('NORMAL'), findsOneWidget);

      // Lihat and Input buttons
      expect(find.text('Lihat'), findsNWidgets(2));
      expect(find.text('Input'), findsNWidgets(2));
    });
  });

  group('IL1 Trafo PS Page Tests', () {
    testWidgets('renders trafo PS items with cards and buttons', (tester) async {
      final repo = _MockOpgiRepo();
      repo.mockTrafoPs = [
        const Il1TrafoPsItem(
          id: 1,
          nama: 'Trafo PS 1',
          status: 'NORMAL',
          last: {'id': 20, 'status': 'NORMAL'},
          il1TrafoPS: [{'id': 20, 'status': 'NORMAL'}],
        ),
      ];
      final cubit = OpgiIl1Cubit(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OpgiIl1Cubit>.value(
            value: cubit,
            child: const Il1TrafoPsPage(
              garduIndukId: 10,
              garduIndukNama: 'GI Sawahan',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Trafo PS 1'), findsOneWidget);
      expect(find.text('NORMAL'), findsOneWidget);
      expect(find.text('Lihat'), findsOneWidget);
    });
  });

  group('IL1 Sipil Page Tests', () {
    testWidgets('renders sipil items with gedung and buttons', (tester) async {
      final repo = _MockOpgiRepo();
      repo.mockSipil = [
        const Il1SipilItem(
          id: 1,
          garduIndukId: 10,
          nama: 'Ruang Kontrol',
          gedung: 'CELL',
          status: 'SESUAI STANDAR',
          last: {'id': 30, 'status': 'SESUAI STANDAR'},
          il1Sipil: [{'id': 30, 'status': 'SESUAI STANDAR'}],
        ),
      ];
      final cubit = OpgiIl1Cubit(repo);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<OpgiIl1Cubit>.value(
            value: cubit,
            child: const Il1SipilPage(
              garduIndukId: 10,
              garduIndukNama: 'GI Sawahan',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CELL'), findsOneWidget);
      expect(find.text('Ruang Kontrol'), findsOneWidget);
      expect(find.text('SESUAI STANDAR'), findsOneWidget);
    });
  });

  group('IL1 Form Fields Widget Tests', () {
    testWidgets('Il1DropdownField renders and reacts to changes', (tester) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Il1DropdownField(
              label: 'Kondisi Lampu',
              options: OpgiIl1Constants.sipilBaikTidak,
              value: 'BAIK',
              onChanged: (val) => selected = val,
            ),
          ),
        ),
      );

      expect(find.text('Kondisi Lampu'), findsOneWidget);
      expect(find.text('Baik'), findsOneWidget);

      await tester.tap(find.text('Baik'));
      await tester.pumpAndSettle();

      expect(find.text('Tidak').last, findsOneWidget);
      await tester.tap(find.text('Tidak').last);
      await tester.pumpAndSettle();

      expect(selected, equals('TIDAK'));
    });

    testWidgets('Il1MultiSelectField displays chips and opens selection modal', (tester) async {
      List<String> values = ['NORMAL'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Il1MultiSelectField(
                  label: 'Keterangan PMT',
                  options: OpgiIl1Constants.kubikelKeteranganPMT,
                  selectedValues: values,
                  onChanged: (newVals) => setState(() => values = newVals),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Keterangan PMT'), findsOneWidget);
      expect(find.text('Normal'), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Pilih'), findsOneWidget);
    });
  });
}
