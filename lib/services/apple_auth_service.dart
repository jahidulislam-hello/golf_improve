import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Native Sign in with Apple → identity token for `POST /auth/apple`.
class AppleAuthService {
  /// Returns whether this device can show the Apple sheet.
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;
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

    final available = await isAvailable();
    if (!available) {
      throw StateError(
        Platform.isAndroid
            ? 'Apple Sign-In is not available on this Android device. Use Google or email.'
            : 'Apple Sign-In is not available on this device.',
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
      throw StateError(e.message);
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
