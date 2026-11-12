import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:golf_training_app/controllers/auth_controller.dart';
import 'package:golf_training_app/helpers/routes.dart';
import 'package:golf_training_app/views/screens/auth/screens/coach_tell_us_about_your.dart';
import 'package:golf_training_app/views/screens/auth/screens/tell_us_about_your.dart';
import 'package:golf_training_app/views/screens/auth/widgets/secondary_button.dart';
import 'package:golf_training_app/views/screens/onboarding/role_selection/role_selection_controller.dart';

void showAuthErrorSnackBar(BuildContext context, AuthController auth) {
  final message = auth.errorMessage;
  if (message == null || message.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}

bool get supportsAppleSignInButton {
  if (kIsWeb) return false;
  return Platform.isIOS || Platform.isMacOS;
}

/// Shared Google / Apple buttons used by Sign In and Sign Up.
class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.auth,
    this.afterSuccessPreferProfileSetup = false,
  });

  final AuthController auth;

  /// When true (Sign Up screen), incomplete profiles go to profile setup first.
  final bool afterSuccessPreferProfileSetup;

  Future<void> _finishSocialAuth(BuildContext context) async {
    if (!context.mounted) return;

    final role = auth.selectedRole ?? UserRole.golfer;
    final goToSetup =
        afterSuccessPreferProfileSetup || auth.needsProfileSetup;

    if (goToSetup) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => role == UserRole.coach
              ? const CoachProfileSetUpScreen()
              : const ProfileSetUpScreen(),
        ),
      );
      return;
    }

    AppRoutes.goToHomeForRole(role);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SecondaryButton.google(
          onPressed: auth.isLoading
              ? null
              : () async {
                  final success = await auth.signInWithGoogle();
                  if (!context.mounted) return;
                  if (!success) {
                    showAuthErrorSnackBar(context, auth);
                    return;
                  }
                  await _finishSocialAuth(context);
                },
        ),
        if (supportsAppleSignInButton) ...[
          const SizedBox(height: 14),
          SecondaryButton.apple(
            onPressed: auth.isLoading
                ? null
                : () async {
                    final success = await auth.signInWithApple();
                    if (!context.mounted) return;
                    if (!success) {
                      showAuthErrorSnackBar(context, auth);
                      return;
                    }
                    await _finishSocialAuth(context);
                  },
          ),
        ],
      ],
    );
  }
}
