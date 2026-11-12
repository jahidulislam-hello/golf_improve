import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Native Sign in with Apple → identity token for `POST /auth/apple`.
///
/// Native Apple sheet works on iOS/macOS. Android needs a configured Apple
/// Services ID + HTTPS redirect (not set up for this app), so Android is
/// treated as unavailable.
class AppleAuthService {
  /// Bundle / App ID used as Apple JWT `aud` for native Sign in with Apple.
  static const String appClientId = 'eu.golfimprove';

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
        'Confirm Sign in with Apple is enabled for $appClientId in Apple Developer.',
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

      final claims = decodeJwtPayload(identityToken);
      _assertTokenFresh(claims);

      final audience = _audienceFromClaims(claims) ?? appClientId;

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
        clientId: audience,
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

  static Map<String, dynamic>? decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final normalized = base64Url.normalize(parts[1]);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final json = jsonDecode(decoded);
      if (json is Map<String, dynamic>) return json;
      if (json is Map) return Map<String, dynamic>.from(json);
    } catch (_) {}
    return null;
  }

  static String? _audienceFromClaims(Map<String, dynamic>? claims) {
    if (claims == null) return null;
    final aud = claims['aud'];
    if (aud is String && aud.trim().isNotEmpty) return aud.trim();
    if (aud is List && aud.isNotEmpty) {
      final first = aud.first?.toString().trim() ?? '';
      if (first.isNotEmpty) return first;
    }
    return null;
  }

  static void _assertTokenFresh(Map<String, dynamic>? claims) {
    if (claims == null) return;
    final exp = claims['exp'];
    if (exp is! num) return;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (exp.toInt() < nowSec - 30) {
      throw StateError(
        'Apple Sign-In token is already expired. Check that this device\'s '
        'date & time are set automatically, then try again.',
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
    required this.clientId,
    this.email,
    this.fullName,
    this.userIdentifier,
  });

  final String identityToken;
  final String authorizationCode;
  final String clientId;
  final String? email;
  final String? fullName;
  final String? userIdentifier;
}
