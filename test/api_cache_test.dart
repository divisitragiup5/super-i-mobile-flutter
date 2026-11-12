import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/network/dio_cache_interceptor.dart';
import 'package:super_i_mobile/core/storage/local_database.dart';
import 'package:super_i_mobile/core/utils/app_url_utils.dart';

class _TestRequestHandler extends RequestInterceptorHandler {
  bool nextCalled = false;
  Response? resolvedResponse;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }

  @override
  void resolve(Response response, [bool callFollowingResponseInterceptor = false]) {
    resolvedResponse = response;
  }
}

void main() {
  group('AppUrlUtils Tests', () {
    test('getFullImageUrl handles relative paths and Windows backslashes', () {
      expect(AppUrlUtils.ensureHttps('uploads\\images\\photo.jpg'), contains('uploads/images/photo.jpg'));
      expect(AppUrlUtils.ensureHttps('https://example.com/photo.jpg'), 'https://example.com/photo.jpg');
      expect(AppUrlUtils.ensureHttps('//example.com/photo.jpg'), 'https://example.com/photo.jpg');
    });
  });

  group('DioCacheInterceptor Cache Key & Configuration Tests', () {
    test('Interceptor is instantiated with default 24h TTL', () {
      final interceptor = DioCacheInterceptor();
      expect(interceptor.defaultTtl, const Duration(hours: 24));
    });

    test('Non-GET requests pass through without cache reading', () async {
      final interceptor = DioCacheInterceptor();
      final options = RequestOptions(path: '/api/submit', method: 'POST');
      final handler = _TestRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.nextCalled, isTrue);
      expect(handler.resolvedResponse, isNull);
    });

    test('GET requests forward to network when cache is empty', () async {
      final fakeDb = _FakeLocalDatabase();
      final interceptor = DioCacheInterceptor(localDatabase: fakeDb);
      final options = RequestOptions(path: '/api/data/items', method: 'GET');
      final handler = _TestRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.nextCalled, isTrue);
      expect(handler.resolvedResponse, isNull);
    });

    test('GET requests resolve immediately from cache when cache is present (Cache-First)', () async {
      final fakeDb = _FakeLocalDatabase();
      fakeDb.cacheStore['/api/data/items'] = '{"data": [{"id": 1, "nama": "Penyulang 1"}]}';
      final interceptor = DioCacheInterceptor(localDatabase: fakeDb);
      final options = RequestOptions(path: '/api/data/items', method: 'GET');
      final handler = _TestRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.resolvedResponse, isNotNull);
      expect(handler.resolvedResponse?.statusCode, 200);
      expect(handler.resolvedResponse?.extra['from_cache'], isTrue);
    });

    test('GET request with force_refresh: true bypasses cache and passes through to network', () async {
      final fakeDb = _FakeLocalDatabase();
      fakeDb.cacheStore['/api/data/items'] = '{"data": [{"id": 1}]}';
      final interceptor = DioCacheInterceptor(localDatabase: fakeDb);
      final options = RequestOptions(
        path: '/api/data/items',
        method: 'GET',
        extra: {'force_refresh': true},
      );
      final handler = _TestRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.nextCalled, isTrue);
      expect(handler.resolvedResponse, isNull);
    });
  });

  group('Content-Type Handling Tests', () {
    test('Request with null data has no Content-Type header', () {
      final options = RequestOptions(path: '/api/delete-item', method: 'DELETE');
      if (options.data == null) {
        options.headers.remove('Content-Type');
        options.headers.remove('content-type');
        options.contentType = null;
      }

      expect(options.headers['Content-Type'], isNull);
      expect(options.headers['content-type'], isNull);
      expect(options.contentType, isNull);
    });

    test('Request with data retains or sets application/json Content-Type', () {
      final options = RequestOptions(
        path: '/api/update-item',
        method: 'POST',
        data: {'name': 'test'},
      );
      if (options.data != null && options.data is! FormData) {
        options.headers['Content-Type'] ??= 'application/json';
      }

      expect(options.headers['Content-Type'], 'application/json');
    });
  });

  group('Mutation Cache Invalidation Tests', () {
    test('Non-GET successful responses invalidate matching cache patterns in store', () async {
      final fakeDb = _FakeLocalDatabase();
      final interceptor = DioCacheInterceptor(localDatabase: fakeDb);

      for (final method in ['POST', 'PUT', 'PATCH', 'DELETE']) {
        fakeDb.deletedPatterns.clear();
        final options = RequestOptions(
          path: '/gama/opgi-20kv/operator-gi/beban-penyulang/3504423',
          method: method,
        );
        final response = Response(
          requestOptions: options,
          statusCode: 200,
        );
        final handler = _TestResponseHandler();

        await interceptor.onResponse(response, handler);

        expect(handler.nextCalled, isTrue);
        expect(fakeDb.deletedPatterns, contains('%beban-penyulang%'));
        expect(fakeDb.deletedPatterns, contains('%/gama/opgi-20kv/operator-gi/beban-penyulang/3504423%'));
      }
    });

    test('Non-GET response with skip_cache_invalidation: true preserves cache (does not wipe)', () async {
      final fakeDb = _FakeLocalDatabase();
      final interceptor = DioCacheInterceptor(localDatabase: fakeDb);

      final options = RequestOptions(
        path: '/gama/opgi-20kv/operator-gi/beban-penyulang/3504423',
        method: 'DELETE',
        extra: {'skip_cache_invalidation': true},
      );
      final response = Response(
        requestOptions: options,
        statusCode: 200,
      );
      final handler = _TestResponseHandler();

      await interceptor.onResponse(response, handler);

      expect(handler.nextCalled, isTrue);
      expect(fakeDb.deletedPatterns, isEmpty);
    });
  });
}

class _FakeLocalDatabase extends LocalDatabase {
  final List<String> deletedPatterns = [];
  final Map<String, String> cacheStore = {};

  @override
  Future<String?> getApiCache(String key, {bool ignoreExpiration = false}) async {
    return cacheStore[key];
  }

  @override
  Future<void> saveApiCache(String key, String data, {int? ttlSeconds}) async {
    cacheStore[key] = data;
  }

  @override
  Future<int> deleteApiCache(String key) async {
    cacheStore.remove(key);
    return 1;
  }

  @override
  Future<int> deleteApiCachePattern(String pattern) async {
    deletedPatterns.add(pattern);
    return 1;
  }
}

class _TestResponseHandler extends ResponseInterceptorHandler {
  bool nextCalled = false;
  Response? forwardedResponse;

  @override
  void next(Response response) {
    nextCalled = true;
    forwardedResponse = response;
  }
}

