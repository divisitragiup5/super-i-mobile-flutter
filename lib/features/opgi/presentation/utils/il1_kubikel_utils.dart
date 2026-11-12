import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ParsedIl1DraftResult {
  final List<Map<String, dynamic>> parsed;
  final List<int> duplicates;

  const ParsedIl1DraftResult({
    required this.parsed,
    required this.duplicates,
  });

  int get parsedLength => parsed.length;
}

class Il1KubikelUtils {
  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is String) return value.trim().isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return false;
  }

  static bool validateIl1Kubikel(Map<String, dynamic> data) {
    const requiredFields = [
      'statusPMT',
      'rackPMT',
      'keteranganPMT',
      'indikatorPegasMekanikPMT',
      'bendaAsing',
      'binatang',
      'tetesanAir',
      'desis',
      'bau',
      'kondisiLVPanel',
      'lampuLVPanel',
      'indikatorPMTClose',
      'indikatorPMTOpen',
      'indikatorTeganganKubikel',
      'tampilanLCDRelayOCR',
      'indikatorHealthyRelayOCR',
      'pembacaanArusNetralRelayOCR',
      'keteranganRelayUFR',
      'tampilanLCDKWHMeter',
      'tombolKWHMeter',
      'kondisiAlarm',
      'keteranganAnomali',
      'fotoBuktiInspeksi',
    ];

    for (final field in requiredFields) {
      if (_isEmpty(data[field])) return false;
    }

    // Photo check
    final fotoBukti = data['fotoBuktiInspeksi'];
    if (fotoBukti is Map && _isEmpty(fotoBukti['uri'] ?? fotoBukti['path'])) {
      return false;
    }

    // Relay UFR conditional
    if (data['keteranganRelayUFR'] == 'ADA') {
      if (_isEmpty(data['tampilanLCDRelayUFR']) ||
          _isEmpty(data['pembacaanTeganganRelayUFR']) ||
          _isEmpty(data['selectorUFR'])) {
        return false;
      }
    }

    // Anomali conditional
    if (data['keteranganAnomali'] == 'ADA') {
      if (_isEmpty(data['anomali'])) return false;
      final fotoAnomali = data['fotoAnomali'];
      if (fotoAnomali is! Map || _isEmpty(fotoAnomali['uri'] ?? fotoAnomali['path'])) {
        return false;
      }
    }

    return true;
  }

  static ParsedIl1DraftResult parseIl1KubikelDrafts(
    List<Map<String, dynamic>> dataDraft,
    int idGi,
    List<dynamic> mappedData,
  ) {
    final existingKeySet = <String>{};

    for (final item in mappedData) {
      final il1List = item.il1 as List?;
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

      if (!validateIl1Kubikel(data)) continue;

      if (existingKeySet.contains(namaDraft)) {
        duplicates.add(draftRowId);
        continue;
      }

      final cleanData = Map<String, dynamic>.from(data);
      cleanData['draftId'] = draftRowId;
      cleanData['durasi'] = double.tryParse(cleanData['durasi']?.toString() ?? '0') ?? 0.0;
      cleanData['pembacaanArusNetralRelayOCR'] =
          double.tryParse(cleanData['pembacaanArusNetralRelayOCR']?.toString() ?? '') ?? 0.0;
      if (cleanData['pembacaanTeganganRelayUFR'] != null) {
        cleanData['pembacaanTeganganRelayUFR'] =
            double.tryParse(cleanData['pembacaanTeganganRelayUFR'].toString());
      }
      if (cleanData['selectorUFR'] != null) {
        cleanData['selectorUFR'] = int.tryParse(cleanData['selectorUFR'].toString());
      }

      parsed.add(cleanData);
    }

    return ParsedIl1DraftResult(parsed: parsed, duplicates: duplicates);
  }

  static Future<FormData> buildIl1KubikelFormData(
    Map<String, dynamic> data, {
    dynamic fotoBuktiInspeksi,
    dynamic fotoAnomali,
    String timezone = 'Asia/Jakarta',
  }) async {
    final cleanPayload = Map<String, dynamic>.from(data);
    cleanPayload.remove('startTime');
    cleanPayload.remove('draftId');
    cleanPayload.remove('garduIndukId');
    cleanPayload.remove('fotoBuktiInspeksi');
    cleanPayload.remove('fotoAnomali');
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
        'files',
        await MultipartFile.fromFile(clean, filename: 'fotoBuktiInspeksi.jpg'),
      ));
    }

    final pathAnomali = extractPath(fotoAnomali ?? data['fotoAnomali']);
    if (pathAnomali != null && pathAnomali.isNotEmpty) {
      final clean = pathAnomali.startsWith('file://') ? pathAnomali.substring(7) : pathAnomali;
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(clean, filename: 'fotoAnomali.jpg'),
      ));
    }

    return formData;
  }
}
