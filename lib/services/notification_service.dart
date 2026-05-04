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

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
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

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // Listen for calls coming from Java (future FCM integration)
    _nativeChannel.setMethodCallHandler((call) async {
      if (call.method == 'showNotification') {
        final args = call.arguments as Map;
        await showOrderUpdate(
          orderId: args['orderId'] as String,
          newStatus: args['newStatus'] as String,
        );
      }
    });

    _initialised = true;
  }

  Future<void> showOrderUpdate({
    required String orderId,
    required String newStatus,
  }) async {
    await _plugin.show(
      id: orderId.hashCode,
      title: 'Order #${orderId.substring(0, 6).toUpperCase()}',
      body: 'Status updated: $newStatus',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotifChannel.channelId,
          NotifChannel.channelName,
          channelDescription: NotifChannel.channelDesc,
          importance: Importance.high,
          priority: Priority.high,
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
    // Will navigate to order detail once routing is wired up
    // Get.toNamed(Routes.order(response.payload!));
  }
}
