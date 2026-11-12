import 'package:image_picker/image_picker.dart';
import '../../data/models/gardu_induk_model.dart';
import '../../data/models/opgi_realisasi_model.dart';
import '../../data/models/opgi_manuver_model.dart';
import '../../data/models/opgi_anomali_model.dart';
import '../../data/models/opgi_il1_model.dart';

abstract class OpgiRepository {
  Future<List<GarduIndukModel>> getGarduIndukList({String timezone = 'Asia/Jakarta'});

  // Realisasi
  Future<List<BebanTrafoModel>> getBebanTrafoInput(int garduIndukId, String date);
  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone);
  Future<List<BebanTrafoModel>> getBebanTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<List<BebanTrafoTodayItemModel>> getBebanTrafoToday(int trafoId, {required int garduIndukId, String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Map<String, dynamic>?> submitBebanTrafoSingle({required dynamic file, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> updateBebanTrafoMobile(int bebanId, {required dynamic file, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> deleteBebanTrafo(int bebanId);

  Future<List<PenyulangModel>> getPenyulangList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date, {bool forceRefresh = false});
  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, String timezone);
  Future<Map<String, dynamic>?> submitBebanPenyulangSingle({required dynamic file, required Map<String, dynamic> data});
  Future<List<BebanPenyulangTodayItemModel>> getBebanPenyulangToday(int penyulangId, {required int garduIndukId, String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Map<String, dynamic>?> updateBebanPenyulangMobile(int bebanId, {required dynamic file, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> deleteBebanPenyulang(int bebanId);
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items);
  Future<void> updateUrutanPenyulangCustom(List<Map<String, dynamic>> items);

  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date);
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone);
  Future<List<KwhHarianModel>> getKwhHarianList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<List<KwhHarianTodayItemModel>> getKwhHarianToday(int objectId, {required String type, required String kelompok, String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Map<String, dynamic>?> submitKwhHarianSingle({required List<Map<String, dynamic>> filesWithJenis, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> updateKwhHarianMobile(int id, {required dynamic file, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> deleteKwhHarianToday(List<int> ids);

  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date);
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone);
  Future<List<TeganganTrafoModel>> getTeganganTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<List<TeganganTrafoTodayItemModel>> getTeganganTrafoToday(int trafoId, {required int garduIndukId, String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Map<String, dynamic>?> submitTeganganTrafoSingle({required dynamic fileMV, required dynamic fileHV, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> updateTeganganTrafoMobile(int teganganId, {dynamic fileMV, dynamic fileHV, required Map<String, dynamic> data});
  Future<Map<String, dynamic>?> deleteTeganganTrafo(int teganganId);

  // Manuver
  Future<List<ManuverItemModel>> getManuverList(int garduIndukId, {String? timezone, bool forceRefresh = false});
  Future<List<ManuverItemModel>> getManuverHistory(int garduIndukId, {int? cursor});
  Future<List<ManuverProgressModel>> getManuverProgress(int manuverId, {String? timezone, bool forceRefresh = false});
  Future<Map<String, dynamic>> submitManuver(Map<String, dynamic> data, [dynamic file]);
  Future<Map<String, dynamic>> submitManuverProgress(Map<String, dynamic> data, [dynamic file]);
  Future<Map<String, dynamic>> updateManuverProgress(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>> deleteManuver(int id);
  Future<Map<String, dynamic>> deleteManuverProgress(int id);
  Future<List<Map<String, dynamic>>> getPenyulangByGi(int garduIndukId);

  // Anomali
  Future<List<AnomaliReportModel>> getAnomaliHistory(int garduIndukId, {int? cursor});
  Future<List<AnomaliKondisiModel>> getKondisiAnomaliHistory(int anomaliId, {int? cursor});
  Future<List<Map<String, dynamic>>> getAnomaliAssets(int garduIndukId, String jenisAsset);
  Future<void> submitAnomali({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  });
  Future<void> submitAnomaliKondisi({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  });
  Future<void> updateAnomaliKondisi(int kondisiId, Map<String, dynamic> data);
  Future<void> deleteAnomali(int id);
  Future<void> deleteAnomaliKondisi(int id);

  // IL1 Kubikel
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Il1KubikelTodayDetailModel?> getIl1KubikelToday(int penyulangId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<void> submitIl1Kubikel({
    required Map<String, dynamic> data,
    required List<XFile> files,
  });
  Future<Map<String, dynamic>?> submitIl1KubikelSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    dynamic fotoAnomali,
    String timezone = 'Asia/Jakarta',
  });
  Future<Map<String, dynamic>?> updateIl1Kubikel(int id, Map<String, dynamic> data, {dynamic fotoAnomali});
  Future<Map<String, dynamic>?> deleteIl1Kubikel(int id);
  Future<List<Map<String, dynamic>>> getTrafoList(int garduIndukId);
  Future<List<Map<String, dynamic>>> getRelList(int garduIndukId);

  // IL1 Trafo PS
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Il1TrafoPsTodayDetailModel?> getIl1TrafoPsToday(int trafoId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<void> submitIl1TrafoPs({
    required Map<String, dynamic> data,
    required XFile file,
  });
  Future<Map<String, dynamic>?> submitIl1TrafoPsSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  });
  Future<Map<String, dynamic>?> updateIl1TrafoPs(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> deleteIl1TrafoPs(int id);

  // IL1 Sipil
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<Il1SipilTodayDetailModel?> getIl1SipilToday(int sipilId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false});
  Future<void> submitIl1Sipil({
    required Map<String, dynamic> data,
    required XFile file,
  });
  Future<Map<String, dynamic>?> submitIl1SipilSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  });
  Future<Map<String, dynamic>?> updateIl1Sipil(int id, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> deleteIl1Sipil(int id);
}
