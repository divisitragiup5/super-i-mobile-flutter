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

  // Realisasi
  @override
  Future<List<BebanTrafoModel>> getBebanTrafoInput(int garduIndukId, String date) {
    return _remoteDataSource.getBebanTrafoInput(garduIndukId, date);
  }

  @override
  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitBebanTrafo(garduIndukId, items, timezone);
  }

  @override
  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date) {
    return _remoteDataSource.getBebanPenyulangInput(garduIndukId, date);
  }

  @override
  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitBebanPenyulang(garduIndukId, items, timezone);
  }

  @override
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) {
    return _remoteDataSource.updateUrutanPenyulang(garduIndukId, items);
  }

  @override
  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date) {
    return _remoteDataSource.getKwhHarianInput(garduIndukId, date);
  }

  @override
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitKwhHarian(garduIndukId, items, timezone);
  }

  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date) {
    return _remoteDataSource.getTeganganTrafoInput(garduIndukId, date);
  }

  @override
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) {
    return _remoteDataSource.submitTeganganTrafo(garduIndukId, items, timezone);
  }

  // Manuver
  @override
  Future<List<ManuverModel>> getManuverHistory(int garduIndukId, {int? cursor}) {
    return _remoteDataSource.getManuverHistory(garduIndukId, cursor: cursor);
  }

  @override
  Future<void> submitManuver(Map<String, dynamic> data) {
    return _remoteDataSource.submitManuver(data);
  }

  @override
  Future<void> deleteManuver(int id) {
    return _remoteDataSource.deleteManuver(id);
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

  // IL1
  @override
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta'}) {
    return _remoteDataSource.getIl1KubikelInput(garduIndukId, timezone: timezone);
  }

  @override
  Future<void> submitIl1Kubikel({
    required Map<String, dynamic> data,
    required List<XFile> files,
  }) {
    return _remoteDataSource.submitIl1Kubikel(data: data, files: files);
  }

  @override
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta'}) {
    return _remoteDataSource.getIl1TrafoPsInput(garduIndukId, timezone: timezone);
  }

  @override
  Future<void> submitIl1TrafoPs({
    required Map<String, dynamic> data,
    required XFile file,
  }) {
    return _remoteDataSource.submitIl1TrafoPs(data: data, file: file);
  }

  @override
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta'}) {
    return _remoteDataSource.getIl1SipilInput(garduIndukId, timezone: timezone);
  }

  @override
  Future<void> submitIl1Sipil({
    required Map<String, dynamic> data,
    required XFile file,
  }) {
    return _remoteDataSource.submitIl1Sipil(data: data, file: file);
  }
}
