import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:quail_order_app/core/constants/app_constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _nativeChannel = MethodChannel(
    'com.quailapp/notifications',
  );

  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (_) {}

    _nativeChannel.setMethodCallHandler((call) async {
      if (call.method == 'showNotification') {
        final args = Map<String, String>.from(call.arguments as Map);
        await showOrderUpdate(
          orderId: args['orderId'] ?? '',
          newStatus: args['newStatus'] ?? '',
        );
      }
    });

    _initialised = true;
  }

  Future<void> showOrderUpdate({
    required String orderId,
    required String newStatus,
  }) async {
    if (orderId.isEmpty) return;

    final shortId = orderId.length >= 6
        ? orderId.substring(0, 6).toUpperCase()
        : orderId;

    await _plugin.show(
      id: orderId.hashCode,
      title: 'Order #$shortId',
      body: 'Status updated to: $newStatus',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannel.channelId,
          NotifChannel.channelName,
          channelDescription: NotifChannel.channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: orderId,
    );
  }

  void _onTap(NotificationResponse response) {
    final orderId = response.payload;
    if (orderId != null && orderId.isNotEmpty) {
      Get.toNamed(Routes.order(orderId));
    }
  }
}
