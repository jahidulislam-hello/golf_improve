import 'package:flutter/material.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/services/golfer_service.dart';
import 'package:golf_training_app/views/screens/choose_plan/subscription_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads live plans and redeems a promo code.
///
/// Redeem calls `POST /promo-code/redeem`, which activates the subscription
/// and lets the server send the Klaviyo "Redeemed Promo Code" event.
class ChoosePlanController extends ChangeNotifier {
  ChoosePlanController() {
    promoController.addListener(_onPromoEdited);
    loadPlans();
  }

  final TextEditingController promoController = TextEditingController();
  final FocusNode promoFocus = FocusNode();
  int _promoRequest = 0;

  List<SubscriptionPlan> plans = const [];
  int selectedIndex = 0;
  bool isLoading = true;
  bool isValidating = false;
  bool isRedeeming = false;
  String? errorMessage;
  String? promoMessage;
  bool promoMessageIsError = false;
  PromoQuote? appliedPromo;

  String _lastPromoText = '';
  bool _isDisposed = false;

  SubscriptionPlan? get selectedPlan {
    if (plans.isEmpty) return null;
    final index = selectedIndex.clamp(0, plans.length - 1);
    return plans[index];
  }

  bool get isBusy => isLoading || isValidating || isRedeeming;

  int get displayTrialDays {
    final quote = appliedPromo;
    if (quote != null && quote.trialDays > 0) return quote.trialDays;
    return selectedPlan?.trialDays ?? 0;
  }

  String get ctaLabel {
    final quote = appliedPromo;
    final days = displayTrialDays;
    if (quote != null) {
      if (quote.discountType == 'free_trial_days' && days > 0) {
        return 'Start $days-Day Free Trial';
      }
      return 'Redeem ${quote.code}';
    }
    if (promoController.text.trim().isNotEmpty) return 'Apply promo code';
    return 'Redeem promo code';
  }

  Future<void> loadPlans() async {
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      final service = await _service();
      final response = await service.getPlans();
      plans = parsePlans(response['data']);
      if (selectedIndex >= plans.length) selectedIndex = 0;
      if (plans.isEmpty) {
        errorMessage = 'No subscription plans are available right now.';
      }
    } on ApiError catch (e) {
      plans = const [];
      errorMessage = e.message;
    } catch (e) {
      plans = const [];
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      _notify();
    }
  }

  void selectPlan(int index) {
    if (index < 0 || index >= plans.length || index == selectedIndex) return;
    selectedIndex = index;
    _promoRequest++;
    isValidating = false;
    appliedPromo = null;
    promoMessage = null;
    _notify();
    final code = promoController.text.trim();
    if (code.isNotEmpty) {
      applyPromo();
    }
  }

  Future<bool> applyPromo() async {
    final plan = selectedPlan;
    final code = promoController.text.trim().toUpperCase();
    if (plan == null || plan.id.isEmpty) {
      _setPromoMessage('Choose a plan first.', isError: true);
      return false;
    }
    if (code.isEmpty) {
      _setPromoMessage('Enter a promo code.', isError: true);
      return false;
    }

    final request = ++_promoRequest;
    isValidating = true;
    promoMessage = null;
    _notify();
    try {
      final service = await _service();
      final response = await service.validatePromoCode(
        code: code,
        planId: plan.id,
      );
      if (request != _promoRequest) return false;
      final data = response['data'];
      appliedPromo = PromoQuote.fromJson(
        data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
        fallbackCode: code,
        currency: plan.currency,
      );
      _syncPromoField(appliedPromo!.code);
      final savings = appliedPromo!.savingsLabel;
      _setPromoMessage(
        savings == null
            ? '${appliedPromo!.code} · ${appliedPromo!.summary}'
            : '${appliedPromo!.code} · ${appliedPromo!.summary} · $savings',
        isError: false,
      );
      return true;
    } on ApiError catch (e) {
      if (request != _promoRequest) return false;
      appliedPromo = null;
      _setPromoMessage(e.message, isError: true);
      return false;
    } catch (e) {
      if (request != _promoRequest) return false;
      appliedPromo = null;
      _setPromoMessage(e.toString(), isError: true);
      return false;
    } finally {
      if (request == _promoRequest) {
        isValidating = false;
        _notify();
      }
    }
  }

  /// Validates the code when needed, then redeems it.
  /// Returns the server success message.
  Future<String?> redeem() async {
    final plan = selectedPlan;
    if (plan == null || plan.id.isEmpty) {
      _setPromoMessage('Choose a plan first.', isError: true);
      return null;
    }

    final typed = promoController.text.trim();
    if (typed.isEmpty && appliedPromo == null) {
      _setPromoMessage('Enter a promo code to activate this plan.', isError: true);
      return null;
    }

    final quote = appliedPromo;
    final quoteMatches = quote != null &&
        quote.code.toUpperCase() == typed.toUpperCase();
    if (!quoteMatches) {
      final valid = await applyPromo();
      if (!valid) return null;
    }

    final code = (appliedPromo?.code ?? typed).trim().toUpperCase();
    final planId = selectedPlan?.id ?? plan.id;
    isRedeeming = true;
    promoMessageIsError = false;
    _notify();
    try {
      final service = await _service();
      final response = await service.redeemPromoCode(
        code: code,
        planId: planId,
      );
      final message = '${response['message'] ?? ''}'.trim();
      return message.isEmpty
          ? 'Promo code "$code" applied successfully!'
          : message;
    } on ApiError catch (e) {
      _setPromoMessage(e.message, isError: true);
      return null;
    } catch (e) {
      _setPromoMessage(e.toString(), isError: true);
      return null;
    } finally {
      isRedeeming = false;
      _notify();
    }
  }

  void _onPromoEdited() {
    if (promoController.text == _lastPromoText) return;
    _lastPromoText = promoController.text;
    _promoRequest++;
    isValidating = false;
    if (appliedPromo == null && promoMessage == null) return;
    appliedPromo = null;
    promoMessage = null;
    _notify();
  }

  void _syncPromoField(String code) {
    if (promoController.text == code) {
      _lastPromoText = code;
      return;
    }
    _lastPromoText = code;
    promoController.value = TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
  }

  void _setPromoMessage(String message, {required bool isError}) {
    promoMessage = message;
    promoMessageIsError = isError;
    _notify();
  }

  Future<GolferService> _service() async {
    final prefs = await SharedPreferences.getInstance();
    return GolferService(apiService: ApiService(sharedPreferences: prefs));
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    promoController.removeListener(_onPromoEdited);
    promoController.dispose();
    promoFocus.dispose();
    super.dispose();
  }
}
