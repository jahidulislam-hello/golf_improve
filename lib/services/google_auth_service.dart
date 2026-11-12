import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Native Google Sign-In (google_sign_in 7.x).
///
/// [serverClientId] must be the **Web** OAuth client ID from Firebase
/// (client_type 3 in google-services.json).
/// On iOS, [iosClientId] comes from `GoogleService-Info.plist` → CLIENT_ID.
class GoogleAuthService {
  GoogleAuthService({
    this.serverClientId =
        '198802247100-12ijve9cne7c0rg6ti1hotilrpqh8tpn.apps.googleusercontent.com',
    this.iosClientId =
        '198802247100-rip0n8jf0cfq68riovhjfiardntlr0nh.apps.googleusercontent.com',
  });

  final String serverClientId;
  final String iosClientId;

  /// `GoogleSignIn.instance.initialize` must run exactly once per app run.
  static Future<void>? _initFuture;

  Future<GoogleSignIn> _client() async {
    _initFuture ??= _initialize();
    try {
      await _initFuture;
    } catch (_) {
      _initFuture = null; // allow a retry on the next attempt
      rethrow;
    }
    return GoogleSignIn.instance;
  }

  Future<void> _initialize() {
    return GoogleSignIn.instance.initialize(
      clientId: (!kIsWeb && Platform.isIOS) ? iosClientId : null,
      serverClientId: serverClientId,
    );
  }

  /// Opens the Google account picker and returns the ID token for the API.
  Future<GoogleSignInResult> signIn() async {
    try {
      final client = await _client();

      if (!client.supportsAuthenticate()) {
        throw StateError(
          'Google Sign-In is not available on this platform build. '
          'Use email sign-in, or rebuild the app.',
        );
      }

      // google_sign_in 7.x: call signOut before a fresh interactive authenticate.
      try {
        await client.signOut();
      } catch (_) {}

      final account = await client.authenticate(
        scopeHint: const <String>['email', 'profile'],
      );

      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google did not return an ID token. Check that the Web client ID '
          '(serverClientId) is configured in Firebase / Google Cloud.',
        );
      }

      return GoogleSignInResult(
        idToken: idToken,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
    } on GoogleSignInCanceled {
      rethrow;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const GoogleSignInCanceled();
      }
      final message = e.description ?? '';
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError ||
          message.contains('ApiException: 10') ||
          message.contains('DEVELOPER_ERROR')) {
        throw StateError(
          'Google Sign-In config error. On Android, the app must be signed with '
          'SHA-1 6D:E3:C2:C9:... (upload keystore). On iOS, bundle id must be '
          'eu.golfimprove and match GoogleService-Info.plist.'
          '${message.isNotEmpty ? ' ($message)' : ''}',
        );
      }
      throw StateError(
        message.isNotEmpty ? message : 'Google Sign-In failed (${e.code.name}).',
      );
    } on PlatformException catch (e) {
      if (e.code == 'channel-error') {
        throw StateError(
          'Google Sign-In plugin is not ready. Uninstall the app, then run: '
          'flutter clean && flutter run',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    final client = await _client();
    await client.signOut();
  }
}

class GoogleSignInCanceled implements Exception {
  const GoogleSignInCanceled();
}

class GoogleSignInResult {
  const GoogleSignInResult({
    required this.idToken,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  final String idToken;
  final String email;
  final String? displayName;
  final String? photoUrl;
}
