import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/dio_client.dart';
import '../models/gardu_induk_model.dart';
import '../models/opgi_realisasi_model.dart';
import '../models/opgi_manuver_model.dart';
import '../models/opgi_anomali_model.dart';
import '../models/opgi_il1_model.dart';

abstract class OpgiRemoteDataSource {
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

class OpgiRemoteDataSourceImpl implements OpgiRemoteDataSource {
  final DioClient _client;

  OpgiRemoteDataSourceImpl(this._client);

  @override
  Future<List<GarduIndukModel>> getGarduIndukList({String timezone = 'Asia/Jakarta'}) async {
    final response = await _client.get(
      '/data/asset/opgi-20kv/unit-kerja/gi-20kv',
      queryParameters: {'timezone': timezone},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => GarduIndukModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Realisasi: Beban Trafo
  @override
  Future<List<BebanTrafoModel>> getBebanTrafoInput(int garduIndukId, String date) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/beban-trafo/input/$garduIndukId',
      queryParameters: {'date': date},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => BebanTrafoModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    await _client.post(
      '/gama/opgi-20kv/operator-gi/beban-trafo/input',
      data: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
        'data': items,
      },
    );
  }

  // Realisasi: Beban Penyulang
  @override
  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/input/$garduIndukId',
      queryParameters: {'date': date},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => BebanPenyulangModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitBebanPenyulang(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    await _client.post(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/input',
      data: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
        'data': items,
      },
    );
  }

  @override
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) async {
    await _client.patch(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/urutan/$garduIndukId',
      data: {'data': items},
    );
  }

  // Realisasi: KWH Harian
  @override
  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/kwh-harian/input/$garduIndukId',
      queryParameters: {'date': date},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => KwhHarianModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    await _client.post(
      '/gama/opgi-20kv/operator-gi/kwh-harian/input',
      data: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
        'data': items,
      },
    );
  }

  // Realisasi: Tegangan Trafo
  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/input/$garduIndukId',
      queryParameters: {'date': date},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => TeganganTrafoModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    await _client.post(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/input',
      data: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
        'data': items,
      },
    );
  }

  // Manuver
  @override
  Future<List<ManuverModel>> getManuverHistory(int garduIndukId, {int? cursor}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/manuver/history/$garduIndukId',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );
    final data = response.data['data'];
    final items = data is Map ? data['items'] as List? : data as List?;
    if (items == null) return [];
    return items.map((json) => ManuverModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitManuver(Map<String, dynamic> data) async {
    await _client.post(
      '/gama/opgi-20kv/operator-gi/manuver/input',
      data: data,
    );
  }

  @override
  Future<void> deleteManuver(int id) async {
    await _client.delete('/gama/opgi-20kv/operator-gi/manuver/$id');
  }

  // Anomali
  @override
  Future<List<AnomaliReportModel>> getAnomaliHistory(int garduIndukId, {int? cursor}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/anomali-report/history/$garduIndukId',
      queryParameters: cursor != null ? {'cursor': cursor} : null,
    );
    final data = response.data['data'];
    final items = data is Map ? data['items'] as List? : data as List?;
    if (items == null) return [];
    return items.map((json) => AnomaliReportModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getAnomaliAssets(int garduIndukId, String jenisAsset) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/anomali-report/asset/$garduIndukId',
      queryParameters: {'jenisAsset': jenisAsset},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> submitAnomali({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  }) async {
    final map = <String, dynamic>{
      'data': jsonEncode(data),
    };
    if (imageFile != null) {
      map['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: 'fotoBuktiAnomali.jpg',
      );
    }
    if (videoFile != null) {
      map['video'] = await MultipartFile.fromFile(
        videoFile.path,
        filename: 'buktiVideo.mp4',
      );
    }
    final formData = FormData.fromMap(map);
    await _client.post(
      '/gama/opgi-20kv/operator-gi/anomali-report/input',
      data: formData,
    );
  }

  @override
  Future<void> submitAnomaliKondisi({
    required Map<String, dynamic> data,
    XFile? imageFile,
    XFile? videoFile,
  }) async {
    final map = <String, dynamic>{
      'data': jsonEncode(data),
    };
    if (imageFile != null) {
      map['image'] = await MultipartFile.fromFile(
        imageFile.path,
        filename: 'fotoBuktiAnomaliKondisi.jpg',
      );
    }
    if (videoFile != null) {
      map['video'] = await MultipartFile.fromFile(
        videoFile.path,
        filename: 'buktiVideoKondisi.mp4',
      );
    }
    final formData = FormData.fromMap(map);
    await _client.post(
      '/gama/opgi-20kv/operator-gi/anomali-report/kondisi/input',
      data: formData,
    );
  }

  @override
  Future<void> deleteAnomali(int id) async {
    await _client.delete('/gama/opgi-20kv/operator-gi/anomali-report/$id');
  }

  @override
  Future<void> deleteAnomaliKondisi(int id) async {
    await _client.delete('/gama/opgi-20kv/operator-gi/anomali-report/kondisi/$id');
  }

  // IL1 Kubikel
  @override
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta'}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Il1KubikelItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitIl1Kubikel({
    required Map<String, dynamic> data,
    required List<XFile> files,
  }) async {
    final fileUploads = <MultipartFile>[];
    for (int i = 0; i < files.length; i++) {
      fileUploads.add(await MultipartFile.fromFile(
        files[i].path,
        filename: 'bukti_${i + 1}.jpg',
      ));
    }
    final formData = FormData.fromMap({
      'data': jsonEncode(data),
      'files': fileUploads,
    });
    await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/input',
      data: formData,
    );
  }

  // IL1 Trafo PS
  @override
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta'}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Il1TrafoPsItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitIl1TrafoPs({
    required Map<String, dynamic> data,
    required XFile file,
  }) async {
    final fileUpload = await MultipartFile.fromFile(
      file.path,
      filename: 'fotoBuktiInspeksi.jpg',
    );
    final formData = FormData.fromMap({
      'data': jsonEncode(data),
      'file': fileUpload,
    });
    await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/input',
      data: formData,
    );
  }

  // IL1 Sipil
  @override
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta'}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-sipil/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Il1SipilItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitIl1Sipil({
    required Map<String, dynamic> data,
    required XFile file,
  }) async {
    final fileUpload = await MultipartFile.fromFile(
      file.path,
      filename: 'fotoBuktiInspeksi.jpg',
    );
    final formData = FormData.fromMap({
      'data': jsonEncode(data),
      'file': fileUpload,
    });
    await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-sipil/input',
      data: formData,
    );
  }
}
