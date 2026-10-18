import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Native Google Sign-In (google_sign_in 6.x — matches backend docs).
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

  GoogleSignIn get _client => GoogleSignIn(
        clientId: (!kIsWeb && Platform.isIOS) ? iosClientId : null,
        serverClientId: serverClientId,
        scopes: const <String>['email', 'profile'],
      );

  /// Opens the Google account picker and returns the ID token for the API.
  Future<GoogleSignInResult> signIn() async {
    try {
      final account = await _client.signIn();
      if (account == null) {
        throw const GoogleSignInCanceled();
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
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
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled' || e.code == 'canceled') {
        throw const GoogleSignInCanceled();
      }
      if (e.code == 'channel-error') {
        throw StateError(
          'Google Sign-In plugin is not ready. Uninstall the app, then run: '
          'flutter clean && flutter run',
        );
      }
      // ApiException: 10 = DEVELOPER_ERROR (package name / SHA-1 mismatch)
      final message = e.message ?? '';
      if (message.contains('ApiException: 10') ||
          message.contains('DEVELOPER_ERROR') ||
          e.code == '10') {
        throw StateError(
          'Google Sign-In config error (ApiException 10). In Firebase → '
          'Project settings → Your apps → com.golfimprove.app, add BOTH SHA-1s: '
          'Debug D0:BB:F6:61:D5:12:08:7C:FA:71:19:AE:9D:C5:36:05:F1:74:6F:51  '
          'Release 6D:E3:C2:C9:B6:E5:F1:30:14:88:59:22:81:30:76:5F:20:43:63:07  '
          'Then re-download google-services.json and wait a few minutes.',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.signOut();
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
