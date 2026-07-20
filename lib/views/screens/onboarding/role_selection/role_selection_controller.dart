import 'package:flutter/material.dart';

enum UserRole { golfer, coach }

/// Controller for the "Choose your role" screen (screen 6).
class RoleSelectionController extends ChangeNotifier {
  UserRole? selectedRole;

  bool get canContinue => selectedRole != null;

  void selectRole(UserRole role) {
    selectedRole = role;
    notifyListeners();
  }

  /// Called from the primary action once a role is chosen.
  void confirmSelection(ValueChanged<UserRole> onConfirmed) {
    if (selectedRole != null) {
      onConfirmed(selectedRole!);
    }
  }
}
