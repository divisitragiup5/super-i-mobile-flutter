import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/app_time_utils.dart';
import '../models/gardu_induk_model.dart';
import '../models/opgi_realisasi_model.dart';
import '../models/opgi_manuver_model.dart';
import '../models/opgi_anomali_model.dart';
import '../models/opgi_il1_model.dart';
import '../../presentation/utils/il1_kubikel_utils.dart';
import '../../presentation/utils/il1_trafo_ps_utils.dart';
import '../../presentation/utils/il1_sipil_utils.dart';

abstract class OpgiRemoteDataSource {
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
    return getBebanTrafoList(garduIndukId);
  }

  @override
  Future<List<BebanTrafoModel>> getBebanTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/beban-trafo/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => BebanTrafoModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitBebanTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    for (final item in items) {
      final file = item['file'] ?? item['foto']?['uri'];
      final data = Map<String, dynamic>.from(item)..remove('file');
      await submitBebanTrafoSingle(file: file, data: data);
    }
  }

  @override
  Future<List<BebanTrafoTodayItemModel>> getBebanTrafoToday(
    int trafoId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/beban-trafo/today/$trafoId',
      queryParameters: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
      },
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data
        .map((json) => BebanTrafoTodayItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> submitBebanTrafoSingle({
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    MultipartFile? multipartFile;
    String? filePath;
    if (file is File) {
      filePath = file.path;
    } else if (file is XFile) {
      filePath = file.path;
    } else if (file is String && file.isNotEmpty) {
      filePath = file;
    }

    if (filePath != null && filePath.isNotEmpty) {
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: 'fotoBebanTrafo.jpg',
      );
    }

    final formData = FormData.fromMap({
      'file': ?multipartFile,
      'data': jsonEncode(data),
    });

    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/beban-trafo/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> updateBebanTrafoMobile(
    int bebanId, {
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    MultipartFile? multipartFile;
    String? filePath;
    if (file is File) {
      filePath = file.path;
    } else if (file is XFile) {
      filePath = file.path;
    } else if (file is String && file.isNotEmpty) {
      filePath = file;
    }

    if (filePath != null && filePath.isNotEmpty) {
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: 'fotoBebanTrafo.jpg',
      );
    }

    final formData = FormData.fromMap({
      'file': ?multipartFile,
      'data': jsonEncode(data),
    });

    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/beban-trafo/input/$bebanId',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    final res = response.data;
    if (res is Map<String, dynamic>) {
      if (res['data'] is Map<String, dynamic>) {
        return res['data'] as Map<String, dynamic>;
      }
      return res;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> deleteBebanTrafo(int bebanId) async {
    final response = await _client.delete(
      '/gama/opgi-20kv/operator-gi/beban-trafo/$bebanId',
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  // Realisasi: Beban Penyulang
  @override
  Future<List<PenyulangModel>> getPenyulangList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => PenyulangModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BebanPenyulangModel>> getBebanPenyulangInput(int garduIndukId, String date, {bool forceRefresh = false}) async {
    return getPenyulangList(garduIndukId, forceRefresh: forceRefresh);
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
  Future<Map<String, dynamic>?> submitBebanPenyulangSingle({
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    MultipartFile? multipartFile;
    String? filePath;
    if (file is File) {
      filePath = file.path;
    } else if (file is XFile) {
      filePath = file.path;
    } else if (file is String && file.isNotEmpty) {
      filePath = file;
    }

    if (filePath != null && filePath.isNotEmpty) {
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: 'fotoBebanPenyulang.jpg',
      );
    }

    final formData = FormData.fromMap({
      'file': ?multipartFile,
      'data': jsonEncode(data),
    });

    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<List<BebanPenyulangTodayItemModel>> getBebanPenyulangToday(
    int penyulangId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/today/$penyulangId',
      queryParameters: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
      },
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data
        .map((json) => BebanPenyulangTodayItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> updateBebanPenyulangMobile(
    int bebanId, {
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    MultipartFile? multipartFile;
    String? filePath;
    if (file is File) {
      filePath = file.path;
    } else if (file is XFile) {
      filePath = file.path;
    } else if (file is String && file.isNotEmpty) {
      filePath = file;
    }

    if (filePath != null && filePath.isNotEmpty) {
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: 'fotoBebanPenyulang.jpg',
      );
    }

    final formData = FormData.fromMap({
      'file': ?multipartFile,
      'data': jsonEncode(data),
    });

    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/input/$bebanId',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> deleteBebanPenyulang(int bebanId) async {
    final response = await _client.delete(
      '/gama/opgi-20kv/operator-gi/beban-penyulang/$bebanId',
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<void> updateUrutanPenyulang(int garduIndukId, List<Map<String, dynamic>> items) async {
    await updateUrutanPenyulangCustom(items);
  }

  @override
  Future<void> updateUrutanPenyulangCustom(List<Map<String, dynamic>> items) async {
    await _client.patch(
      '/data/asset/opgi-20kv/penyulang/urutan-custom',
      data: {'data': items},
    );
  }

  // Realisasi: KWH Harian
  @override
  Future<List<KwhHarianModel>> getKwhHarianInput(int garduIndukId, String date) async {
    return getKwhHarianList(garduIndukId);
  }

  @override
  Future<List<KwhHarianModel>> getKwhHarianList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/kwh-harian/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => KwhHarianModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitKwhHarian(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    for (final item in items) {
      final files = (item['filesWithJenis'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final data = Map<String, dynamic>.from(item)..remove('filesWithJenis');
      await submitKwhHarianSingle(filesWithJenis: files, data: data);
    }
  }

  @override
  Future<List<KwhHarianTodayItemModel>> getKwhHarianToday(
    int objectId, {
    required String type,
    required String kelompok,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/kwh-harian/today/$objectId',
      queryParameters: {
        'type': type,
        'kelompok': kelompok,
        'timezone': timezone,
      },
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data
        .map((json) => KwhHarianTodayItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> submitKwhHarianSingle({
    required List<Map<String, dynamic>> filesWithJenis,
    required Map<String, dynamic> data,
  }) async {
    final formData = FormData();
    for (final item in filesWithJenis) {
      final file = item['file'];
      final jenis = item['jenis']?.toString() ?? 'foto';
      String? filePath;
      if (file is File) {
        filePath = file.path;
      } else if (file is XFile) {
        filePath = file.path;
      } else if (file is String && file.isNotEmpty) {
        filePath = file;
      }
      if (filePath != null && filePath.isNotEmpty) {
        if (filePath.startsWith('file://')) {
          filePath = filePath.replaceFirst('file://', '');
        }
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(filePath, filename: '$jenis.jpg'),
        ));
      }
    }
    formData.fields.add(MapEntry('data', jsonEncode(data)));

    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/kwh-harian/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    if (response.data is Map<String, dynamic>) {
      final resMap = response.data as Map<String, dynamic>;
      final dataField = resMap['data'];
      if (dataField is Map<String, dynamic>) {
        return dataField;
      } else if (dataField is List) {
        return {'data': dataField};
      }
      return resMap;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> updateKwhHarianMobile(
    int id, {
    required dynamic file,
    required Map<String, dynamic> data,
  }) async {
    MultipartFile? multipartFile;
    String? filePath;
    if (file is File) {
      filePath = file.path;
    } else if (file is XFile) {
      filePath = file.path;
    } else if (file is String && file.isNotEmpty) {
      filePath = file;
    }

    if (filePath != null && filePath.isNotEmpty) {
      if (filePath.startsWith('file://')) {
        filePath = filePath.replaceFirst('file://', '');
      }
      multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: 'fotoStand.jpg',
      );
    }

    final formData = FormData.fromMap({
      'file': ?multipartFile,
      'data': jsonEncode(data),
    });

    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/kwh-harian/input/$id',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
        return map['data'] as Map<String, dynamic>;
      }
      return map;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> deleteKwhHarianToday(List<int> ids) async {
    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/kwh-harian/delete-many',
      data: {'ids': ids},
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
        return map['data'] as Map<String, dynamic>;
      }
      return map;
    }
    return null;
  }

  // Realisasi: Tegangan Trafo
  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoInput(int garduIndukId, String date) async {
    return getTeganganTrafoList(garduIndukId);
  }

  @override
  Future<List<TeganganTrafoModel>> getTeganganTrafoList(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((json) => TeganganTrafoModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitTeganganTrafo(int garduIndukId, List<Map<String, dynamic>> items, String timezone) async {
    for (final item in items) {
      final fileMV = item['fileMV'];
      final fileHV = item['fileHV'];
      final data = Map<String, dynamic>.from(item)
        ..remove('fileMV')
        ..remove('fileHV');
      await submitTeganganTrafoSingle(fileMV: fileMV, fileHV: fileHV, data: data);
    }
  }

  @override
  Future<List<TeganganTrafoTodayItemModel>> getTeganganTrafoToday(
    int trafoId, {
    required int garduIndukId,
    String timezone = 'Asia/Jakarta',
    bool forceRefresh = false,
  }) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/today/$trafoId',
      queryParameters: {
        'garduIndukId': garduIndukId,
        'timezone': timezone,
      },
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data
        .map((json) => TeganganTrafoTodayItemModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, dynamic>?> submitTeganganTrafoSingle({
    required dynamic fileMV,
    required dynamic fileHV,
    required Map<String, dynamic> data,
  }) async {
    final formData = FormData();
    String? pathMV = fileMV is File
        ? fileMV.path
        : (fileMV is XFile ? fileMV.path : (fileMV is String ? fileMV : null));
    if (pathMV != null && pathMV.isNotEmpty) {
      if (pathMV.startsWith('file://')) pathMV = pathMV.replaceFirst('file://', '');
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(pathMV, filename: 'fotoMV.jpg'),
      ));
    }

    String? pathHV = fileHV is File
        ? fileHV.path
        : (fileHV is XFile ? fileHV.path : (fileHV is String ? fileHV : null));
    if (pathHV != null && pathHV.isNotEmpty) {
      if (pathHV.startsWith('file://')) pathHV = pathHV.replaceFirst('file://', '');
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(pathHV, filename: 'fotoHV.jpg'),
      ));
    }

    formData.fields.add(MapEntry('data', jsonEncode(data)));

    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> updateTeganganTrafoMobile(
    int teganganId, {
    dynamic fileMV,
    dynamic fileHV,
    required Map<String, dynamic> data,
  }) async {
    final formData = FormData();
    String? pathMV = fileMV is File
        ? fileMV.path
        : (fileMV is XFile ? fileMV.path : (fileMV is String ? fileMV : null));
    if (pathMV != null && pathMV.isNotEmpty) {
      if (pathMV.startsWith('file://')) pathMV = pathMV.replaceFirst('file://', '');
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(pathMV, filename: 'fotoMV.jpg'),
      ));
    }

    String? pathHV = fileHV is File
        ? fileHV.path
        : (fileHV is XFile ? fileHV.path : (fileHV is String ? fileHV : null));
    if (pathHV != null && pathHV.isNotEmpty) {
      if (pathHV.startsWith('file://')) pathHV = pathHV.replaceFirst('file://', '');
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(pathHV, filename: 'fotoHV.jpg'),
      ));
    }

    formData.fields.add(MapEntry('data', jsonEncode(data)));

    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/input/$teganganId',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    final res = response.data;
    if (res is Map<String, dynamic>) {
      if (res['data'] is Map<String, dynamic>) {
        return res['data'] as Map<String, dynamic>;
      }
      return res;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> deleteTeganganTrafo(int teganganId) async {
    final response = await _client.delete(
      '/gama/opgi-20kv/operator-gi/tegangan-trafo/$teganganId',
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  // Manuver
  @override
  Future<List<ManuverItemModel>> getManuverList(int garduIndukId, {String? timezone, bool forceRefresh = false}) async {
    final tz = timezone ?? AppTimeUtils.deviceTimezone;
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/manuver/input/$garduIndukId',
      queryParameters: {'timezone': tz},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => ManuverItemModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  @override
  Future<List<ManuverItemModel>> getManuverHistory(int garduIndukId, {int? cursor}) =>
      getManuverList(garduIndukId);

  @override
  Future<List<ManuverProgressModel>> getManuverProgress(int manuverId, {String? timezone, bool forceRefresh = false}) async {
    final tz = timezone ?? AppTimeUtils.deviceTimezone;
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/manuver/input/progres/$manuverId',
      queryParameters: {'timezone': tz},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((json) => ManuverProgressModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> submitManuver(Map<String, dynamic> data, [dynamic file]) async {
    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(data)));
    if (file != null) {
      String? filePath;
      if (file is File) {
        filePath = file.path;
      } else if (file is XFile) {
        filePath = file.path;
      } else if (file is String && file.isNotEmpty) {
        filePath = file;
      }
      if (filePath != null && filePath.isNotEmpty) {
        if (filePath.startsWith('file://')) {
          filePath = filePath.replaceFirst('file://', '');
        }
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(filePath, filename: 'fotoBuktiInspeksi.jpg'),
        ));
      }
    }

    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/manuver/input',
      data: formData,
    );
    return response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : {};
  }

  @override
  Future<Map<String, dynamic>> submitManuverProgress(Map<String, dynamic> data, [dynamic file]) async {
    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(data)));
    if (file != null) {
      String? filePath;
      if (file is File) {
        filePath = file.path;
      } else if (file is XFile) {
        filePath = file.path;
      } else if (file is String && file.isNotEmpty) {
        filePath = file;
      }
      if (filePath != null && filePath.isNotEmpty) {
        if (filePath.startsWith('file://')) {
          filePath = filePath.replaceFirst('file://', '');
        }
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(filePath, filename: 'fotoBuktiInspeksi.jpg'),
        ));
      }
    }

    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/manuver/input/progres',
      data: formData,
    );
    return response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : {};
  }

  @override
  Future<Map<String, dynamic>> updateManuverProgress(int id, Map<String, dynamic> data) async {
    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/manuver/input/progres/$id',
      data: data,
    );
    return response.data is Map<String, dynamic> ? response.data as Map<String, dynamic> : {};
  }

  @override
  Future<Map<String, dynamic>> deleteManuver(int id) async {
    final response = await _client.delete('/gama/opgi-20kv/operator-gi/manuver/input/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['success'] == false) {
        throw Exception(data['message']?.toString() ?? 'Gagal menghapus kegiatan manuver');
      }
      return data;
    }
    return {'success': true, 'message': 'Kegiatan manuver berhasil dihapus'};
  }

  @override
  Future<Map<String, dynamic>> deleteManuverProgress(int id) async {
    final response = await _client.delete('/gama/opgi-20kv/operator-gi/manuver/input/progres/$id');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      if (data['success'] == false) {
        throw Exception(data['message']?.toString() ?? 'Gagal menghapus progress manuver');
      }
      return data;
    }
    return {'success': true, 'message': 'Progress manuver berhasil dihapus'};
  }

  @override
  Future<List<Map<String, dynamic>>> getPenyulangByGi(int garduIndukId) async {
    final response = await _client.get('/data/asset/opgi-20kv/penyulang/gi/$garduIndukId');
    final data = response.data['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
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
  Future<List<Il1KubikelItem>> getIl1KubikelInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Il1KubikelItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<Il1KubikelTodayDetailModel?> getIl1KubikelToday(int penyulangId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/today/$penyulangId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'];
    if (data == null) return null;
    return Il1KubikelTodayDetailModel.fromJson(Map<String, dynamic>.from(data as Map));
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
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('garduIndukId');
    cleanPayload.remove('startTime');
    cleanPayload.remove('draftId');
    final formData = FormData.fromMap({
      'data': jsonEncode(cleanPayload),
      'files': fileUploads,
    });
    await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/input',
      data: formData,
    );
  }

  @override
  Future<Map<String, dynamic>?> submitIl1KubikelSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    dynamic fotoAnomali,
    String timezone = 'Asia/Jakarta',
  }) async {
    final formData = await Il1KubikelUtils.buildIl1KubikelFormData(
      data,
      fotoBuktiInspeksi: fotoBuktiInspeksi,
      fotoAnomali: fotoAnomali,
      timezone: timezone,
    );
    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> updateIl1Kubikel(int id, Map<String, dynamic> data, {dynamic fotoAnomali}) async {
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('id');
    cleanPayload.remove('garduIndukId');
    cleanPayload.remove('fotoAnomali');
    cleanPayload.remove('fotoAnomaliUri');

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(cleanPayload)));

    String? extractPath(dynamic photo) {
      if (photo == null) return null;
      if (photo is XFile) return photo.path;
      if (photo is Map) return photo['uri']?.toString() ?? photo['path']?.toString();
      if (photo is String) return photo;
      return null;
    }

    final pathAnomali = extractPath(fotoAnomali ?? data['fotoAnomali']);
    if (pathAnomali != null && pathAnomali.isNotEmpty) {
      final clean = pathAnomali.startsWith('file://') ? pathAnomali.substring(7) : pathAnomali;
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(clean, filename: 'fotoAnomali.jpg'),
      ));
    }

    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/input/$id',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1Kubikel(int id) async {
    final response = await _client.delete(
      '/gama/opgi-20kv/operator-gi/il1-kubikel/$id',
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<List<Map<String, dynamic>>> getTrafoList(int garduIndukId) async {
    final response = await _client.get('/data/asset/opgi-20kv/trafo/all/$garduIndukId');
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getRelList(int garduIndukId) async {
    final response = await _client.get('/data/asset/opgi-20kv/penyulang/rel/$garduIndukId');
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // IL1 Trafo PS
  @override
  Future<List<Il1TrafoPsItem>> getIl1TrafoPsInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Il1TrafoPsItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<Il1TrafoPsTodayDetailModel?> getIl1TrafoPsToday(int trafoId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/today/$trafoId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'];
    if (data == null) return null;
    return Il1TrafoPsTodayDetailModel.fromJson(Map<String, dynamic>.from(data as Map));
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

  @override
  Future<Map<String, dynamic>?> submitIl1TrafoPsSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  }) async {
    final formData = await Il1TrafoPsUtils.buildIl1TrafoPsFormData(
      data,
      fotoBuktiInspeksi: fotoBuktiInspeksi,
      timezone: timezone,
    );
    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> updateIl1TrafoPs(int id, Map<String, dynamic> data) async {
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('id');
    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/input/$id',
      data: cleanPayload,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1TrafoPs(int id) async {
    final response = await _client.delete(
      '/gama/opgi-20kv/operator-gi/il1-trafo-ps/$id',
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  // IL1 Sipil
  @override
  Future<List<Il1SipilItem>> getIl1SipilInput(int garduIndukId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-sipil/input/$garduIndukId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'] as List?;
    if (data == null) return [];
    return data.map((e) => Il1SipilItem.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  @override
  Future<Il1SipilTodayDetailModel?> getIl1SipilToday(int sipilId, {String timezone = 'Asia/Jakarta', bool forceRefresh = false}) async {
    final response = await _client.get(
      '/gama/opgi-20kv/operator-gi/il1-sipil/today/$sipilId',
      queryParameters: {'timezone': timezone},
      options: forceRefresh ? Options(extra: {'force_refresh': true}) : null,
    );
    final data = response.data['data'];
    if (data == null) return null;
    return Il1SipilTodayDetailModel.fromJson(Map<String, dynamic>.from(data as Map));
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

  @override
  Future<Map<String, dynamic>?> submitIl1SipilSingle({
    required Map<String, dynamic> data,
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  }) async {
    final formData = await Il1SipilUtils.buildIl1SipilFormData(
      data,
      fotoBuktiInspeksi: fotoBuktiInspeksi,
      timezone: timezone,
    );
    final response = await _client.post(
      '/gama/opgi-20kv/operator-gi/il1-sipil/input',
      data: formData,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> updateIl1Sipil(int id, Map<String, dynamic> data) async {
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('id');
    final response = await _client.patch(
      '/gama/opgi-20kv/operator-gi/il1-sipil/input/$id',
      data: cleanPayload,
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }

  @override
  Future<Map<String, dynamic>?> deleteIl1Sipil(int id) async {
    final response = await _client.delete(
      '/gama/opgi-20kv/operator-gi/il1-sipil/$id',
      options: Options(extra: {'skip_cache_invalidation': true}),
    );
    return response.data['data'] as Map<String, dynamic>?;
  }
}
