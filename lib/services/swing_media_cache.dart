import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-first swing video playback.
///
/// Remote S3 URLs often fail in ExoPlayer (HTTP 403 / Range). We keep the
/// recorded file on device and, when needed, download the remote file once
/// then play from disk so playback stays reliable.
class SwingMediaCache {
  SwingMediaCache._();

  static const _indexKey = 'swing_media_cache_index_v1';

  /// Register a local clip after record / upload so library & share can play it.
  static Future<void> rememberLocal({
    required String localPath,
    String? swingId,
    String? analysisId,
    String? remoteUrl,
  }) async {
    final file = File(localPath);
    if (!await file.exists()) return;

    final prefs = await SharedPreferences.getInstance();
    final index = await _loadIndex(prefs);
    final entry = <String, String>{
      'path': localPath,
      if (swingId != null && swingId.isNotEmpty) 'swingId': swingId,
      if (analysisId != null && analysisId.isNotEmpty) 'analysisId': analysisId,
      if (remoteUrl != null && remoteUrl.isNotEmpty)
        'remoteUrl': _normalizeUrl(remoteUrl),
    };

    for (final key in _keysFor(
      swingId: swingId,
      analysisId: analysisId,
      remoteUrl: remoteUrl,
      localPath: localPath,
    )) {
      index[key] = entry;
    }
    await prefs.setString(_indexKey, jsonEncode(index));
  }

  /// Resolve a playable local file path when possible.
  /// Falls back to downloading [remoteUrl] into the cache.
  static Future<String?> resolveLocalPath({
    String? remoteUrl,
    String? swingId,
    String? analysisId,
    String? preferredLocalPath,
  }) async {
    final preferred = preferredLocalPath?.trim() ?? '';
    if (preferred.isNotEmpty &&
        !preferred.startsWith('http') &&
        await File(preferred).exists()) {
      return preferred;
    }

    final prefs = await SharedPreferences.getInstance();
    final index = await _loadIndex(prefs);

    for (final key in _keysFor(
      swingId: swingId,
      analysisId: analysisId,
      remoteUrl: remoteUrl,
    )) {
      final entry = index[key];
      final path = entry?['path'];
      if (path != null && path.isNotEmpty && await File(path).exists()) {
        return path;
      }
    }

    final remote = remoteUrl?.trim() ?? '';
    if (!remote.startsWith('http')) return null;

    return _downloadToCache(
      remoteUrl: remote,
      swingId: swingId,
      analysisId: analysisId,
      prefs: prefs,
      index: index,
    );
  }

  /// Best source for [VideoPlayer]: local file path, else remote URL, else null.
  static Future<({bool isLocal, String source})?> resolvePlayableSource({
    String? remoteUrl,
    String? swingId,
    String? analysisId,
    String? preferredLocalPath,
  }) async {
    final local = await resolveLocalPath(
      remoteUrl: remoteUrl,
      swingId: swingId,
      analysisId: analysisId,
      preferredLocalPath: preferredLocalPath,
    );
    if (local != null && local.isNotEmpty) {
      return (isLocal: true, source: local);
    }
    final remote = remoteUrl?.trim() ?? '';
    if (remote.startsWith('http')) {
      return (isLocal: false, source: remote);
    }
    final preferred = preferredLocalPath?.trim() ?? '';
    if (preferred.isNotEmpty && !preferred.startsWith('http')) {
      return (isLocal: true, source: preferred);
    }
    return null;
  }

  static Future<String?> _downloadToCache({
    required String remoteUrl,
    String? swingId,
    String? analysisId,
    required SharedPreferences prefs,
    required Map<String, Map<String, String>> index,
  }) async {
    try {
      final response = await http.get(Uri.parse(remoteUrl)).timeout(
            const Duration(minutes: 2),
          );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      if (response.bodyBytes.isEmpty) return null;

      final dir = await _cacheDir();
      final name = _fileNameFor(
        remoteUrl: remoteUrl,
        swingId: swingId,
        analysisId: analysisId,
      );
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(response.bodyBytes, flush: true);

      await rememberLocal(
        localPath: file.path,
        swingId: swingId,
        analysisId: analysisId,
        remoteUrl: remoteUrl,
      );
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<Directory> _cacheDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/swing_media_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static String _fileNameFor({
    required String remoteUrl,
    String? swingId,
    String? analysisId,
  }) {
    final id = (analysisId?.isNotEmpty == true)
        ? analysisId!
        : (swingId?.isNotEmpty == true)
            ? swingId!
            : remoteUrl.hashCode.toRadixString(16);
    final safe = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '');
    return 'swing_$safe.mp4';
  }

  static String _normalizeUrl(String url) {
    // Keep query (signed URLs); only trim whitespace.
    return url.trim();
  }

  static String _urlKey(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return 'url:${url.trim()}';
    // Match the same object even when query/signature differs.
    return 'url:${uri.replace(query: '', fragment: '').toString()}';
  }

  static Iterable<String> _keysFor({
    String? swingId,
    String? analysisId,
    String? remoteUrl,
    String? localPath,
  }) sync* {
    if (swingId != null && swingId.trim().isNotEmpty) {
      yield 'swing:${swingId.trim()}';
    }
    if (analysisId != null && analysisId.trim().isNotEmpty) {
      yield 'analysis:${analysisId.trim()}';
    }
    if (remoteUrl != null && remoteUrl.trim().isNotEmpty) {
      yield _urlKey(remoteUrl);
    }
    if (localPath != null && localPath.trim().isNotEmpty) {
      yield 'path:${localPath.trim()}';
    }
  }

  static Future<Map<String, Map<String, String>>> _loadIndex(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_indexKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      final out = <String, Map<String, String>>{};
      decoded.forEach((key, value) {
        if (value is Map) {
          out['$key'] = value.map(
            (k, v) => MapEntry('$k', '$v'),
          );
        }
      });
      return out;
    } catch (_) {
      return {};
    }
  }
}
