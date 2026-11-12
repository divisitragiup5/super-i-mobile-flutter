import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'il1_kubikel_utils.dart';

class Il1SipilUtils {
  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  static bool validateIl1Sipil(Map<String, dynamic> data) {
    if (data.isEmpty) return false;

    const requiredFields = [
      'fotoBuktiInspeksi',
      'kondisiLampuPenerangan',
      'jenisLampuPenerangan',
      'jumlahLampuPenerangan',
      'jumlahLampuPeneranganMati',
      'keteranganLampuPenerangan',
      'kondisiRuangan',
      'jumlahACMenyalaNormal',
      'jumlahACWindOnly',
      'jumlahACBocor',
      'keteranganAc',
      'kondisiAtap',
      'mainholeTergenangAir',
      'powerSupplyAC',
      'kebersihanPanelDCBC',
      'kebersihanRuangBaterai',
      'suhuRuangBaterai',
      'kelembabanRuangBaterai',
      'kebersihanBaterai',
      'kebocoranBaterai',
      'exhaustFan',
      'kondisiRuangBaterai',
      'teganganBeban',
      'arusBeban',
      'kondisiRectifier',
      'kebersihanRuangRectifier',
      'suhuRuangRectifier',
      'kelembabanRuangRectifier',
      'kebersihanPanel',
      'kondisiMMI',
      'kondisiMouseKomputer',
      'kondisiKeyboardKomputer',
      'kondisiInternet',
      'kondisiRadio',
      'kondisiYealink',
    ];

    for (final field in requiredFields) {
      if (_isEmpty(data[field])) return false;
    }

    final foto = data['fotoBuktiInspeksi'];
    if (foto is Map && _isEmpty(foto['uri'] ?? foto['path'])) {
      return false;
    }

    if (data['kondisiAtap'] == 'BOCOR' && _isEmpty(data['letakKebocoranAtap'])) {
      return false;
    }

    return true;
  }

  static ParsedIl1DraftResult parseIl1SipilDrafts(
    List<Map<String, dynamic>> dataDraft,
    int idGi,
    List<dynamic> mappedData,
  ) {
    final existingKeySet = <String>{};

    for (final item in mappedData) {
      final il1List = item.il1Sipil as List?;
      if (il1List != null && il1List.isNotEmpty) {
        final key = '${item.gedung}-${item.nama}';
        existingKeySet.add(key);
      }
    }

    final parsed = <Map<String, dynamic>>[];
    final duplicates = <int>[];

    for (final draft in dataDraft) {
      final draftRowId = draft['id'] as int? ?? 0;
      final namaDraft = draft['nama'] as String? ?? '';
      final rawData = draft['data'];
      final Map<String, dynamic> data = rawData is Map<String, dynamic>
          ? rawData
          : (rawData is String ? jsonDecode(rawData) : <String, dynamic>{});

      final draftGiId = int.tryParse(data['garduIndukId']?.toString() ?? '') ?? 0;
      if (draftGiId != idGi) continue;

      if (!validateIl1Sipil(data)) continue;

      if (existingKeySet.contains(namaDraft)) {
        duplicates.add(draftRowId);
        continue;
      }

      final cleanData = Map<String, dynamic>.from(data);
      cleanData['draftId'] = draftRowId;
      cleanData['durasi'] = double.tryParse(cleanData['durasi']?.toString() ?? '0') ?? 0.0;
      cleanData['jumlahLampuPenerangan'] =
          int.tryParse(cleanData['jumlahLampuPenerangan']?.toString() ?? '0') ?? 0;
      cleanData['jumlahLampuPeneranganMati'] =
          int.tryParse(cleanData['jumlahLampuPeneranganMati']?.toString() ?? '0') ?? 0;
      cleanData['jumlahACMenyalaNormal'] =
          int.tryParse(cleanData['jumlahACMenyalaNormal']?.toString() ?? '0') ?? 0;
      cleanData['jumlahACWindOnly'] =
          int.tryParse(cleanData['jumlahACWindOnly']?.toString() ?? '0') ?? 0;
      cleanData['jumlahACBocor'] =
          int.tryParse(cleanData['jumlahACBocor']?.toString() ?? '0') ?? 0;
      cleanData['suhuRuangBaterai'] =
          double.tryParse(cleanData['suhuRuangBaterai']?.toString() ?? '0') ?? 0.0;
      cleanData['kelembabanRuangBaterai'] =
          double.tryParse(cleanData['kelembabanRuangBaterai']?.toString() ?? '0') ?? 0.0;
      cleanData['suhuRuangRectifier'] =
          double.tryParse(cleanData['suhuRuangRectifier']?.toString() ?? '0') ?? 0.0;
      cleanData['kelembabanRuangRectifier'] =
          double.tryParse(cleanData['kelembabanRuangRectifier']?.toString() ?? '0') ?? 0.0;
      cleanData['teganganBeban'] =
          double.tryParse(cleanData['teganganBeban']?.toString() ?? '0') ?? 0.0;
      cleanData['arusBeban'] =
          double.tryParse(cleanData['arusBeban']?.toString() ?? '0') ?? 0.0;

      parsed.add(cleanData);
    }

    return ParsedIl1DraftResult(parsed: parsed, duplicates: duplicates);
  }

  static Future<FormData> buildIl1SipilFormData(
    Map<String, dynamic> data, {
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  }) async {
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('startTime');
    cleanPayload.remove('draftId');
    cleanPayload.remove('fotoBuktiInspeksi');
    cleanPayload['timezone'] = timezone;

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(cleanPayload)));

    String? extractPath(dynamic photo) {
      if (photo == null) return null;
      if (photo is XFile) return photo.path;
      if (photo is Map) return photo['uri']?.toString() ?? photo['path']?.toString();
      if (photo is String) return photo;
      return null;
    }

    final pathBukti = extractPath(fotoBuktiInspeksi ?? data['fotoBuktiInspeksi']);
    if (pathBukti != null && pathBukti.isNotEmpty) {
      final clean = pathBukti.startsWith('file://') ? pathBukti.substring(7) : pathBukti;
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(clean, filename: 'fotoBuktiInspeksi.jpg'),
      ));
    }

    return formData;
  }
}
