import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

/// Item rincian pekerjaan pemeliharaan lapangan per rencana komponen
class RincianPemeliharaanItem {
  final int rencanaId;
  final String sub;
  final String komponen;
  final String? fasa;
  final String status; // 'TERLAKSANA' | 'KENDALA'
  final int jumlah;
  final String? kendala;
  final File? fotoSebelum;
  final File? fotoProses;
  final File? fotoSesudah;

  const RincianPemeliharaanItem({
    required this.rencanaId,
    required this.sub,
    required this.komponen,
    this.fasa,
    this.status = 'TERLAKSANA',
    this.jumlah = 1,
    this.kendala,
    this.fotoSebelum,
    this.fotoProses,
    this.fotoSesudah,
  });

  Map<String, dynamic> toJson() => {
        'rencanaId': rencanaId,
        'sub': sub,
        'komponen': komponen,
        'fasa': fasa,
        'status': status,
        'jumlah': jumlah,
        'kendala': kendala,
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
