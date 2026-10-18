package com.golfimprove.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterFragmentActivity

/// FragmentActivity host required for Google Sign-In on Android.
class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createDefaultPushChannel()
    }

    /// Matches `com.google.firebase.messaging.default_notification_channel_id`
    /// in AndroidManifest so FCM alerts show on Android 8+.
    private fun createDefaultPushChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "golfimprove_default",
            "GolfImprove",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply {
            description = "Swing feedback, coach messages, and app alerts"
            enableVibration(true)
        }
        val manager = getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(channel)
    }
}
