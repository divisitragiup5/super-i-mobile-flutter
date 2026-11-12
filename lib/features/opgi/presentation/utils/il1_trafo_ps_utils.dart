import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'il1_kubikel_utils.dart';

class Il1TrafoPsUtils {
  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  static bool validateIl1TrafoPs(Map<String, dynamic> data) {
    if (data.isEmpty) return false;

    const requiredFields = [
      'trafoId',
      'kebocoranBodyTrafo',
      'kondisiFisikTrafo',
      'kondisiRumahTrafo',
      'fotoBuktiInspeksi',
    ];

    for (final field in requiredFields) {
      if (_isEmpty(data[field])) return false;
    }

    final foto = data['fotoBuktiInspeksi'];
    if (foto is Map && _isEmpty(foto['uri'] ?? foto['path'])) {
      return false;
    }

    return true;
  }

  static ParsedIl1DraftResult parseIl1TrafoPsDrafts(
    List<Map<String, dynamic>> dataDraft,
    int idGi,
    List<dynamic> mappedData,
  ) {
    final existingKeySet = <String>{};

    for (final item in mappedData) {
      final il1List = item.il1TrafoPS as List?;
      if (il1List != null && il1List.isNotEmpty) {
        final key = '${item.nama}-${item.garduIndukNama ?? item.garduInduk?['nama']}';
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

      if (!validateIl1TrafoPs(data)) continue;

      if (existingKeySet.contains(namaDraft)) {
        duplicates.add(draftRowId);
        continue;
      }

      final cleanData = Map<String, dynamic>.from(data);
      cleanData['draftId'] = draftRowId;
      cleanData['durasi'] = double.tryParse(cleanData['durasi']?.toString() ?? '0') ?? 0.0;
      if (cleanData['trafoId'] != null) {
        cleanData['trafoId'] = int.tryParse(cleanData['trafoId'].toString()) ?? cleanData['trafoId'];
      }
      if (cleanData['kapasitasTrafo'] != null) {
        cleanData['kapasitasTrafo'] = double.tryParse(cleanData['kapasitasTrafo'].toString());
      }
      if (cleanData['tapTrafo'] != null) {
        cleanData['tapTrafo'] = int.tryParse(cleanData['tapTrafo'].toString());
      }

      parsed.add(cleanData);
    }

    return ParsedIl1DraftResult(parsed: parsed, duplicates: duplicates);
  }

  static Future<FormData> buildIl1TrafoPsFormData(
    Map<String, dynamic> data, {
    dynamic fotoBuktiInspeksi,
    String timezone = 'Asia/Jakarta',
  }) async {
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('startTime');
    cleanPayload.remove('draftId');
    cleanPayload.remove('garduIndukId');
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
