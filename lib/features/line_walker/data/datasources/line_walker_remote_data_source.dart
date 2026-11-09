import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/download_ba_helper.dart';
import '../models/kegiatan_sosial_model.dart';
import '../models/ketenagakerjaan_model.dart';
import '../models/line_walker_performance_model.dart';
import '../models/pembumian_model.dart';
import '../models/ppl_model.dart';
import '../models/tower_asset_model.dart';
import '../models/waterpass_model.dart';
import 'package:super_i_mobile/features/home/data/models/ppl_condition_summary_model.dart';

abstract class LineWalkerRemoteDataSource {
  Future<LineWalkerPerformanceModel?> getMyPerformance({
    int? minggu,
    String? bulan,
    int? tahun,
  });

  Future<List<TowerAssetModel>> getTowers({String type = 'GANTRY,TOWER'});
  
  // Waterpass
  Future<String> submitWaterpass(WaterpassInputModel input);
  Future<WaterpassDetailModel?> getLastWaterpass(int towerId);

  // Pembumian
  Future<String> submitPembumian(PembumianInputModel input);
  Future<Map<String, dynamic>?> getLastPembumian(int towerId);
  Future<List<PembumianHistoryItemModel>> getPembumianHistory({int cursor = 0, String? search});
  Future<String> downloadBAPembumian({required int towerId, required int inspectionId, required String towerName});

  // PPL
  Future<String> submitPpl(PPLInputModel input);
  Future<String> updatePpl({required int id, File? ttdTLGI, String? namaTTDTLGI});
  Future<Map<String, dynamic>?> getLastPpl(int towerId);
  Future<List<PPLHistoryItemModel>> getPplHistory({int cursor = 0, String? search, String? type});
  Future<List<PPLHistoryItemModel>> getPplHistoryByIdentifier(String identifier, {int cursor = 0});
  Future<Map<String, dynamic>> getSummaryRiwayatPpl();
  Future<PplConditionSummaryModel> getPplConditionSummary();
  Future<String> downloadBAPPL({required int inspectionId, required String towerName});

  // Ketenagakerjaan
  Future<List<KetenagakerjaanItemModel>> getSummaryKetenagakerjaan({int cursor = 0, String? search});
  Future<List<KetenagakerjaanItemModel>> getKetenagakerjaanDetail(int id, {int cursor = 0, String? timezone});
  Future<String> downloadSuratKetenagakerjaan({
    required int id,
    required int minggu,
    required String bulan,
    required int tahun,
    required String status,
  });

  // Kegiatan Sosial
  Future<String> submitKegiatanSosial(KegiatanSosialInputModel input);
  Future<String> updateKegiatanSosial({
    required int id,
    File? ttdTLGI,
    String? namaTTDTLGI,
    File? ttdLineWalker,
    String? namaTTDLineWalker,
  });
  Future<Map<String, dynamic>?> getLastKegiatanSosial(int towerId);
  Future<List<KegiatanSosialHistoryItemModel>> getKegiatanSosialHistory({int cursor = 0, String? search});
  Future<List<KegiatanSosialHistoryItemModel>> getKegiatanSosialHistoryByIdentifier(String identifier, {int cursor = 0});
  Future<String> downloadBAKegiatanSosial({required int inspectionId, required String towerName});
}

class LineWalkerRemoteDataSourceImpl implements LineWalkerRemoteDataSource {
  final DioClient _dioClient;

  LineWalkerRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<TowerAssetModel>> getTowers({String type = 'GANTRY,TOWER'}) async {
    final response = await _dioClient.dio.get(
      '/data/asset/tower/line-walker',
      queryParameters: {'type': type},
    );
    final list = response.data['data'] as List? ?? [];
    return list.map((e) => TowerAssetModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Waterpass ---
  @override
  Future<String> submitWaterpass(WaterpassInputModel input) async {
    final Map<String, dynamic> dataMap = {
      'towerId': input.towerId,
      'timezone': 'Asia/Jakarta',
    };
    if (input.hasilX != null) dataMap['waterpassX'] = {'hasil': input.hasilX};
    if (input.hasilY != null) dataMap['waterpassY'] = {'hasil': input.hasilY};
    if (input.hasilZ != null) dataMap['waterpassZ'] = {'hasil': input.hasilZ};

    final List<MapEntry<String, MultipartFile>> fileEntries = [];

    Future<void> addFile(String key, File? file) async {
      if (file != null && await file.exists()) {
        final ext = file.path.endsWith('.png') ? 'png' : 'jpg';
        fileEntries.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: '$key.$ext'),
        ));
      }
    }

