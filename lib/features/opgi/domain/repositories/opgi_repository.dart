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

  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date);
  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, String timezone);
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items);

  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date);
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone);

  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date);
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone);

  // Manuver
  Future<List<ManuverModel>> getManuverHistory(int garduIndukId, {int? cursor});
  Future<void> submitManuver(Map<String, dynamic> data);
  Future<void> deleteManuver(int id);

  // Anomali
  Future<List<AnomaliReportModel>> getAnomaliHistory(int garduIndukId, {int? cursor});
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
  Future<void> deleteAnomali(int id);
  Future<void> deleteAnomaliKondisi(int id);

  // IL1
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta'});
  Future<void> submitIl1Kubikel({
    required Map<String, dynamic> data,
    required List<XFile> files,
  });

  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta'});
  Future<void> submitIl1TrafoPs({
    required Map<String, dynamic> data,
    required XFile file,
  });

  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta'});
  Future<void> submitIl1Sipil({
    required Map<String, dynamic> data,
    required XFile file,
  });
}
