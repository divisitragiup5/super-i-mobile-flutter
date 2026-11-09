import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../errors/exceptions.dart';
import 'dio_cache_interceptor.dart';

/// Client HTTP terpusat menggunakan Dio.
/// Otomatis menyematkan token Bearer dan memetakan error HTTP ke Exception aplikasi.
class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  // Callback opsional saat token kadaluarsa (HTTP 401)
  final VoidCallback? onUnauthorized;

  DioClient({
    required this.dio,
    required this.secureStorage,
    this.onUnauthorized,
  }) {
    _initDio();
  }

  void _initDio() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout: ApiConstants.sendTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
    );

    // 1. Interceptor Autentikasi (Sematkan Token & Handle 401)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari Keystore Android yang aman
          final token = await secureStorage.read(
            key: StorageConstants.accessToken,
          );
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Jika mendapat status 401 Unauthorized
          if (error.response?.statusCode == 401) {
            // Hapus token yang sudah hangus
            await secureStorage.delete(key: StorageConstants.accessToken);
            // Panggil callback agar aplikasi otomatis redirect ke login
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Interceptor Cache SQLite Lokal (Otomatis cache semua GET dengan default TTL 24 jam)
    dio.interceptors.add(DioCacheInterceptor());

    // 3. Interceptor Logging (Hanya aktif saat debugging di laptop)
    // kDebugMode di Flutter setara dengan __DEV__ di React Native
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (object) => debugPrint('[DIO] $object'),
        ),
      );
    }
  }

  /// Helper untuk menerjemahkan DioException menjadi Exception aplikasi kita.
  Exception handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        message: 'Koneksi ke server terputus. Pastikan internet Anda stabil.',
      );
    }

    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      return const UnauthorizedException();
    }

    // Ambil pesan error dari response backend jika ada
    final responseData = error.response?.data;
    String errorMessage = 'Terjadi kesalahan pada server.';

    if (responseData is Map<String, dynamic>) {
      final messageVal = responseData['message'];
      if (messageVal is String && messageVal.isNotEmpty) {
        errorMessage = messageVal;
      } else if (messageVal is List && messageVal.isNotEmpty) {
        errorMessage = messageVal.map((e) => e.toString()).join('\n');
      } else if (responseData['error'] is String) {
        errorMessage = responseData['error'] as String;
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      errorMessage = responseData;
    }

    return ServerException(message: errorMessage, statusCode: statusCode);
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
