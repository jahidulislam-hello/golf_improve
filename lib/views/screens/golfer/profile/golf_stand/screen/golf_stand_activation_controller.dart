import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/free_swing_quota.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ActivationStatus { idle, submitting, success, error }

/// Stand buyer codes are redeemed through `/promo-code/redeem`
/// (same codes emailed after a GolfImprove Stand purchase).
class GolfStandActivationController extends ChangeNotifier {
  GolfStandActivationController() {
    codeController.addListener(() {
      if (status == ActivationStatus.error) {
        status = ActivationStatus.idle;
        errorMessage = null;
        notifyListeners();
      }
    });
  }

  final TextEditingController codeController = TextEditingController();

  ActivationStatus status = ActivationStatus.idle;
  String? errorMessage;
  String? successMessage;

  /// Stand promo codes vary in length; UI field allows up to 12 chars.
  static const int codeLength = 6;

  bool get isCodeComplete => codeController.text.trim().length >= codeLength;

  bool get isSubmitting => status == ActivationStatus.submitting;

  void applyScannedCode(String scannedCode) {
    codeController.text = scannedCode.trim().toUpperCase();
    notifyListeners();
  }

  Future<bool> activate() async {
    final code = codeController.text.trim().toUpperCase();
    if (code.length < codeLength) {
      status = ActivationStatus.error;
      errorMessage = 'Enter the full activation / promo code from your Stand.';
      notifyListeners();
      return false;
    }

    status = ActivationStatus.submitting;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final service = GolferService(
        apiService: ApiService(sharedPreferences: prefs),
      );

      final planId = await _resolvePlanId(service);
      if (planId.isEmpty) {
        status = ActivationStatus.error;
        errorMessage =
            'No subscription plan is available to attach this Stand code.';
        notifyListeners();
        return false;
      }

      final response = await service.redeemPromoCode(
        code: code,
        planId: planId,
      );
      await FreeSwingQuota.markPremium();
      try {
        final profile = await service.getMyProfile();
        final data = profile['data'];
        final name = data is Map
            ? '${data['name'] ?? data['fullName'] ?? 'Golfer'}'.trim()
            : 'Golfer';
        await service.updateProfileBasics(
          name: name.isEmpty ? 'Golfer' : name,
          usesGolfImproveStand: true,
        );
      } catch (_) {
        // Profile flag is best-effort; redemption already succeeded.
      }

      final message = '${response['message'] ?? ''}'.trim();
      successMessage = message.isEmpty
          ? 'Stand code activated. Premium access is unlocked.'
          : message;
      status = ActivationStatus.success;
      notifyListeners();
      return true;
    } on ApiError catch (e) {
      status = ActivationStatus.error;
      errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      status = ActivationStatus.error;
      errorMessage = 'Something went wrong — please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<String> _resolvePlanId(GolferService service) async {
    String pick(List<dynamic> list) {
      Map<String, dynamic>? stand;
      Map<String, dynamic>? first;
      for (final item in list) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        first ??= map;
        final label =
            '${map['planType'] ?? ''} ${map['name'] ?? ''}'.toLowerCase();
        if (label.contains('stand')) {
          stand = map;
          break;
        }
      }
      final chosen = stand ?? first;
      if (chosen == null) return '';
      return '${chosen['_id'] ?? chosen['id'] ?? ''}'.trim();
    }

    try {
      final launch = await service.getLaunchPlan();
      final data = launch['data'];
      if (data is List) {
        final id = pick(data);
        if (id.isNotEmpty) return id;
      } else if (data is Map) {
        final id = '${data['_id'] ?? data['id'] ?? ''}'.trim();
        if (id.isNotEmpty) return id;
        final nested = data['plans'] ?? data['results'] ?? data['items'];
        if (nested is List) {
          final idNested = pick(nested);
          if (idNested.isNotEmpty) return idNested;
        }
      }
    } catch (_) {}

    try {
      final plans = await service.getPlans();
      final data = plans['data'];
      if (data is List) return pick(data);
      if (data is Map) {
        final nested = data['plans'] ?? data['results'] ?? data['items'];
        if (nested is List) return pick(nested);
      }
    } catch (_) {}
    return '';
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }
}
