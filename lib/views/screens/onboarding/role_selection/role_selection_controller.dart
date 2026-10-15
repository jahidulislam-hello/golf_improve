import 'package:flutter/material.dart';

enum UserRole { golfer, coach }

extension UserRoleApi on UserRole {
  /// API role values: golfer → `user`, coach → `coach`.
  String get apiValue {
    switch (this) {
      case UserRole.golfer:
        return 'user';
      case UserRole.coach:
        return 'coach';
    }
  }

  static UserRole? fromApiValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'user':
      case 'golfer':
        return UserRole.golfer;
      case 'coach':
        return UserRole.coach;
      default:
        return null;
    }
  }
}

/// Controller for the "Choose your role" screen (screen 6).
class RoleSelectionController extends ChangeNotifier {
  UserRole? selectedRole;

  void selectRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }
}
