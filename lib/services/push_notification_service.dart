import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:golf_training_app/services/api_services.dart';
import 'package:golf_training_app/utils/api_constants.dart';

/// Top-level handler required by Firebase for background / terminated messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  developer.log(
    'Background FCM: ${message.messageId} type=${message.data['type']}',
    name: 'PushNotificationService',
  );
}

/// Firebase Cloud Messaging: init, permissions, token, and server sync.
///
/// Backend expects the classic FCM registration token (`fcmToken` on
/// `POST /auth/google` and `PATCH /user/fcm-token`), so we still use the
/// legacy token API rather than the newer FID-only register APIs.
class PushNotificationService {
  PushNotificationService._();

  static bool _initialized = false;
  static ApiService? _api;

  /// Call once from [main] after WidgetsFlutterBinding.
  /// Safe when Firebase is not fully configured yet.
  static Future<void> initialize({ApiService? apiService}) async {
    if (_initialized) return;
    _api = apiService;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      developer.log(
        'Firebase.initializeApp failed: $e',
        name: 'PushNotificationService',
      );
      return;
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _requestPermission(messaging);

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    final initial = await messaging.getInitialMessage();
    if (initial != null) {
      _onMessageOpened(initial);
    }

    // ignore: deprecated_member_use
    messaging.onTokenRefresh.listen((token) {
      unawaited(syncTokenToServer(token));
    });

    _initialized = true;
  }

  static Future<void> _requestPermission(FirebaseMessaging messaging) async {
    if (kIsWeb) return;
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    developer.log(
      'FCM permission: ${settings.authorizationStatus}',
      name: 'PushNotificationService',
    );
  }

  /// Returns the current device FCM token, or null if unavailable.
  static Future<String?> getToken() async {
    if (!_initialized) {
      try {
        await Firebase.initializeApp();
      } catch (_) {
        return null;
      }
    }
    try {
      if (!kIsWeb && Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
      }
      // Backend docs use getToken(); FID from register()/onRegistered is different.
      // ignore: deprecated_member_use
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      developer.log('getToken failed: $e', name: 'PushNotificationService');
      return null;
    }
  }

  /// PATCH /user/fcm-token when the user has a session.
  static Future<void> syncTokenToServer([String? token]) async {
    final api = _api;
    if (api == null) return;
    final access = api.getAccessToken();
    if (access == null || access.isEmpty) return;

    final fcmToken = token ?? await getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    try {
      await api.patch(
        ApiConstants.updateFcmToken,
        body: {'fcmToken': fcmToken},
      );
    } catch (e) {
      developer.log(
        'syncTokenToServer failed: $e',
        name: 'PushNotificationService',
      );
    }
  }

  static void _onForegroundMessage(RemoteMessage message) {
    developer.log(
      'Foreground FCM: ${message.notification?.title} data=${message.data}',
      name: 'PushNotificationService',
    );
  }

  static void _onMessageOpened(RemoteMessage message) {
    developer.log(
      'Opened from FCM: type=${message.data['type']} linkId=${message.data['linkId']}',
      name: 'PushNotificationService',
    );
  }
}
