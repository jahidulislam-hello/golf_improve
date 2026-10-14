import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constants.dart';

/// Local queue of swings recorded without a successful server upload.
class OfflineSwingQueue {
  static Future<List<Map<String, dynamic>>> load(SharedPreferences prefs) async {
    final raw = prefs.getString(ApiConstants.keyOfflineSwings);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(
    SharedPreferences prefs,
    List<Map<String, dynamic>> items,
  ) async {
    if (items.isEmpty) {
      await prefs.remove(ApiConstants.keyOfflineSwings);
      return;
    }
    await prefs.setString(ApiConstants.keyOfflineSwings, jsonEncode(items));
  }

  static Future<void> enqueue(
    SharedPreferences prefs,
    Map<String, dynamic> item,
  ) async {
    final items = await load(prefs);
    final key = '${item['idempotencyKey'] ?? item['local_id'] ?? ''}';
    items.removeWhere(
      (e) => '${e['idempotencyKey'] ?? e['local_id'] ?? ''}' == key && key.isNotEmpty,
    );
    items.add(item);
    await save(prefs, items);
  }

  static bool fileExists(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }
}
