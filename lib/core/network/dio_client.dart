import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import '../errors/exceptions.dart';
import 'dio_cache_interceptor.dart';

import 'dart:async';

/// Client HTTP terpusat menggunakan Dio.
/// Otomatis menyematkan token Bearer dan memetakan error HTTP ke Exception aplikasi.
class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  // Callback opsional saat token kadaluarsa (HTTP 401)
  final VoidCallback? onUnauthorized;

  // 1. Variabel penampung antrian refresh token (Mutex Lock)
  Completer<String?>? _refreshTokenCompleter;

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
      headers: {'Accept': 'application/json'},
      responseType: ResponseType.json,
    );

    // 1. Interceptor Autentikasi (Sematkan Token, Handle 401 & Headers)
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

          // Atur Content-Type hanya jika ada body (dan bukan FormData)
          if (options.data != null && options.data is! FormData) {
            options.headers['Content-Type'] ??= 'application/json';
          } else if (options.data == null) {
            options.headers.remove('Content-Type');
            options.headers.remove('content-type');
            options.contentType = null;
          }

          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestPath = error.requestOptions.path;
          // Cek apakah 401 dan BUKAN request login/refresh itu sendiri
          final isAuthEndpoint =
              requestPath.contains('/auth/login') ||
              requestPath.contains('/auth/refresh');
          if (statusCode == 401 && !isAuthEndpoint) {
            try {
              // Panggil fungsi refresh yang aman dari balapan request paralel
              final newAccessToken = await _handleTokenRefresh();
              if (newAccessToken != null && newAccessToken.isNotEmpty) {
                // Update header Authorization request yang tadi gagal
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newAccessToken';
                // Retry request menggunakan Dio utama
                final retryResponse = await dio.fetch(opts);
                return handler.resolve(retryResponse);
              }
            } catch (_) {
              // Jika gagal, biarkan lanjut ke blok logout di bawah
            }
            // Jika refresh gagal atau tidak ada token, bersihkan sesi & redirect login
            await secureStorage.delete(key: StorageConstants.accessToken);
            await secureStorage.delete(key: StorageConstants.refreshToken);
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

  /// Fungsi terpusat untuk menukar refresh_token dengan aman (hanya 1 kali eksekusi)
  Future<String?> _handleTokenRefresh() async {
    // Jika sedang ada proses refresh yang berjalan, request lain CUKUP MENUNGGU proses yang sama
    if (_refreshTokenCompleter != null) {
      return _refreshTokenCompleter!.future;
    }
    _refreshTokenCompleter = Completer<String?>();
    try {
      final currentRefreshToken = await secureStorage.read(
        key: StorageConstants.refreshToken,
      );
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        _refreshTokenCompleter!.complete(null);
        return null;
      }
      // Buat instance Dio terpisah (tanpa interceptor auth)
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: ApiConstants.connectTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ),
      );
      // Tembak POST /auth/refresh sesuai dokumentasi Swagger Anda
      final response = await refreshDio.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': currentRefreshToken},
      );
      final data = response.data['data'];
      final newAccessToken = data?['access_token']?.toString();
      final newRefreshToken = data?['refresh_token']?.toString();
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        // Simpan access_token & refresh_token baru (karena token baru di-rotasi)
        await secureStorage.write(
          key: StorageConstants.accessToken,
          value: newAccessToken,
        );
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await secureStorage.write(
            key: StorageConstants.refreshToken,
            value: newRefreshToken,
          );
        }
        _refreshTokenCompleter!.complete(newAccessToken);
        return newAccessToken;
      } else {
        _refreshTokenCompleter!.complete(null);
        return null;
      }
    } catch (e) {
      _refreshTokenCompleter!.complete(null);
      return null;
    } finally {
      // Buka kembali kunci setelah selesai
      _refreshTokenCompleter = null;
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
      dio.options.headers.remove('Content-Type');
      dio.options.headers.remove('content-type');
      dio.options.contentType = null;
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
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
      final reqOptions = options ?? Options();
      if (data != null && data is! FormData) {
        reqOptions.contentType ??= 'application/json';
      }
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: reqOptions,
      );
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
      final reqOptions = options ?? Options();
      if (data != null && data is! FormData) {
        reqOptions.contentType ??= 'application/json';
      }
      return await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: reqOptions,
      );
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
      dio.options.headers.remove('Content-Type');
      dio.options.headers.remove('content-type');
      dio.options.contentType = null;

      final reqOptions = options ?? Options();
      if (data == null) {
        reqOptions.contentType = null;
        reqOptions.headers?.remove('Content-Type');
        reqOptions.headers?.remove('content-type');
      } else if (data is! FormData) {
        reqOptions.contentType ??= 'application/json';
      }
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: reqOptions,
      );
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
      final reqOptions = options ?? Options();
      if (data != null && data is! FormData) {
        reqOptions.contentType ??= 'application/json';
      }
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: reqOptions,
      );
    } on DioException catch (e) {
      throw handleError(e);
    }
  }
}
