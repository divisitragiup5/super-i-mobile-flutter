import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Builder dan serializer untuk payload formulir inspeksi SUTM
/// Menghasilkan format JSON dan Multipart Files yang 100% identik dengan super-i-mobile
class SutmInspectionPayload {
  SutmInspectionPayload._();

  static double? _toNumber(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    return double.tryParse(str);
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    final str = val.toString().trim();
    if (str.isEmpty) return null;
    return int.tryParse(str);
  }

  static List<Map<String, dynamic>>? _buildThermalRows({
    required Map<String, dynamic> formValues,
    required String minFieldKey,
    required String maxFieldPrefix,
  }) {
    final min = _toNumber(formValues[minFieldKey]);
    final List<Map<String, dynamic>> rows = [];
    for (final fasa in ['R', 'S', 'T']) {
      final maxVal = _toNumber(formValues['${maxFieldPrefix}_${fasa.toLowerCase()}_max']);
      if (maxVal != null) {
        rows.add({
          'fasa': fasa,
          'thermal': {
            'min': min ?? 0,
            'max': maxVal,
          },
        });
      }
    }
    return rows.isNotEmpty ? rows : null;
  }

  static List<Map<String, dynamic>>? _buildPdRows({
    required Map<String, dynamic> formValues,
    required String fieldPrefix,
  }) {
    final List<Map<String, dynamic>> rows = [];
    for (final fasa in ['R', 'S', 'T']) {
      final pdVal = formValues['${fieldPrefix}_${fasa.toLowerCase()}']?.toString();
      if (pdVal != null && pdVal.isNotEmpty) {
        rows.add({
          'fasa': fasa,
          'partialDischarge': pdVal,
        });
      }
    }
    return rows.isNotEmpty ? rows : null;
  }

  static Map<String, dynamic> buildJsonPayload({
    required Map<String, dynamic> formValues,
    required int? workOrderSutmItemId,
    int? sutmId,
    required double latitude,
    required double longitude,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    final jenisKonstruksi = formValues['1_jenis_konstruksi']?.toString() ?? 'TM 1';
    final useTm13 = jenisKonstruksi == 'TM 1' || jenisKonstruksi == 'TM 3';

    final gswVal = formValues['4_gsw']?.toString() ?? 'Tidak Ada';
    final hasArrester = formValues['4_has_arrester'] == 'Ada';
    final showPembumianGrounding = gswVal != 'Tidak Ada' || hasArrester;

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
    dataJson['jenisTiang'] = formValues['1_jenis_tiang'];
    dataJson['tinggiTiang'] = formValues['1_tinggi_tiang'];

    // kondisiTiang: array of strings
    final rawKondisi = formValues['1_kondisi_tiang'];
    List<String> listKondisi = [];
    if (rawKondisi is List) {
      listKondisi = rawKondisi.map((e) => e.toString().trim()).toList();
    } else if (rawKondisi is String && rawKondisi.isNotEmpty) {
      listKondisi = rawKondisi.split(',').map((s) => s.trim()).toList();
    }
    if (listKondisi.any((item) => item.toLowerCase() == 'baik')) {
      listKondisi = ['Baik'];
    }
    dataJson['kondisiTiang'] = {'kondisi': listKondisi};

    dataJson['identitasTiang'] = formValues['1_identitas_tiang'];
    dataJson['jenisKonstruksi'] = {'jenis': jenisKonstruksi};

    // Sub 2: Penghantar
    dataJson['jenisKonduktor'] = formValues['2_jenis_konduktor'];
    dataJson['ukuranKonduktor'] = formValues['2_ukuran_konduktor'];

    dataJson['konduktor'] = ['R', 'S', 'T'].map((fasa) {
      final key = '2_konduktor_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Baik',
      };
    }).toList();

    dataJson['sambungan'] = ['R', 'S', 'T'].map((fasa) {
      final key = '2_sambungan_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Tidak Ada',
      };
    }).toList();

    final thermalSambungan = _buildThermalRows(
      formValues: formValues,
      minFieldKey: '2_thermal_sambungan_min',
      maxFieldPrefix: '2_thermal_sambungan_fasa',
    );
    if (thermalSambungan != null) {
      dataJson['thermalSambungan'] = thermalSambungan;
    }

