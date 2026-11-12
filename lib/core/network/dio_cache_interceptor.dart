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
    final auth = options.headers['Authorization']?.toString();
    if (auth != null && auth.isNotEmpty) {
      // User-scoped cache key (guna menghindari bentrok data antar user)
      final tokenHash = auth.hashCode.abs().toString();
      buffer.write('@$tokenHash');
    }
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
        options.headers['cache-control'] == 'no-cache' ||
        options.path.contains('/absensi/info');
    final forceRefresh = options.extra['force_refresh'] == true;

    // Jika forceRefresh, hapus cache sebelumnya agar data segar dari server tersimpan baru
    if (forceRefresh) {
      final cacheKey = _generateCacheKey(options);
      try {
        await localDatabase.deleteApiCache(cacheKey);
      } catch (_) {}
      return handler.next(options);
    }

    if (noCache) {
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
      final noCache = response.requestOptions.extra['no_cache'] == true ||
          response.requestOptions.headers['cache-control'] == 'no-cache' ||
          response.requestOptions.path.contains('/absensi/info');
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

    // 2. Jika mutasi berhasil (POST, PUT, PATCH, DELETE, dll selain GET), invalidate cache terkait di store
    if (method != 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final skipInvalidation =
          response.requestOptions.extra['skip_cache_invalidation'] == true;
      if (!skipInvalidation) {
        await _invalidateRelatedCaches(response.requestOptions.path);
      }
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
          err.type == DioExceptionType.connectionError ||
          (err.type == DioExceptionType.unknown && err.error != null);

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
  Future<void> _invalidateRelatedCaches(String path) async {
    try {
      final cleanPath = path.replaceAll(RegExp(r'^https?://[^/]+'), '');
      final segments = cleanPath
          .split('/')
          .where((s) => s.isNotEmpty && !s.startsWith('?'))
          .toList();

      const nonResourceWords = {
        'api', 'v1', 'v2', 'v3', 'input', 'update', 'delete', 'today',
        'detail', 'create', 'edit', 'store', 'upload', 'progress', 'custom',
        'kondisi', 'report', 'urutan',
      };

      // Filter segmen yang bukan angka/ID dan bukan kata kerja umum
      final resourceSegments = segments.where((s) {
        if (int.tryParse(s) != null) return false;
        if (nonResourceWords.contains(s.toLowerCase())) return false;
        return true;
      }).toList();

      // 1. Bersihkan cache yang mengandung path mutasi
      await localDatabase.deleteApiCachePattern('%$cleanPath%');

      // 2. Bersihkan cache berdasarkan setiap resource keyword (misal: '%beban-penyulang%')
      for (final resource in resourceSegments) {
        await localDatabase.deleteApiCachePattern('%$resource%');
      }

      // 3. Pembersihan silang antar modul yang saling mempengaruhi (Cross-module invalidation)
      final lowerPath = cleanPath.toLowerCase();

      // Absen, Shift & Penilaian
      if (lowerPath.contains('shift') || lowerPath.contains('absen')) {
        await localDatabase.deleteApiCachePattern('%shift%');
        await localDatabase.deleteApiCachePattern('%absen%');
        await localDatabase.deleteApiCachePattern('%penilaian%');
        await localDatabase.deleteApiCachePattern('%home%');
      }

      // OPGI 20KV Realisasi & Dashboard
      if (lowerPath.contains('penyulang') ||
          lowerPath.contains('trafo') ||
          lowerPath.contains('kwh') ||
          lowerPath.contains('tegangan')) {
        await localDatabase.deleteApiCachePattern('%beban-penyulang%');
        await localDatabase.deleteApiCachePattern('%beban-trafo%');
        await localDatabase.deleteApiCachePattern('%tegangan-trafo%');
        await localDatabase.deleteApiCachePattern('%kwh-harian%');
        await localDatabase.deleteApiCachePattern('%input-realisasi%');
        await localDatabase.deleteApiCachePattern('%dashboard%');
      }

      // OPGI Manuver & Anomali & IL1
      if (lowerPath.contains('manuver')) {
        await localDatabase.deleteApiCachePattern('%manuver%');
      }
      if (lowerPath.contains('anomali')) {
        await localDatabase.deleteApiCachePattern('%anomali%');
      }
      if (lowerPath.contains('il1-')) {
        await localDatabase.deleteApiCachePattern('%il1-%');
      }

      // Distribusi Inspeksi & Pemeliharaan
      if (lowerPath.contains('inspeksi') ||
          lowerPath.contains('pemeliharaan') ||
          lowerPath.contains('workorder') ||
          lowerPath.contains('wo-')) {
        await localDatabase.deleteApiCachePattern('%inspeksi%');
        await localDatabase.deleteApiCachePattern('%pemeliharaan%');
        await localDatabase.deleteApiCachePattern('%workorder%');
        await localDatabase.deleteApiCachePattern('%wo-%');
        await localDatabase.deleteApiCachePattern('%yantek%');
        await localDatabase.deleteApiCachePattern('%dashboard%');
      }

      // Line Walker
      if (lowerPath.contains('ppl') ||
          lowerPath.contains('pembumian') ||
          lowerPath.contains('kegiatan-sosial') ||
          lowerPath.contains('waterpass') ||
          lowerPath.contains('ketenagakerjaan')) {
        await localDatabase.deleteApiCachePattern('%ppl%');
        await localDatabase.deleteApiCachePattern('%pembumian%');
        await localDatabase.deleteApiCachePattern('%kegiatan-sosial%');
        await localDatabase.deleteApiCachePattern('%waterpass%');
        await localDatabase.deleteApiCachePattern('%ketenagakerjaan%');
        await localDatabase.deleteApiCachePattern('%line-walker%');
      }

      if (kDebugMode) {
        debugPrint('[DIO CACHE INVALIDATED] Path: $cleanPath, Resources: $resourceSegments');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DIO CACHE INVALIDATION ERROR] $e');
      }
    }
  }
}
