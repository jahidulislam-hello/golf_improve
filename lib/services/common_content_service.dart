import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/utils/api_constants.dart';

/// Public CMS endpoints under `/common/*`.
class CommonContentService {
  CommonContentService({required ApiService apiService}) : _api = apiService;

  final ApiService _api;

  Future<Map<String, dynamic>> getAbout() => _getMap(ApiConstants.commonAbout);

  Future<Map<String, dynamic>> getTerms() => _getMap(ApiConstants.commonTerms);

  Future<Map<String, dynamic>> getPrivacyPolicy() =>
      _getMap(ApiConstants.commonPrivacy);

  Future<Map<String, dynamic>> getSupport() =>
      _getMap(ApiConstants.commonSupport);

  Future<Map<String, dynamic>> getStandInfo() =>
      _getMap(ApiConstants.commonStand);

  Future<Map<String, dynamic>> _getMap(String url) async {
    final response = await _api.get(url);
    return Map<String, dynamic>.from(response as Map);
  }

  /// Prefer `content`, then `description`, then split into paragraphs.
  /// Some CMS endpoints return `data` as a list — first item wins.
  static List<String> paragraphsFrom(Map<String, dynamic>? response) {
    final data = _cmsRecord(response);
    if (data == null) return const [];
    final raw = '${data['content'] ?? data['description'] ?? ''}'.trim();
    if (raw.isEmpty) return const [];
    final plain = raw
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .trim();
    return plain
        .split(RegExp(r'\n+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String? titleFrom(Map<String, dynamic>? response) {
    final data = _cmsRecord(response);
    if (data == null) return null;
    final title = '${data['title'] ?? ''}'.trim();
    return title.isEmpty ? null : title;
  }

  static String supportEmail(Map<String, dynamic>? response) {
    final data = _cmsRecord(response);
    final email = '${data?['email'] ?? ''}'.trim();
    return email.isEmpty ? 'support@golfimprove.com' : email;
  }

  static Map<String, dynamic>? _cmsRecord(Map<String, dynamic>? response) {
    if (response == null) return null;
    final raw = response['data'];
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) return Map<String, dynamic>.from(item);
      }
      return null;
    }
    return response;
  }
}