    final pdSambungan = _buildPdRows(
      formValues: formValues,
      fieldPrefix: '2_pd_sambungan_fasa',
    );
    if (pdSambungan != null) {
      dataJson['partialDischargeSambungan'] = pdSambungan;
    }

    dataJson['terminasi'] = ['R', 'S', 'T'].map((fasa) {
      final key = '2_terminasi_fasa_${fasa.toLowerCase()}';
      return {
        'fasa': fasa,
        'kondisi': formValues[key] ?? 'Tidak Ada',
      };
    }).toList();

    final thermalTerminasi = _buildThermalRows(
      formValues: formValues,
      minFieldKey: '2_thermal_terminasi_min',
      maxFieldPrefix: '2_thermal_terminasi_fasa',
    );
    if (thermalTerminasi != null) {
      dataJson['thermalTerminasi'] = thermalTerminasi;
    }

    final pdTerminasi = _buildPdRows(
      formValues: formValues,
      fieldPrefix: '2_pd_terminasi_fasa',
    );
    if (pdTerminasi != null) {
      dataJson['partialDischargeTerminasi'] = pdTerminasi;
    }

    // Sub 3: Isolator
    final isolatorSuffix = useTm13 ? 'tm_1_3' : 'tm_5';

    dataJson['isolatorTumpu'] = ['R', 'S', 'T'].map((fasa) {
      final fasaKey = fasa.toLowerCase();
      final key = '3_isolator_tumpu_${isolatorSuffix}_fasa_$fasaKey';
      final kondisiVal = formValues[key] ?? 'Baik';
      final jumlahTemuanKey = '3_isolator_tumpu_${isolatorSuffix}_fasa_${fasaKey}_jumlah_temuan';
      final jumlahTemuan = _toInt(formValues[jumlahTemuanKey]);

      final Map<String, dynamic> row = {
        'fasa': fasa,
        'kondisi': kondisiVal,
      };
      if (jenisKonstruksi != 'TM 1' && jumlahTemuan != null) {
        row['jumlahTemuan'] = jumlahTemuan;
      }
      return row;
    }).toList();

    final pdIsolatorTumpu = _buildPdRows(
      formValues: formValues,
      fieldPrefix: useTm13 ? '3_pd_isolator_tumpu_tm_1_3_fasa' : '3_pd_isolator_tumpu_tm_5_fasa',
    );
    if (pdIsolatorTumpu != null) {
      dataJson['partialDischargeIsolatorTumpu'] = pdIsolatorTumpu;
    }

    dataJson['jenisIsolator'] = ['R', 'S', 'T'].map((fasa) {
      return {
        'fasa': fasa,
        'jenis': formValues['3_jenis_isolator_$isolatorSuffix'] ?? 'Pin Post',
      };
    }).toList();

    dataJson['topTies'] = ['R', 'S', 'T'].map((fasa) {
      final fasaKey = fasa.toLowerCase();
      final key = '3_top_ties_${isolatorSuffix}_fasa_$fasaKey';
      final kondisiVal = formValues[key] ?? 'Baik';
      final jumlahTemuanKey = '3_top_ties_${isolatorSuffix}_fasa_${fasaKey}_jumlah_temuan';
      final jumlahTemuan = _toInt(formValues[jumlahTemuanKey]);

      final Map<String, dynamic> row = {
        'fasa': fasa,
        'kondisi': kondisiVal,
      };
      if (kondisiVal != 'Baik' && jumlahTemuan != null) {
        row['jumlahTemuan'] = jumlahTemuan;
      }
      return row;
    }).toList();

    final crossArmKondisi = formValues['3_cross_arm_$isolatorSuffix'];
    if (crossArmKondisi != null) {
      dataJson['crossArm'] = {'kondisi': crossArmKondisi};
    }

