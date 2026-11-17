import 'package:golf_training_app/services/paywall_gate.dart';
import 'package:golf_training_app/services/swing_quota_service.dart';

/// Free users get 3 recorded swings, then the paywall.
///
/// Kept for existing call sites; it delegates to [SwingQuotaService], which
/// reads the quota from the server (`/payment/paywall-status`). The server
/// counts every stored swing, so the limit survives reinstalls, new devices
/// and logout — a device-local counter could not.
class FreeSwingQuota {
  FreeSwingQuota._();

  static const int freeLimit = 3;

  /// Returns true when the user may start another recording.
  /// Opens the paywall and returns false when the free quota is used up.
  static Future<bool> ensureCanRecord() async {
    final quota = await SwingQuotaService.refresh();
    if (quota.canRecord) return true;
    PaywallGate.open();
    return false;
  }

  /// The server counts swings when they are stored; nothing to do locally.
  static Future<void> incrementAfterSuccessfulUpload() async {}

  /// After subscribing or redeeming a code, drop the cached quota so the next
  /// check asks the server again.
  static Future<void> markPremium() => SwingQuotaService.clear();
}
