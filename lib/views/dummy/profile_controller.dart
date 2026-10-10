// import 'package:flutter/material.dart';
//
// /// Holds all state shown on the Profile screen (avatar, plan, connection
// /// status, and the settings list). Wire this up to your real user/repo
// /// layer — for now it ships with the values from the design.
// class ProfileController extends ChangeNotifier {
//   ProfileController({
//     String userName = 'Alex Thompson',
//     String? avatarUrl,
//     double handicap = 12.4,
//     bool isFreePlan = true,
//     bool isStandConnected = true,
//   })  : _userName = userName,
//         _avatarUrl = avatarUrl,
//         _handicap = handicap,
//         _isFreePlan = isFreePlan,
//         _isStandConnected = isStandConnected;
//
//   String _userName;
//   String get userName => _userName;
//
//   String? _avatarUrl;
//   String? get avatarUrl => _avatarUrl;
//
//   double _handicap;
//   double get handicap => _handicap;
//   String get handicapLabel => 'Handicap ${_handicap.toStringAsFixed(1)}';
//
//   bool _isFreePlan;
//   bool get isFreePlan => _isFreePlan;
//
//   bool _isStandConnected;
//   bool get isStandConnected => _isStandConnected;
//
//   /// Called from the "Upgrade" pill on the Free Plan card.
//   void upgradePlan() {
//     _isFreePlan = false;
//     notifyListeners();
//   }
//
//   /// Call after PersonalInfoScreen returns updated values, so the header
//   /// (name + handicap) stays in sync without a refetch.
//   void applyPersonalInfo({String? name, double? handicap, String? avatarUrl}) {
//     if (name != null) _userName = name;
//     if (handicap != null) _handicap = handicap;
//     if (avatarUrl != null) _avatarUrl = avatarUrl;
//     notifyListeners();
//   }
//
//   void toggleStandConnected(bool connected) {
//     _isStandConnected = connected;
//     notifyListeners();
//   }
// }
