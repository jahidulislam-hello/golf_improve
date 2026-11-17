import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/services/paywall_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Free users get 3 recorded swings, then the paywall. Not bypassable from UI.
class FreeSwingQuota {
  FreeSwingQuota._();

  static const int freeLimit = 3;
  static const String _keyCount = 'free_swing_record_count';

  static Future<bool> hasPremiumAccess(SharedPreferences prefs) async {
    final cached = prefs.getBool('has_premium_access');
    if (cached == true) return true;

    final user = ApiService(sharedPreferences: prefs).getUserData();
    if (user != null) {
      final plan = '${user['plan'] ?? user['subscriptionPlan'] ?? ''}'.toLowerCase();
      final status =
          '${user['subscriptionStatus'] ?? user['status'] ?? ''}'.toLowerCase();
      if (plan.contains('pro') ||
          plan.contains('premium') ||
          plan.contains('stand') ||
          status == 'active' ||
          status == 'trialing' ||
          status == 'trial') {
        return true;
      }
      final paywall = user['paywall'];
      if (paywall is Map &&
          (paywall['hasPremiumAccess'] == true ||
              paywall['bypassActive'] == true)) {
        return true;
      }
    }

    try {
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );
      final response = await service.getPaywallStatus();
      final data = response['data'];
      if (data is Map &&
          (data['hasPremiumAccess'] == true || data['bypassActive'] == true)) {
        await prefs.setBool('has_premium_access', true);
        return true;
      }
    } catch (_) {}

    return false;
  }

  static int recordedCount(SharedPreferences prefs) =>
      prefs.getInt(_keyCount) ?? 0;

  static Future<int> remaining(SharedPreferences prefs) async {
    if (await hasPremiumAccess(prefs)) return freeLimit;
    return (freeLimit - recordedCount(prefs)).clamp(0, freeLimit);
  }

  /// Returns true when the user may start another recording.
  /// Opens the paywall and returns false when the free quota is used up.
  static Future<bool> ensureCanRecord() async {
    final prefs = await SharedPreferences.getInstance();
    if (await hasPremiumAccess(prefs)) return true;
    if (recordedCount(prefs) < freeLimit) return true;
    PaywallGate.open();
    return false;
  }

  static Future<void> incrementAfterSuccessfulUpload() async {
    final prefs = await SharedPreferences.getInstance();
    if (await hasPremiumAccess(prefs)) return;
    final next = recordedCount(prefs) + 1;
    await prefs.setInt(_keyCount, next);
  }

  static Future<void> markPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_premium_access', true);
  }
}
