import '../constants/api_constants.dart';

/// Utilitas untuk normalisasi URL berkas dan gambar dari respons Backend.
class AppUrlUtils {
  AppUrlUtils._();

  /// Mengubah URL parsial / path relatif dari BE menjadi URL lengkap yang valid.
  /// Menangani path relatif, backslash Windows, ketiadaan skema https://, dsb.
  static String getFullImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return '';
    }

    // 1. Normalisasi semua backslash Windows '\' menjadi forward slash '/'
    String cleanUrl = url.trim().replaceAll(r'\', '/');

    // 2. Jika sudah merupakan URI lengkap (http, https, file, data, content)
    if (cleanUrl.startsWith('http://') ||
        cleanUrl.startsWith('https://') ||
        cleanUrl.startsWith('file://') ||
        cleanUrl.startsWith('content://') ||
        cleanUrl.startsWith('data:')) {
      return cleanUrl;
    }

    // 3. Jika diawali protocol-relative '//'
    if (cleanUrl.startsWith('//')) {
      return 'https:$cleanUrl';
    }

    // 4. Ambil Base URL dari ApiConstants (misal: "https://super-i-app.co.id/api")
    final String base = ApiConstants.baseUrl.replaceAll(RegExp(r'/+$'), '');

    // 5. Cegah duplikasi '/api/api' jika base URL berakhiran '/api' dan path diawali '/api'
    if (base.endsWith('/api')) {
      if (cleanUrl.startsWith('/api/')) {
        cleanUrl = cleanUrl.substring(4);
      } else if (cleanUrl.startsWith('api/')) {
        cleanUrl = cleanUrl.substring(3);
      }
    }

    // 6. Pastikan path memiliki leading slash
    final String path = cleanUrl.startsWith('/') ? cleanUrl : '/$cleanUrl';

    return '$base$path';
  }

  /// Alias untuk memastikan URL gambar valid dan memiliki skema lengkap
  static String ensureHttps(String? url) => getFullImageUrl(url);

  /// Resolves any relative or absolute media path to a full URL (returns null if empty)
  static String? resolveMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    return getFullImageUrl(url);
  }
}
