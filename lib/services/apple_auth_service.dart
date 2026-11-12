import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Native Sign in with Apple → identity token for `POST /auth/apple`.
///
/// Native Apple sheet works on iOS/macOS. Android needs a configured Apple
/// Services ID + HTTPS redirect (not set up for this app), so Android is
/// treated as unavailable.
class AppleAuthService {
  /// Returns whether this device can show the Apple sheet.
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
    if (!(Platform.isIOS || Platform.isMacOS)) return false;
    try {
      return await SignInWithApple.isAvailable();
    } catch (_) {
      return Platform.isIOS || Platform.isMacOS;
    }
  }

  /// Opens the Apple account sheet and returns tokens for the API.
  Future<AppleSignInResult> signIn() async {
    if (kIsWeb) {
      throw StateError('Apple Sign-In is not supported on web in this app.');
    }

    if (!(Platform.isIOS || Platform.isMacOS)) {
      throw StateError(
        'Apple Sign-In is available on iPhone/iPad. On Android, use Google or email.',
      );
    }

    final available = await isAvailable();
    if (!available) {
      throw StateError(
        'Apple Sign-In is not available on this device. '
        'Confirm Sign in with Apple is enabled for eu.golfimprove in Apple Developer.',
      );
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw StateError(
          'Apple did not return an identity token. Try again, or use email sign-in.',
        );
      }

      final given = credential.givenName?.trim() ?? '';
      final family = credential.familyName?.trim() ?? '';
      final fullName = [
        if (given.isNotEmpty) given,
        if (family.isNotEmpty) family,
      ].join(' ').trim();

      return AppleSignInResult(
        identityToken: identityToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        fullName: fullName.isEmpty ? null : fullName,
        userIdentifier: credential.userIdentifier,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AppleSignInCanceled();
      }
      throw StateError(
        e.message.isNotEmpty ? e.message : 'Apple Sign-In failed (${e.code}).',
      );
    }
  }
}

class AppleSignInCanceled implements Exception {
  const AppleSignInCanceled();
}

class AppleSignInResult {
  const AppleSignInResult({
    required this.identityToken,
    required this.authorizationCode,
    this.email,
    this.fullName,
    this.userIdentifier,
  });

  final String identityToken;
  final String authorizationCode;
  final String? email;
  final String? fullName;
  final String? userIdentifier;
}
