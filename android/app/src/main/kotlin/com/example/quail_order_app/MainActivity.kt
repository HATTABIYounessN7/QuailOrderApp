package com.example.quail_order_app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // Must match NotifChannel.channelId in app_constants.dart
    private val channelId   = "quail_shop_orders"
    private val channelName = "Order Updates"
    private val channelDesc = "Notifications for order status changes"

    // Must match _nativeChannel in notification_service.dart
    private val methodChannelName = "com.quailapp/notifications"

    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        createNotificationChannel()

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            methodChannelName
        )

        methodChannel?.setMethodCallHandler { call, result ->
            // Future: handle Dart → Kotlin calls here
            result.notImplemented()
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = channelDesc
                enableVibration(true)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    // Call this from a future FCM service to forward a push payload to Dart
    fun notifyDart(orderId: String, newStatus: String) {
        val args = mapOf("orderId" to orderId, "newStatus" to newStatus)
        runOnUiThread {
            methodChannel?.invokeMethod("showNotification", args)
        }
    }
}