import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_constants.dart';

import 'api_services.dart';
import 'golfer_service.dart';
import 'offline_swing_queue.dart';

/// Free-plan swing allowance, read from `GET /payment/paywall-status`.
///
/// The server is the source of truth and rejects the 4th upload with HTTP 402.
/// The app checks the same quota *before* recording so a free user is never
/// allowed to film a swing that can't be saved. The last known quota is cached
/// so the limit still applies offline, and clips waiting in the offline queue
/// count against the remaining swings.
class SwingQuota {
  const SwingQuota({
    required this.isUnlimited,
    required this.limit,
    required this.used,
    required this.remaining,
  });

  /// Used before the first successful server check on a fresh install.
  static const SwingQuota unknown = SwingQuota(
    isUnlimited: false,
    limit: null,
    used: 0,
    remaining: null,
  );

  final bool isUnlimited;
  final int? limit;
  final int used;
  final int? remaining;

  bool get isKnown => isUnlimited || remaining != null;

  bool get canRecord => isUnlimited || remaining == null || remaining! > 0;

  /// Applies clips recorded offline that the server has not counted yet.
  SwingQuota withPending(int pending) {
    if (isUnlimited || remaining == null || pending <= 0) return this;
    final left = remaining! - pending;
    return SwingQuota(
      isUnlimited: false,
      limit: limit,
      used: used + pending,
      remaining: left < 0 ? 0 : left,
    );
  }

  factory SwingQuota.fromPaywallStatus(Map<String, dynamic> data) {
    final quota = data['swingQuota'];
    if (quota is Map) {
      final unlimited = quota['isUnlimited'] == true;
      return SwingQuota(
        isUnlimited: unlimited,
        limit: _asInt(quota['limit']),
        used: _asInt(quota['used']) ?? 0,
        remaining: unlimited ? null : _asInt(quota['remaining']),
      );
    }
    final premium =
        data['hasPremiumAccess'] == true || data['bypassActive'] == true;
    return SwingQuota(
      isUnlimited: premium,
      limit: _asInt(data['freeSwingLimit']),
      used: _asInt(data['freeSwingsUsed']) ?? 0,
      remaining: premium ? null : _asInt(data['freeSwingsRemaining']),
    );
  }

  factory SwingQuota.fromJson(Map<String, dynamic> json) => SwingQuota(
        isUnlimited: json['isUnlimited'] == true,
        limit: _asInt(json['limit']),
        used: _asInt(json['used']) ?? 0,
        remaining: _asInt(json['remaining']),
      );

  Map<String, dynamic> toJson() => {
        'isUnlimited': isUnlimited,
        'limit': limit,
        'used': used,
        'remaining': remaining,
      };

  static int? _asInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse('$raw');
  }
}

class SwingQuotaService {
  SwingQuotaService._();

  static const String _cacheKey = ApiConstants.keySwingQuotaCache;

  /// Fetches the latest quota; falls back to the cached value when offline.
  /// Offline clips not yet synced are subtracted from what is left.
  static Future<SwingQuota> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    SwingQuota base;
    try {
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getPaywallStatus();
      final data = response['data'];
      base = data is Map
          ? SwingQuota.fromPaywallStatus(Map<String, dynamic>.from(data))
          : SwingQuota.unknown;
      if (base.isKnown) {
        await prefs.setString(_cacheKey, jsonEncode(base.toJson()));
      }
    } catch (_) {
      base = cached(prefs);
    }
    final pending = (await OfflineSwingQueue.load(prefs)).length;
    return base.withPending(pending);
  }

  static SwingQuota cached(SharedPreferences prefs) {
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return SwingQuota.unknown;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return SwingQuota.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {}
    return SwingQuota.unknown;
  }

  /// Clears the cached quota (e.g. on logout or after subscribing).
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
