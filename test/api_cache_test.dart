import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_i_mobile/core/network/dio_cache_interceptor.dart';
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
  });
}