    if (useTm13) {
      final armTieKondisi = formValues['3_arm_tie_tm_1_3'];
      if (armTieKondisi != null) {
        dataJson['armTie'] = {'kondisi': armTieKondisi};
      }
    } else {
      // Isolator Tarik
      dataJson['isolatorTarik'] = ['R', 'S', 'T'].map((fasa) {
        final key = '3_isolator_tarik_tm_5_fasa_${fasa.toLowerCase()}';
        return {
          'fasa': fasa,
          'kondisi': formValues[key] ?? 'Baik',
        };
      }).toList();

      final pdIsolatorTarik = _buildPdRows(
        formValues: formValues,
        fieldPrefix: '3_pd_isolator_tarik_tm_5_fasa',
      );
      if (pdIsolatorTarik != null) {
        dataJson['partialDischargeIsolatorTarik'] = pdIsolatorTarik;
      }

      // Sambungan Jumper
      dataJson['sambunganJumper'] = ['R', 'S', 'T'].map((fasa) {
        final key = '3_sambungan_jumper_tm_5_fasa_${fasa.toLowerCase()}';
        return {
          'fasa': fasa,
          'jenis': formValues[key] ?? 'Tidak Ada',
        };
      }).toList();

      final thermalJumper = _buildThermalRows(
        formValues: formValues,
        minFieldKey: '3_thermal_sambungan_jumper_min',
        maxFieldPrefix: '3_thermal_sambungan_jumper_tm_5_fasa',
      );
      if (thermalJumper != null) {
        dataJson['thermalSambunganJumper'] = thermalJumper;
      }

      final pdJumper = _buildPdRows(
        formValues: formValues,
        fieldPrefix: '3_pd_sambungan_jumper_tm_5_fasa',
      );
      if (pdJumper != null) {
        dataJson['partialDischargeSambunganJumper'] = pdJumper;
      }
    }

    // Sub 4: Proteksi & Pembumian
    dataJson['gswLetak'] = gswVal;
    if (gswVal != 'Tidak Ada' && formValues['4_kondisi_gsw'] != null) {
      dataJson['gswKondisi'] = formValues['4_kondisi_gsw'];
    }

    dataJson['arrester'] = ['R', 'S', 'T'].map((fasa) {
      final fasaKey = fasa.toLowerCase();
      return {
        'fasa': fasa,
        'jenis': hasArrester ? (formValues['4_jenis_arrester_fasa_$fasaKey'] ?? 'Tidak Ada') : 'Tidak Ada',
      };
    }).toList();

    if (hasArrester) {
      final List<Map<String, dynamic>> kondisiArresterList = [];
      for (final fasa in ['R', 'S', 'T']) {
        final fasaKey = fasa.toLowerCase();
        final jenisVal = formValues['4_jenis_arrester_fasa_$fasaKey'];
        if (jenisVal != null && jenisVal != 'Tidak Ada') {
          kondisiArresterList.add({
            'fasa': fasa,
            'kondisi': formValues['4_kondisi_arrester_fasa_$fasaKey'] ?? 'Baik',
          });
        }
      }
      if (kondisiArresterList.isNotEmpty) {
        dataJson['kondisiArrester'] = kondisiArresterList;
      }

      final thermalArrester = _buildThermalRows(
        formValues: formValues,
        minFieldKey: '4_thermal_arrester_min',
        maxFieldPrefix: '4_thermal_arrester_fasa',
      );
      if (thermalArrester != null) {
        dataJson['thermalArrester'] = thermalArrester;
      }

      final pdArrester = _buildPdRows(
        formValues: formValues,
        fieldPrefix: '4_pd_arrester_fasa',
      );
      if (pdArrester != null) {
        dataJson['partialDischargeArrester'] = pdArrester;
      }

      if (formValues['4_jumper_arrester'] != null && formValues['4_jumper_arrester'] != 'Tidak Ada') {
        dataJson['jumperArrester'] = {'kondisi': formValues['4_jumper_arrester']};
      }
    }

    if (showPembumianGrounding) {
      if (formValues['4_kawat_pembumian'] != null) {
        dataJson['kawatPembumian'] = {'kondisi': formValues['4_kawat_pembumian']};
      }
      final ukurKawat = _toNumber(formValues['4_hasil_ukur_kawat_pembumian']);
      if (ukurKawat != null) {
        dataJson['ukurKawatPembumian'] = ukurKawat;
      }

      if (formValues['4_grounding'] != null) {
        dataJson['grounding'] = {'kondisi': formValues['4_grounding']};
      }
      final ukurGrounding = _toNumber(formValues['4_hasil_ukur_grounding']);
      if (ukurGrounding != null) {
        dataJson['ukurGrounding'] = ukurGrounding;
      }
    }

