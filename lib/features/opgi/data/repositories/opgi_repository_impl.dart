import 'package:image_picker/image_picker.dart';
import '../../domain/repositories/opgi_repository.dart';
import '../datasources/opgi_remote_data_source.dart';
import '../models/gardu_induk_model.dart';
import '../models/opgi_realisasi_model.dart';
import '../models/opgi_manuver_model.dart';
import '../models/opgi_anomali_model.dart';
import '../models/opgi_il1_model.dart';

class OpgiRepositoryImpl implements OpgiRepository {
  final OpgiRemoteDataSource _remoteDataSource;

  OpgiRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<GarduIndukModel>> getGarduIndukList({String timezone = 'Asia/Jakarta'}) {
    return _remoteDataSource.getGarduIndukList(timezone: timezone);
  }

  // Realisasi: Beban Trafo
  @override
  Future<List<BebanTrafoModel>> getBebanTrafoInput(int garduIndukId, String date) {
    return _remoteDataSource.getBebanTrafoList(garduIndukId);
  }

  @override
  Future<List<BebanTrafoModel>> getBebanTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getBebanTrafoList(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<List<BebanTrafoTodayItemModel>> getBebanTrafoToday(
    int trafoId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) {
    return _remoteDataSource.getBebanTrafoToday(
      trafoId,
      garduIndukId: garduIndukId,
      timezone: timezone,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<Map<String, dynamic>?> submitBebanTrafoSingle({required dynamic file, required Map<String, dynamic> data}) {
    return _remoteDataSource.submitBebanTrafoSingle(file: file, data: data);
  }

  @override
  Future<Map<String, dynamic>?> updateBebanTrafoMobile(int bebanId, {required dynamic file, required Map<String, dynamic> data}) {
    return _remoteDataSource.updateBebanTrafoMobile(bebanId, file: file, data: data);
  }

  @override
  Future<Map<String, dynamic>?> deleteBebanTrafo(int bebanId) {
    return _remoteDataSource.deleteBebanTrafo(bebanId);
  }

  @override
  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitBebanTrafo(garduIndukId, items, timezone);
  }

  // Realisasi: Beban Penyulang
  @override
  Future<List<PenyulangModel>> getPenyulangList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getPenyulangList(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date, {bool forceRefresh = false}) {
    return _remoteDataSource.getBebanPenyulangInput(garduIndukId, date, forceRefresh: forceRefresh);
  }

  @override
  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitBebanPenyulang(garduIndukId, items, timezone);
  }

  @override
  Future<Map<String, dynamic>?> submitBebanPenyulangSingle({required dynamic file, required Map<String, dynamic> data}) {
    return _remoteDataSource.submitBebanPenyulangSingle(file: file, data: data);
  }

  @override
  Future<List<BebanPenyulangTodayItemModel>> getBebanPenyulangToday(
    int penyulangId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) {
    return _remoteDataSource.getBebanPenyulangToday(
      penyulangId,
      garduIndukId: garduIndukId,
      timezone: timezone,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<Map<String, dynamic>?> updateBebanPenyulangMobile(int bebanId, {required dynamic file, required Map<String, dynamic> data}) {
    return _remoteDataSource.updateBebanPenyulangMobile(bebanId, file: file, data: data);
  }

  @override
  Future<Map<String, dynamic>?> deleteBebanPenyulang(int bebanId) {
    return _remoteDataSource.deleteBebanPenyulang(bebanId);
  }

  @override
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) {
    return _remoteDataSource.updateUrutanPenyulang(garduIndukId, items);
  }

  @override
  Future<void> updateUrutanPenyulangCustom(List<Map<String, dynamic>> items) {
    return _remoteDataSource.updateUrutanPenyulangCustom(items);
  }

  // Realisasi: KWH Harian
  @override
  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date) {
    return _remoteDataSource.getKwhHarianList(garduIndukId);
  }

  @override
  Future<List<KwhHarianModel>> getKwhHarianList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getKwhHarianList(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<List<KwhHarianTodayItemModel>> getKwhHarianToday(
    int objectId, {
    required String type,
    required String kelompok,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) {
    return _remoteDataSource.getKwhHarianToday(
      objectId,
      type: type,
      kelompok: kelompok,
      timezone: timezone,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<Map<String, dynamic>?> submitKwhHarianSingle({
    required List<Map<String, dynamic>> filesWithJenis,
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.submitKwhHarianSingle(filesWithJenis: filesWithJenis, data: data);
  }

  @override
  Future<Map<String, dynamic>?> updateKwhHarianMobile(int id, {required dynamic file, required Map<String, dynamic> data}) {
    return _remoteDataSource.updateKwhHarianMobile(id, file: file, data: data);
  }

  @override
  Future<Map<String, dynamic>?> deleteKwhHarianToday(List<int> ids) {
    return _remoteDataSource.deleteKwhHarianToday(ids);
  }

  @override
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitKwhHarian(garduIndukId, items, timezone);
  }

  // Realisasi: Tegangan Trafo
  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date) {
    return _remoteDataSource.getTeganganTrafoList(garduIndukId);
  }

  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getTeganganTrafoList(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<List<TeganganTrafoTodayItemModel>> getTeganganTrafoToday(
    int trafoId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) {
    return _remoteDataSource.getTeganganTrafoToday(
      trafoId,
      garduIndukId: garduIndukId,
      timezone: timezone,
      forceRefresh: forceRefresh,
    );
  }

  @override
  Future<Map<String, dynamic>?> submitTeganganTrafoSingle({
    required dynamic fileMV,
    required dynamic fileHV,
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.submitTeganganTrafoSingle(fileMV: fileMV, fileHV: fileHV, data: data);
  }

  @override
  Future<Map<String, dynamic>?> updateTeganganTrafoMobile(
    int teganganId, {
    dynamic fileMV,
    dynamic fileHV,
    required Map<String, dynamic> data,
  }) {
    return _remoteDataSource.updateTeganganTrafoMobile(teganganId, fileMV: fileMV, fileHV: fileHV, data: data);
  }

  @override
  Future<Map<String, dynamic>?> deleteTeganganTrafo(int teganganId) {
    return _remoteDataSource.deleteTeganganTrafo(teganganId);
  }

  @override
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitTeganganTrafo(garduIndukId, items, timezone);
  }

  // Manuver
  @override
  Future<List<ManuverItemModel>> getManuverList(int garduIndukId, {String? timezone, bool forceRefresh = false}) {
    return _remoteDataSource.getManuverList(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<List<ManuverItemModel>> getManuverHistory(int garduIndukId, {int? cursor}) {
    return _remoteDataSource.getManuverHistory(garduIndukId, cursor: cursor);
  }

  @override
  Future<List<ManuverProgressModel>> getManuverProgress(int manuverId, {String? timezone, bool forceRefresh = false}) {
    return _remoteDataSource.getManuverProgress(manuverId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<Map<String, dynamic>> submitManuver(Map<String, dynamic> data, [dynamic file]) {
    return _remoteDataSource.submitManuver(data, file);
  }

  @override
  Future<Map<String, dynamic>> submitManuverProgress(Map<String, dynamic> data, [dynamic file]) {
    return _remoteDataSource.submitManuverProgress(data, file);
  }

  @override
  Future<Map<String, dynamic>> updateManuverProgress(int id, Map<String, dynamic> data) {
    return _remoteDataSource.updateManuverProgress(id, data);
  }

  @override
  Future<Map<String, dynamic>> deleteManuver(int id) {
    return _remoteDataSource.deleteManuver(id);
  }

  @override
  Future<Map<String, dynamic>> deleteManuverProgress(int id) {
    return _remoteDataSource.deleteManuverProgress(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getPenyulangByGi(int garduIndukId) {
    return _remoteDataSource.getPenyulangByGi(garduIndukId);
  }

  // Anomali
  @override
  Future<List<AnomaliReportModel>> getAnomaliHistory(int garduIndukId, {int? cursor}) {
    return _remoteDataSource.getAnomaliHistory(garduIndukId, cursor: cursor);
  }

  @override
  Future<List<Map<String, dynamic>>> getAnomaliAssets(int garduIndukId, String jenisAsset) {
    return _remoteDataSource.getAnomaliAssets(garduIndukId, jenisAsset);
  }

  @override
  Future<void> submitAnomali({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  }) {
    return _remoteDataSource.submitAnomali(
      data: data,
      imageFile: imageFile,
      videoFile: videoFile,
    );
  }

  @override
  Future<void> submitAnomaliKondisi({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  }) {
    return _remoteDataSource.submitAnomaliKondisi(
      data: data,
      imageFile: imageFile,
      videoFile: videoFile,
    );
  }

  @override
  Future<void> deleteAnomali(int id) {
    return _remoteDataSource.deleteAnomali(id);
  }

  @override
  Future<void> deleteAnomaliKondisi(int id) {
    return _remoteDataSource.deleteAnomaliKondisi(id);
  }

  // IL1 Kubikel
  @override
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getIl1KubikelInput(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<Il1KubikelTodayDetailModel?> getIl1KubikelToday(int penyulangId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getIl1KubikelToday(penyulangId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<void> submitIl1Kubikel({
    required Map<String, dynamic> data,
    required List<XFile> files,
  }) {
    return _remoteDataSource.submitIl1Kubikel(data: data, files: files);
  }

  @override
  Future<Map<String, dynamic>?> submitIl1KubikelSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    dynamic fotoAnomali,
    String timezone = 'Asia/Jakarta',
  }) {
    return _remoteDataSource.submitIl1KubikelSingle(
      data: data,
      fotoBuktiInspeksi: fotoBuktiInspeksi,
      fotoAnomali: fotoAnomali,
      timezone: timezone,
    );
  }

  @override
  Future<Map<String, dynamic>?> updateIl1Kubikel(int id, Map<String, dynamic> data, {dynamic fotoAnomali}) {
    return _remoteDataSource.updateIl1Kubikel(id, data, fotoAnomali: fotoAnomali);
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1Kubikel(int id) {
    return _remoteDataSource.deleteIl1Kubikel(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getTrafoList(int garduIndukId) {
    return _remoteDataSource.getTrafoList(garduIndukId);
  }

  @override
  Future<List<Map<String, dynamic>>> getRelList(int garduIndukId) {
    return _remoteDataSource.getRelList(garduIndukId);
  }

  // IL1 Trafo PS
  @override
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getIl1TrafoPsInput(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<Il1TrafoPsTodayDetailModel?> getIl1TrafoPsToday(int trafoId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getIl1TrafoPsToday(trafoId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<void> submitIl1TrafoPs({
    required Map<String, dynamic> data,
    required XFile file,
  }) {
    return _remoteDataSource.submitIl1TrafoPs(data: data, file: file);
  }

  @override
  Future<Map<String, dynamic>?> submitIl1TrafoPsSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  }) {
    return _remoteDataSource.submitIl1TrafoPsSingle(
      data: data,
      fotoBuktiInspeksi: fotoBuktiInspeksi,
      timezone: timezone,
    );
  }

  @override
  Future<Map<String, dynamic>?> updateIl1TrafoPs(int id, Map<String, dynamic> data) {
    return _remoteDataSource.updateIl1TrafoPs(id, data);
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1TrafoPs(int id) {
    return _remoteDataSource.deleteIl1TrafoPs(id);
  }

  // IL1 Sipil
  @override
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getIl1SipilInput(garduIndukId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<Il1SipilTodayDetailModel?> getIl1SipilToday(int sipilId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) {
    return _remoteDataSource.getIl1SipilToday(sipilId, timezone: timezone, forceRefresh: forceRefresh);
  }

  @override
  Future<void> submitIl1Sipil({
    required Map<String, dynamic> data,
    required XFile file,
  }) {
    return _remoteDataSource.submitIl1Sipil(data: data, file: file);
  }

  @override
  Future<Map<String, dynamic>?> submitIl1SipilSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  }) {
    return _remoteDataSource.submitIl1SipilSingle(
      data: data,
      fotoBuktiInspeksi: fotoBuktiInspeksi,
      timezone: timezone,
    );
  }

  @override
  Future<Map<String, dynamic>?> updateIl1Sipil(int id, Map<String, dynamic> data) {
    return _remoteDataSource.updateIl1Sipil(id, data);
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1Sipil(int id) {
    return _remoteDataSource.deleteIl1Sipil(id);
  }
}
