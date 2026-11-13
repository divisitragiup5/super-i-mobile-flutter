import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Item rincian pekerjaan pemeliharaan lapangan per rencana komponen
class RincianPemeliharaanItem {
  final int rencanaId;
  final String sub;
  final String komponen;
  final String? fasa;
  final String? nilaiAwal;
  final String status; // 'TERLAKSANA' | 'KENDALA'
  final int jumlah;
  final String? kendala;
  final String? kondisiSesudah;
  final File? fotoSebelum;
  final File? fotoProses;
  final File? fotoSesudah;
  final String? fotoTemuanAwalUrl;
  final String? keteranganAwal;

  const RincianPemeliharaanItem({
    required this.rencanaId,
    required this.sub,
    required this.komponen,
    this.fasa,
    this.nilaiAwal,
    this.status = 'TERLAKSANA',
    this.jumlah = 1,
    this.kendala,
    this.kondisiSesudah = 'Baik',
    this.fotoSebelum,
    this.fotoProses,
    this.fotoSesudah,
    this.fotoTemuanAwalUrl,
    this.keteranganAwal,
  });

  RincianPemeliharaanItem copyWith({
    int? rencanaId,
    String? sub,
    String? komponen,
    String? fasa,
    String? nilaiAwal,
    String? status,
    int? jumlah,
    String? kendala,
    String? kondisiSesudah,
    File? fotoSebelum,
    File? fotoProses,
    File? fotoSesudah,
    String? fotoTemuanAwalUrl,
    String? keteranganAwal,
  }) {
    return RincianPemeliharaanItem(
      rencanaId: rencanaId ?? this.rencanaId,
      sub: sub ?? this.sub,
      komponen: komponen ?? this.komponen,
      fasa: fasa ?? this.fasa,
      nilaiAwal: nilaiAwal ?? this.nilaiAwal,
      status: status ?? this.status,
      jumlah: jumlah ?? this.jumlah,
      kendala: kendala ?? this.kendala,
      kondisiSesudah: kondisiSesudah ?? this.kondisiSesudah,
      fotoSebelum: fotoSebelum ?? this.fotoSebelum,
      fotoProses: fotoProses ?? this.fotoProses,
      fotoSesudah: fotoSesudah ?? this.fotoSesudah,
      fotoTemuanAwalUrl: fotoTemuanAwalUrl ?? this.fotoTemuanAwalUrl,
      keteranganAwal: keteranganAwal ?? this.keteranganAwal,
    );
  }

  Map<String, dynamic> toJson() => {
        'rencanaId': rencanaId,
        'sub': sub,
        'komponen': komponen,
        'fasa': fasa,
        'nilaiAwal': nilaiAwal,
        'status': status,
        'jumlah': jumlah,
        'kendala': kendala,
        if (kondisiSesudah != null) 'kondisiSesudah': kondisiSesudah,
      };
}

class SutmPemeliharaanPayload {
  SutmPemeliharaanPayload._();

  static FormData buildFormData({
    required int workOrderId,
    required int workOrderSutmItemId,
    required int sutmId,
    required List<RincianPemeliharaanItem> rincianItems,
    String? globalKendala,
    File? globalFotoKendala,
  }) {
    final Map<String, dynamic> dataJson = {
      'workOrderId': workOrderId,
      'workOrderSutmItemId': workOrderSutmItemId,
      'sutmId': sutmId,
      'rincian': rincianItems.map((item) => item.toJson()).toList(),
      if (globalKendala != null && globalKendala.isNotEmpty)
        'kendala': globalKendala,
    };

    final formData = FormData();
    formData.fields.add(MapEntry('data', jsonEncode(dataJson)));

    // Lampirkan foto-foto rincian (before, process, after)
    for (int i = 0; i < rincianItems.length; i++) {
      final item = rincianItems[i];
      if (item.fotoSebelum != null && item.fotoSebelum!.existsSync()) {
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromFileSync(
              item.fotoSebelum!.path,
              filename: 'rincian_${item.rencanaId}_sebelum.jpg',
            ),
          ),
        );
      }
      if (item.fotoProses != null && item.fotoProses!.existsSync()) {
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromFileSync(
              item.fotoProses!.path,
              filename: 'rincian_${item.rencanaId}_proses.jpg',
            ),
          ),
        );
      }
      if (item.fotoSesudah != null && item.fotoSesudah!.existsSync()) {
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromFileSync(
              item.fotoSesudah!.path,
              filename: 'rincian_${item.rencanaId}_sesudah.jpg',
            ),
          ),
        );
      }
    }

    if (globalFotoKendala != null && globalFotoKendala.existsSync()) {
      formData.files.add(
        MapEntry(
          'files',
          MultipartFile.fromFileSync(
            globalFotoKendala.path,
            filename: 'kendala_pemeliharaan.jpg',
          ),
        ),
      );
    }

    return formData;
  }
}