    // Sub 5: Konstruksi Penopang
    final penopangJenis = formValues['5_penopang_jenis']?.toString() ?? 'Tidak Ada';
    if (penopangJenis == 'Tidak Ada') {
      dataJson['konstruksiPenopang'] = {'jenis': 'Tidak Ada', 'kondisi': 'Tidak Ada'};
    } else {
      dataJson['konstruksiPenopang'] = {
        'jenis': penopangJenis,
        'kondisi': formValues['5_penopang_kondisi'] ?? 'Baik',
      };
      if (formValues['5_kondisi_steel_wire'] != null) {
        dataJson['kondisiSteelWire'] = {'kondisi': formValues['5_kondisi_steel_wire']};
      }
      if (formValues['5_pondasi'] != null) {
        dataJson['pondasi'] = {'kondisi': formValues['5_pondasi']};
      }
    }

    // Sub 6: Peralatan Hubung
    dataJson['fco'] = ['R', 'S', 'T'].map((fasa) {
      final fasaKey = fasa.toLowerCase();
      return {
        'fasa': fasa,
        'kondisi': formValues['6_fco_fasa_$fasaKey'] ?? 'Tidak Ada',
      };
    }).toList();

    final thermalFco = _buildThermalRows(
      formValues: formValues,
      minFieldKey: '6_thermal_fco_min',
      maxFieldPrefix: '6_thermal_fco_fasa',
    );
    if (thermalFco != null) {
      dataJson['thermalFco'] = thermalFco;
    }

    final pdFco = _buildPdRows(
      formValues: formValues,
      fieldPrefix: '6_pd_fco_fasa',
    );
    if (pdFco != null) {
      dataJson['partialDischargeFco'] = pdFco;
    }

    if (formValues['6_sambungan_fco'] != null && formValues['6_sambungan_fco'] != 'Tidak Ada') {
      dataJson['sambunganFCO'] = {'jenis': formValues['6_sambungan_fco']};
    }
    if (formValues['6_lbs_konvensional'] != null && formValues['6_lbs_konvensional'] != 'Tidak Ada') {
      dataJson['lbsKonvensional'] = {'kondisi': formValues['6_lbs_konvensional']};
    }
    if (formValues['6_lbs_remote_motorized'] != null && formValues['6_lbs_remote_motorized'] != 'Tidak Ada') {
      dataJson['lbsRemote'] = {'kondisi': formValues['6_lbs_remote_motorized']};
    }
    if (formValues['6_recloser'] != null && formValues['6_recloser'] != 'Tidak Ada') {
      dataJson['recloser'] = {'kondisi': formValues['6_recloser']};
    }

    // Sub 7: ROW
    final rawRows = formValues['7_rows'];
    if (rawRows is List && rawRows.isNotEmpty) {
      dataJson['row'] = rawRows.map((r) {
        final rowMap = r is Map ? r : <String, dynamic>{};
        return {
          'idEntitas': rowMap['idEntitas'],
          'jenisEntitas': rowMap['jenisEntitas'],
          'jarak': rowMap['jarak'],
          'fasa': rowMap['fasa'],
          'latitude': _toNumber(rowMap['latitude']) ?? latitude,
          'longitude': _toNumber(rowMap['longitude']) ?? longitude,
        };
      }).toList();
    }

    // Pelaksanaan / Kendala
    if (formValues['pelaksanaan'] == 'KENDALA' || formValues['kendala'] != null) {
      dataJson['pelaksanaan'] = 'KENDALA';
      dataJson['kendala'] = formValues['kendala'];
    } else {
      dataJson['pelaksanaan'] = 'TERLAKSANA';
    }

    return dataJson;
  }

  static FormData buildFormData({
    required Map<String, dynamic> formValues,
    required int? workOrderSutmItemId,
    int? sutmId,
    required double latitude,
    required double longitude,
    required DateTime startTime,
    required DateTime endTime,
    Map<String, dynamic>? fileAttachments,
  }) {
    final dataJson = buildJsonPayload(
      formValues: formValues,
      workOrderSutmItemId: workOrderSutmItemId,
      sutmId: sutmId,
      latitude: latitude,
      longitude: longitude,
      startTime: startTime,
      endTime: endTime,
    );

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataJson)));

    if (fileAttachments != null) {
      fileAttachments.forEach((key, val) {
        if (val is File && val.existsSync()) {
          final fileName = '$key.jpg';
          formData.files.add(
            MapEntry(
              'files',
              MultipartFile.fromFileSync(
                val.path,
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
