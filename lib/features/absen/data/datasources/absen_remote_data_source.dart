import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/absen_info_model.dart';

abstract class AbsenRemoteDataSource {
  Future<AbsenInfoModel> getAbsensiInfo();

  Future<Map<String, dynamic>> submitAbsen({
    required String type,
    required File pictureFile,
    required double latitude,
    required double longitude,
    required int failedAttempt,
    required List<Map<String, dynamic>> faceProps,
    String? address,
    Map<String, dynamic>? extraData,
  });
}

class AbsenRemoteDataSourceImpl implements AbsenRemoteDataSource {
  final DioClient dioClient;

  AbsenRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<AbsenInfoModel> getAbsensiInfo() async {
    try {
      final response = await dioClient.dio.get(
        '/absensi/info',
        queryParameters: {'timezone': 'Asia/Jakarta'},
        options: Options(extra: {'no_cache': true}),
      );

      final data = response.data['data'] as Map<String, dynamic>;
      return AbsenInfoModel.fromJson(data);
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> submitAbsen({
    required String type,
    required File pictureFile,
    required double latitude,
    required double longitude,
    required int failedAttempt,
    required List<Map<String, dynamic>> faceProps,
    String? address,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      final payloadData = <String, dynamic>{
        'timezone': 'Asia/Jakarta',
        'type': type,
        'latitude': latitude,
        'longitude': longitude,
        'failedAttempt': failedAttempt,
        'face': faceProps,
        'picture': {
          'date': DateTime.now().toUtc().toIso8601String(),
          'latitude': latitude,
          'longitude': longitude,
          if (address != null && address.isNotEmpty) 'address': address,
        },
      };

      if (extraData != null) {
        const allowedExtraKeys = {
          'premi',
          'alasanPremiOff',
          'alasanPremiOn',
          'izin',
          'diagnosaSakit',
          'premiOnInfo',
          'shifts',
        };
        for (final entry in extraData.entries) {
          if (allowedExtraKeys.contains(entry.key)) {
            payloadData[entry.key] = entry.value;
          }
        }
      }

      final formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          pictureFile.path,
          filename: 'picture.jpg',
        ),
        'data': jsonEncode(payloadData),
      });

      final response = await dioClient.dio.post(
        '/absensi',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw dioClient.handleError(e);
    }
  }
}