    await addFile('fotoTowerSebelumInspeksi', input.fotoSebelum);
    await addFile('fotoTowerSetelahInspeksi', input.fotoSetelah);
    await addFile('waterpassX', input.fotoX);
    await addFile('waterpassY', input.fotoY);
    await addFile('waterpassZ', input.fotoZ);

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataMap)));
    formData.files.addAll(fileEntries);

    final response = await _dioClient.dio.post(
      '/gama/line-walker/waterpass',
      data: formData,
    );
    return response.data['message']?.toString() ?? 'Waterpass berhasil disimpan';
  }

  @override
  Future<WaterpassDetailModel?> getLastWaterpass(int towerId) async {
    try {
      final response = await _dioClient.dio.get(
        '/gama/line-walker/waterpass/last-inspection',
        queryParameters: {'towerId': towerId},
      );
      if (response.data['data'] != null) {
        return WaterpassDetailModel.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // --- Pembumian ---
  @override
  Future<String> submitPembumian(PembumianInputModel input) async {
    final Map<String, dynamic> dataMap = {
      'towerId': input.towerId,
      'kendala': input.kendala,
      'timezone': 'Asia/Jakarta',
    };

    final List<MapEntry<String, MultipartFile>> fileEntries = [];

    Future<void> addFile(String filename, File? file) async {
      if (file != null && await file.exists()) {
        final ext = file.path.endsWith('.png') ? 'png' : 'jpg';
        fileEntries.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: '$filename.$ext'),
        ));
      }
    }

    await addFile('fotoTowerSebelumInspeksi', input.fotoSebelum);
    await addFile('fotoTowerSetelahInspeksi', input.fotoSetelah);

    void processLeg(String legKey, LegInputModel? leg) {
      if (leg != null) {
        dataMap[legKey] = {
          if (leg.hasil != null) 'hasil': leg.hasil,
          if (leg.status != null) 'status': leg.status,
        };
      }
    }

    processLeg('legA', input.legA);
    processLeg('legB', input.legB);
    processLeg('legC', input.legC);
    processLeg('legD', input.legD);
    processLeg('IGSW', input.igsw);
    processLeg('groundingLangsung', input.groundingLangsung);
    processLeg('bersama', input.bersama);
    processLeg('MDG', input.mdg);

    if (input.legA != null) {
      await addFile('legA', input.legA!.pict);
      await addFile('statusLegA', input.legA!.statusPict);
    }
    if (input.legB != null) {
      await addFile('legB', input.legB!.pict);
      await addFile('statusLegB', input.legB!.statusPict);
    }
    if (input.legC != null) {
      await addFile('legC', input.legC!.pict);
      await addFile('statusLegC', input.legC!.statusPict);
    }
    if (input.legD != null) {
      await addFile('legD', input.legD!.pict);
      await addFile('statusLegD', input.legD!.statusPict);
    }
    if (input.igsw != null) {
      await addFile('IGSW', input.igsw!.pict);
      await addFile('statusIGSW', input.igsw!.statusPict);
    }
    if (input.groundingLangsung != null) {
      await addFile('groundingLangsung', input.groundingLangsung!.pict);
      await addFile('statusGroundingLangsung', input.groundingLangsung!.statusPict);
    }
    if (input.bersama != null) {
      await addFile('bersama', input.bersama!.pict);
      await addFile('statusBersama', input.bersama!.statusPict);
    }
    if (input.mdg != null) {
      await addFile('MDG', input.mdg!.pict);
      await addFile('statusMDG', input.mdg!.statusPict);
    }

    if (input.catatanAnomali != null && input.catatanAnomali!.isNotEmpty) {
      dataMap['anomali'] = {'catatan': input.catatanAnomali};
      await addFile('anomali', input.fotoAnomali);
    }

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataMap)));
    formData.files.addAll(fileEntries);

    final response = await _dioClient.dio.post(
      '/gama/line-walker/pembumian',
      data: formData,
    );
    return response.data['message']?.toString() ?? 'Pembumian berhasil disimpan';
  }

  @override
  Future<Map<String, dynamic>?> getLastPembumian(int towerId) async {
    try {
      final response = await _dioClient.dio.get(
        '/gama/line-walker/pembumian/last-inspection',
        queryParameters: {'towerId': towerId},
      );
      return response.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PembumianHistoryItemModel>> getPembumianHistory({int cursor = 0, String? search}) async {
    final Map<String, dynamic> query = {'cursor': cursor};
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _dioClient.dio.get(
      '/gama/line-walker/pembumian/history',
      queryParameters: query,
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => PembumianHistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- PPL ---
  @override
  Future<String> submitPpl(PPLInputModel input) async {
    final Map<String, dynamic> dataMap = {
      'towerId': input.towerId,
      'identifier': input.identifier,
      'namaPekerjaan': input.namaPekerjaan,
      'jenisObjek': input.jenisObjek,
      'keteranganJenisObjek': input.keteranganJenisObjek,
      'kategoriObjek': input.kategoriObjek,
      'keteranganKategoriObjek': input.keteranganKategoriObjek,
      'statusObjek': input.statusObjek,
      'statusPekerjaan': input.statusPekerjaan,
      'progressPekerjaan': input.progressPekerjaan,
      'pihakPelaksana': input.pihakPelaksana,
      'pjPekerjaan': input.pjPekerjaan,
      'noTeleponPJPekerjaan': input.noTeleponPJPekerjaan,
      'tanggapan': input.tanggapan,
      'namaValidator': input.namaValidator,
      'suratSosialisasi': input.suratSosialisasi.toIso8601String(),
      'lokasi': input.lokasi,
      'koordinat': {
        'latitude': input.latitude,
        'longitude': input.longitude,
      },
      'namaTTDLineWalker': input.namaTTDLineWalker,
      'namaTTDPJPekerjaan': input.namaTTDPJPekerjaan,
      if (input.namaTTDTLGI != null) 'namaTTDTLGI': input.namaTTDTLGI,
      'timezone': 'Asia/Jakarta',
    };

    final List<MapEntry<String, MultipartFile>> fileEntries = [];

    Future<void> addFile(String key, File? file) async {
      if (file != null && await file.exists()) {
        final ext = file.path.endsWith('.png') ? 'png' : 'jpg';
        fileEntries.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: '$key.$ext'),
        ));
      }
    }

    await addFile('dokumentasiPerwakilan', input.dokumentasiPerwakilan);
    await addFile('dokumentasiObjek', input.dokumentasiObjek);
    await addFile('dokumentasiSekitar', input.dokumentasiSekitar);
    await addFile('ttdLineWalker', input.ttdLineWalker);
    await addFile('ttdPJPekerjaan', input.ttdPJPekerjaan);
    await addFile('ttdTLGI', input.ttdTLGI);

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataMap)));
    formData.files.addAll(fileEntries);

    final response = await _dioClient.dio.post(
      '/gama/line-walker/ppl',
      data: formData,
    );
    return response.data['message']?.toString() ?? 'PPL berhasil disimpan';
  }

  @override
  Future<String> updatePpl({required int id, File? ttdTLGI, String? namaTTDTLGI}) async {
    final Map<String, dynamic> dataMap = {
      'id': id,
      'namaTTDTLGI': ?namaTTDTLGI,
    };

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataMap)));

    if (ttdTLGI != null && await ttdTLGI.exists()) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(ttdTLGI.path, filename: 'ttdTLGI.png'),
      ));
    }

    final response = await _dioClient.dio.patch(
      '/gama/line-walker/ppl/history/$id',
      data: formData,
    );
    return response.data['message']?.toString() ?? 'PPL berhasil diperbarui';
  }

  @override
  Future<Map<String, dynamic>?> getLastPpl(int towerId) async {
    try {
      final response = await _dioClient.dio.get(
        '/gama/line-walker/ppl/last-inspection',
        queryParameters: {'towerId': towerId},
      );
      return response.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<PPLHistoryItemModel>> getPplHistory({int cursor = 0, String? search, String? type}) async {
    final Map<String, dynamic> query = {'cursor': cursor};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (type != null && type.isNotEmpty && type != 'all') query['type'] = type;

    final response = await _dioClient.dio.get(
      '/gama/line-walker/ppl/history',
      queryParameters: query,
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => PPLHistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PPLHistoryItemModel>> getPplHistoryByIdentifier(String identifier, {int cursor = 0}) async {
    final response = await _dioClient.dio.get(
      '/gama/line-walker/ppl/history/$identifier',
      queryParameters: {'cursor': cursor},
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => PPLHistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Map<String, dynamic>> getSummaryRiwayatPpl() async {
    final response = await _dioClient.dio.get('/gama/line-walker/ppl/summary-ppl-history');
    return response.data['data'] as Map<String, dynamic>? ?? {};
  }

  @override
  Future<PplConditionSummaryModel> getPplConditionSummary() async {
    final response = await _dioClient.dio.get('/gama/line-walker/ppl/condition-summary');
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return PplConditionSummaryModel.fromJson(data);
  }

  // --- Ketenagakerjaan ---
  @override
  Future<List<KetenagakerjaanItemModel>> getSummaryKetenagakerjaan({int cursor = 0, String? search}) async {
    final Map<String, dynamic> query = {'cursor': cursor};
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _dioClient.dio.get(
      '/gama/line-walker/arsakha/summary-performance',
      queryParameters: query,
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => KetenagakerjaanItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<KetenagakerjaanItemModel>> getKetenagakerjaanDetail(int id, {int cursor = 0, String? timezone}) async {
    final response = await _dioClient.dio.get(
      '/gama/line-walker/arsakha/summary-performance/$id',
      queryParameters: {
        'cursor': cursor,
        'timezone': timezone ?? 'Asia/Jakarta',
      },
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => KetenagakerjaanItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // --- Kegiatan Sosial ---
  @override
  Future<String> submitKegiatanSosial(KegiatanSosialInputModel input) async {
    final Map<String, dynamic> dataMap = {
      'towerId': input.towerId,
      'identifier': input.identifier,
      'jenisAktivitas': input.jenisAktivitas,
      'statusAktivitas': input.statusAktivitas,
      'progresPenanganan': input.progresPenanganan,
      'tindakan': input.tindakan,
      'keterangan': input.keterangan,
      'statusObjek': input.statusObjek,
      'pelakuAktivitasSosial': input.pelakuAktivitasSosial,
      'tanggapan': input.tanggapan,
      'lokasi': input.lokasi,
      'koordinat': {
        'latitude': input.latitude,
        'longitude': input.longitude,
      },
      'namaTTDLineWalker': input.namaTTDLineWalker,
      if (input.namaTTDTLGI != null) 'namaTTDTLGI': input.namaTTDTLGI,
      'temuan': input.temuan,
      if (input.jumlahTemuan != null) 'jumlahTemuan': input.jumlahTemuan,
      'timezone': 'Asia/Jakarta',
    };

    final List<MapEntry<String, MultipartFile>> fileEntries = [];

    Future<void> addFile(String key, File? file) async {
      if (file != null && await file.exists()) {
        final ext = file.path.endsWith('.png') ? 'png' : 'jpg';
        fileEntries.add(MapEntry(
          'files',
          await MultipartFile.fromFile(file.path, filename: '$key.$ext'),
        ));
      }
    }

    await addFile('dokumentasiSosialisasi', input.dokumentasiSosialisasi);
    await addFile('dokumentasiAktivitasSosial', input.dokumentasiAktivitasSosial);
    await addFile('ttdLineWalker', input.ttdLineWalker);
    await addFile('ttdTLGI', input.ttdTLGI);

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataMap)));
    formData.files.addAll(fileEntries);

    final response = await _dioClient.dio.post(
      '/gama/line-walker/kegiatan-sosial',
      data: formData,
    );
    return response.data['message']?.toString() ?? 'Kegiatan Sosial berhasil disimpan';
  }

  @override
  Future<String> updateKegiatanSosial({
    required int id,
    File? ttdTLGI,
    String? namaTTDTLGI,
    File? ttdLineWalker,
    String? namaTTDLineWalker,
  }) async {
    final Map<String, dynamic> dataMap = {
      'id': id,
      'namaTTDTLGI': ?namaTTDTLGI,
      'namaTTDLineWalker': ?namaTTDLineWalker,
    };

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataMap)));

    if (ttdTLGI != null && await ttdTLGI.exists()) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(ttdTLGI.path, filename: 'ttdTLGI.png'),
      ));
    }
    if (ttdLineWalker != null && await ttdLineWalker.exists()) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(ttdLineWalker.path, filename: 'ttdLineWalker.png'),
      ));
    }

    final response = await _dioClient.dio.patch(
      '/gama/line-walker/kegiatan-sosial/history/$id',
      data: formData,
    );
    return response.data['message']?.toString() ?? 'Kegiatan Sosial berhasil diperbarui';
  }

  @override
  Future<Map<String, dynamic>?> getLastKegiatanSosial(int towerId) async {
    try {
      final response = await _dioClient.dio.get(
        '/gama/line-walker/kegiatan-sosial/last-inspection',
        queryParameters: {'towerId': towerId},
      );
      return response.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<KegiatanSosialHistoryItemModel>> getKegiatanSosialHistory({int cursor = 0, String? search}) async {
    final Map<String, dynamic> query = {'cursor': cursor};
    if (search != null && search.isNotEmpty) query['search'] = search;

    final response = await _dioClient.dio.get(
      '/gama/line-walker/kegiatan-sosial/history',
      queryParameters: query,
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => KegiatanSosialHistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<KegiatanSosialHistoryItemModel>> getKegiatanSosialHistoryByIdentifier(String identifier, {int cursor = 0}) async {
    final response = await _dioClient.dio.get(
      '/gama/line-walker/kegiatan-sosial/history/$identifier',
      queryParameters: {'cursor': cursor},
    );
    final items = response.data['data']?['items'] as List? ?? [];
    return items.map((e) => KegiatanSosialHistoryItemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<LineWalkerPerformanceModel?> getMyPerformance({
    int? minggu,
    String? bulan,
    int? tahun,
  }) async {
    final Map<String, dynamic> query = {};
    if (minggu != null) query['minggu'] = minggu;
    if (bulan != null && bulan.isNotEmpty) query['bulan'] = bulan;
    if (tahun != null) query['tahun'] = tahun;

    final response = await _dioClient.dio.get(
      '/gama/line-walker/arsakha/my-performance',
      queryParameters: query.isNotEmpty ? query : null,
    );

    dynamic raw = response.data;
    if (raw is String) {
      if (raw.trim().isEmpty) return null;
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return null;
      }
    }

    if (raw == null || raw is! Map) return null;
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw);

    // Jika response kosong atau data['data'] null
    if (map['data'] == null && map['score'] == null) {
      return null;
    }

    return LineWalkerPerformanceModel.fromJson(map);
  }

  @override
  Future<String> downloadBAPembumian({
    required int towerId,
    required int inspectionId,
    required String towerName,
  }) async {
    final response = await _dioClient.dio.post(
      '/gama/line-walker/pembumian/rekap',
      data: {
        'ids': [
          [towerId, inspectionId]
        ],
        'type': 'executive-summary',
        'timezone': 'Asia/Jakarta',
      },
      options: Options(responseType: ResponseType.bytes),
    );
    final contentType = response.headers.value('content-type');
    final filePath = await DownloadBaHelper.saveFile(
      bytes: response.data as List<int>,
      rawFileName: towerName,
      contentType: contentType,
    );
    return filePath;
  }

  @override
  Future<String> downloadBAPPL({
    required int inspectionId,
    required String towerName,
  }) async {
    final response = await _dioClient.dio.post(
      '/gama/line-walker/ppl/rekap',
      data: {
        'ids': [inspectionId],
        'type': 'ba',
        'timezone': 'Asia/Jakarta',
      },
      options: Options(responseType: ResponseType.bytes),
    );
    final contentType = response.headers.value('content-type');
    final filePath = await DownloadBaHelper.saveFile(
      bytes: response.data as List<int>,
      rawFileName: '$towerName.pdf',
      contentType: contentType,
    );
    return filePath;
  }

  @override
  Future<String> downloadBAKegiatanSosial({
    required int inspectionId,
    required String towerName,
  }) async {
    final response = await _dioClient.dio.post(
      '/gama/line-walker/kegiatan-sosial/rekap',
      data: {
        'ids': [inspectionId],
        'type': 'ba',
        'timezone': 'Asia/Jakarta',
      },
      options: Options(responseType: ResponseType.bytes),
    );
    final contentType = response.headers.value('content-type');
    final filePath = await DownloadBaHelper.saveFile(
      bytes: response.data as List<int>,
      rawFileName: towerName,
      contentType: contentType,
    );
    return filePath;
  }

  @override
  Future<String> downloadSuratKetenagakerjaan({
    required int id,
    required int minggu,
    required String bulan,
    required int tahun,
    required String status,
  }) async {
    final response = await _dioClient.dio.post(
      '/gama/line-walker/arsakha/print-surat',
      data: {
        'id': id,
        'minggu': minggu,
        'bulan': bulan,
        'tahun': tahun,
        'status': status,
      },
      options: Options(responseType: ResponseType.bytes),
    );
    final contentType = response.headers.value('content-type');
    final filePath = await DownloadBaHelper.saveFile(
      bytes: response.data as List<int>,
      rawFileName: status,
      contentType: contentType,
    );
    return filePath;
  }
}

