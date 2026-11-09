import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/local_database.dart';

/// Interceptor Dio untuk menyimpan dan menyajikan respon GET dari cache SQLite lokal.
/// Memiliki perilaku offline-first dengan default TTL 24 jam (menyesuaikan TanStack Query di super-i-mobile).
class DioCacheInterceptor extends Interceptor {
  final LocalDatabase localDatabase;
  final Duration defaultTtl;

  DioCacheInterceptor({
    LocalDatabase? localDatabase,
    this.defaultTtl = const Duration(hours: 24),
  }) : localDatabase = localDatabase ?? LocalDatabase.instance;

  String _generateCacheKey(RequestOptions options) {
    final buffer = StringBuffer(options.path);
    if (options.queryParameters.isNotEmpty) {
      final sortedKeys = options.queryParameters.keys.toList()..sort();
      final queryPairs = sortedKeys.map((k) {
        final val = options.queryParameters[k];
        return '$k=$val';
      }).join('&');
      buffer.write('?$queryPairs');
    }
    return buffer.toString();
  }

  int _getTtlSeconds(RequestOptions options) {
    final customTtl = options.extra['cache_ttl'];
    if (customTtl is Duration) {
      return customTtl.inSeconds;
    } else if (customTtl is int) {
      return customTtl;
    }
    return defaultTtl.inSeconds;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Hanya tangani request berjenis GET
    if (options.method.toUpperCase() != 'GET') {
      return handler.next(options);
    }

    final noCache = options.extra['no_cache'] == true ||
        options.headers['cache-control'] == 'no-cache';
    final forceRefresh = options.extra['force_refresh'] == true;

    if (noCache || forceRefresh) {
      return handler.next(options);
    }

    final cacheKey = _generateCacheKey(options);

    try {
      final cachedJson = await localDatabase.getApiCache(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final decodedData = jsonDecode(cachedJson);
        if (kDebugMode) {
          debugPrint('[DIO CACHE HIT] $cacheKey');
        }
        return handler.resolve(
          Response(
            requestOptions: options,
            data: decodedData,
            statusCode: 200,
            extra: {
              ...options.extra,
              'from_cache': true,
              'is_stale': false,
            },
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DIO CACHE ERROR] Gagal membaca cache: $e');
      }
    }

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    final method = response.requestOptions.method.toUpperCase();

    // 1. Simpan respon GET sukses ke dalam cache
    if (method == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final noCache = response.requestOptions.extra['no_cache'] == true;
      if (!noCache && response.data != null) {
        final cacheKey = _generateCacheKey(response.requestOptions);
        final ttlSeconds = _getTtlSeconds(response.requestOptions);

        try {
          final jsonString = jsonEncode(response.data);
          await localDatabase.saveApiCache(
            cacheKey,
            jsonString,
            ttlSeconds: ttlSeconds,
          );
          if (kDebugMode) {
            debugPrint('[DIO CACHE SAVED] $cacheKey (TTL: ${ttlSeconds}s)');
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[DIO CACHE ERROR] Gagal menyimpan cache: $e');
          }
        }
      }
    }

    // 2. Jika mutasi berhasil (POST, PUT, PATCH, DELETE), invalidate cache terkait
    if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(method) &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      _invalidateRelatedCaches(response.requestOptions.path);
    }

    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;

    // Offline-first fallback: Jika koneksi internet putus / timeout saat GET, sajikan stale cache jika ada
    if (options.method.toUpperCase() == 'GET') {
      final isNetworkIssue = err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.sendTimeout ||
          err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.connectionError;

      if (isNetworkIssue) {
        final cacheKey = _generateCacheKey(options);
        try {
          final staleJson = await localDatabase.getApiCache(
            cacheKey,
            ignoreExpiration: true,
          );
          if (staleJson != null && staleJson.isNotEmpty) {
            final decodedData = jsonDecode(staleJson);
            if (kDebugMode) {
              debugPrint('[DIO CACHE OFFLINE-FALLBACK] $cacheKey');
            }
            return handler.resolve(
              Response(
                requestOptions: options,
                data: decodedData,
                statusCode: 200,
                extra: {
                  ...options.extra,
                  'from_cache': true,
                  'is_stale': true,
                },
              ),
            );
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[DIO CACHE OFFLINE ERROR] Gagal membaca stale cache: $e');
          }
        }
      }
    }

    return handler.next(err);
  }

  /// Menghapus cache terkait saat ada perubahan data di endpoint tersebut
  void _invalidateRelatedCaches(String path) {
    try {
      // Potong path menjadi prefix utama
      final segments = path.split('/').where((s) => s.isNotEmpty).toList();
      if (segments.length >= 2) {
        final prefix = '/${segments[0]}/${segments[1]}%';
        localDatabase.deleteApiCachePattern(prefix);
        if (kDebugMode) {
          debugPrint('[DIO CACHE INVALIDATED] Prefix: $prefix');
        }
      }
    } catch (_) {}
  }
}
