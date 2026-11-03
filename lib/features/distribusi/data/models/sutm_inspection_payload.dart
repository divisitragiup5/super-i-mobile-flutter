import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Builder dan serializer untuk payload formulir inspeksi SUTM
class SutmInspectionPayload {
  SutmInspectionPayload._();

  static FormData buildFormData({
    required Map<String, dynamic> formValues,
    required int? workOrderSutmItemId,
    int? sutmId,
    required double latitude,
    required double longitude,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, File?>? fileAttachments,
  }) {
    // 1. Ekstrak data JSON terstruktur
    final Map<String, dynamic> dataJson = {
      if (workOrderSutmItemId != null && workOrderSutmItemId > 0)
        'workOrderSUTMItemId': workOrderSutmItemId,
      if (sutmId != null && sutmId > 0) 'sutmId': sutmId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };

    // Sub 1: Tiang
    if (formValues['1_jenis_tiang'] != null) {
      dataJson['jenisTiang'] = formValues['1_jenis_tiang'];
    }
    if (formValues['1_tinggi_tiang'] != null) {
      dataJson['tinggiTiang'] = formValues['1_tinggi_tiang'];
    }
    if (formValues['1_kondisi_tiang'] != null) {
      final rawKondisi = formValues['1_kondisi_tiang'];
      List<String> listKondisi = [];
      if (rawKondisi is List) {
        listKondisi = rawKondisi.map((e) => e.toString()).toList();
      } else if (rawKondisi is String) {
        listKondisi = rawKondisi.split(',').map((s) => s.trim()).toList();
      }
      dataJson['kondisiTiang'] = {'kondisi': listKondisi};
    }
    if (formValues['1_identitas_tiang'] != null) {
      dataJson['identitasTiang'] = formValues['1_identitas_tiang'];
    }
    if (formValues['1_jenis_konstruksi'] != null) {
      dataJson['jenisKonstruksi'] = {
        'jenis': formValues['1_jenis_konstruksi'],
      };
    }

    // Sub 2: Penghantar (Konduktor, Sambungan, Terminasi)
    if (formValues['2_jenis_konduktor'] != null) {
      dataJson['jenisKonduktor'] = formValues['2_jenis_konduktor'];
    }
    if (formValues['2_ukuran_konduktor'] != null) {
      dataJson['ukuranKonduktor'] = formValues['2_ukuran_konduktor'];
    }

    final konduktorList = ['R', 'S', 'T'].map((fasa) {
      final key = '2_konduktor_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Baik',
      };
    }).toList();
    dataJson['konduktor'] = konduktorList;

    final sambunganList = ['R', 'S', 'T'].map((fasa) {
      final key = '2_sambungan_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Tidak Ada',
      };
    }).toList();
    dataJson['sambungan'] = sambunganList;

    final terminasiList = ['R', 'S', 'T'].map((fasa) {
      final key = '2_terminasi_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Tidak Ada',
      };
    }).toList();
    dataJson['terminasi'] = terminasiList;

    // Sub 3: Isolator
    final isolatorTumpuList = ['R', 'S', 'T'].map((fasa) {
      final key = '3_isolator_tumpu_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Baik',
      };
    }).toList();
    dataJson['isolatorTumpu'] = isolatorTumpuList;

    final jenisIsolatorList = ['R', 'S', 'T'].map((fasa) {
      final key = '3_jenis_isolator_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'jenis': formValues[key] ?? 'Pin Post',
      };
    }).toList();
    dataJson['jenisIsolator'] = jenisIsolatorList;

    final topTiesList = ['R', 'S', 'T'].map((fasa) {
      final key = '3_top_ties_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Baik',
      };
    }).toList();
    dataJson['topTies'] = topTiesList;

    if (formValues['3_cross_arm'] != null) {
      dataJson['crossArm'] = {'kondisi': formValues['3_cross_arm']};
    }

    // Sub 4: Proteksi & Pembumian
    if (formValues['4_gsw_letak'] != null) {
      dataJson['gswLetak'] = formValues['4_gsw_letak'];
    }
    if (formValues['4_grounding'] != null) {
      dataJson['grounding'] = {'kondisi': formValues['4_grounding']};
    }
    if (formValues['4_kawat_pembumian'] != null) {
      dataJson['kawatPembumian'] = {'kondisi': formValues['4_kawat_pembumian']};
    }

    final arresterList = ['R', 'S', 'T'].map((fasa) {
      final jenisKey = '4_arrester_jenis_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'jenis': formValues[jenisKey] ?? 'Polymer',
      };
    }).toList();
    dataJson['arrester'] = arresterList;

    final kondisiArresterList = ['R', 'S', 'T'].map((fasa) {
      final kondisiKey = '4_arrester_kondisi_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[kondisiKey] ?? 'Baik',
      };
    }).toList();
    dataJson['kondisiArrester'] = kondisiArresterList;

    // Sub 5: Konstruksi Penopang
    if (formValues['5_penopang_jenis'] != null ||
        formValues['5_penopang_kondisi'] != null) {
      dataJson['konstruksiPenopang'] = {
        'jenis': formValues['5_penopang_jenis'] ?? 'Tidak Ada',
        'kondisi': formValues['5_penopang_kondisi'] ?? 'Baik',
      };
    }

    // Sub 6: Peralatan Hubung (FCO, LBS, Recloser)
    final fcoList = ['R', 'S', 'T'].map((fasa) {
      final key = '6_fco_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Baik',
      };
    }).toList();
    dataJson['fco'] = fcoList;

    if (formValues['6_lbs'] != null) {
      dataJson['lbsKonvensional'] = {'kondisi': formValues['6_lbs']};
    }
    if (formValues['6_recloser'] != null) {
      dataJson['recloser'] = {'kondisi': formValues['6_recloser']};
    }

    // Sub 7: ROW & Lingkungan
    if (formValues['7_row_list'] is List) {
      dataJson['row'] = formValues['7_row_list'];
    }

    // Kendala
    if (formValues['pelaksanaan'] == 'KENDALA' || formValues['kendala'] != null) {
      dataJson['pelaksanaan'] = formValues['pelaksanaan'] ?? 'TERLAKSANA';
      dataJson['kendala'] = formValues['kendala'];
    }

    // 2. Susun Multipart Form Data
    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataJson)));

    if (fileAttachments != null) {
      fileAttachments.forEach((key, file) {
        if (file != null && file.existsSync()) {
          final fileName = '${key}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          formData.files.add(
            MapEntry(
              'files',
              MultipartFile.fromFileSync(
                file.path,
                filename: fileName,
              ),
            ),
          );
        }
      });
    }

    return formData;
  }
}
