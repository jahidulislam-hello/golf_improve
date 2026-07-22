import 'package:flutter/foundation.dart';

/// Which subscription tier the golfer is on.
enum PlanType { free, pro }

/// Holds all state shown on the Profile / Settings screen:
/// the header (name + handicap + avatar), the plan-upsell card,
/// the "Golf Stand Connected" status row, and the settings list.
///
/// Wire this up with a real repository/API layer later — for now it just
/// exposes plain fields + notifyListeners() so the UI can react to changes.
class GolferProfileController extends ChangeNotifier {
  GolferProfileController({
    String name = 'Alex Thompson',
    double handicap = 12.4,
    String? avatarUrl,
    PlanType plan = PlanType.free,
    bool golfStandConnected = true,
  })  : _name = name,
        _handicap = handicap,
        _avatarUrl = avatarUrl,
        _plan = plan,
        _golfStandConnected = golfStandConnected;

  String _name;
  double _handicap;
  String? _avatarUrl;
  PlanType _plan;
  bool _golfStandConnected;

  String get name => _name;
  double get handicap => _handicap;
  String? get avatarUrl => _avatarUrl;
  PlanType get plan => _plan;
  bool get isFreePlan => _plan == PlanType.free;
  bool get golfStandConnected => _golfStandConnected;

  String get handicapLabel => 'Handicap ${_handicap.toStringAsFixed(1)}';

  /// Called when the golfer taps "Upgrade" on the free-plan card.
  /// Replace the body with your real purchase/paywall flow.
  Future<void> upgradePlan() async {
    // TODO: hook into in-app purchase / paywall.
    _plan = PlanType.pro;
    notifyListeners();
  }

  /// Reflects a change in the physical Golf Stand's connection state
  /// (e.g. from a Bluetooth/companion-device listener).
  void setGolfStandConnected(bool connected) {
    if (_golfStandConnected == connected) return;
    _golfStandConnected = connected;
    notifyListeners();
  }

  /// Applies edits made on the Personal Info screen back to the header.
  void applyPersonalInfo({required String name, required double handicap}) {
    _name = name;
    _handicap = handicap;
    notifyListeners();
  }

  /// Signs the current user out.
  Future<void> logOut() async {
    // TODO: clear session/tokens and navigate to the auth flow.
  }
}
