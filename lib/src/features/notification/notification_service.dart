import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationService {
  final Dio _dio;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this._dio);

  Future<void> initialize() async {
    try {
      // Request Permission
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else {
        print('User declined or has not accepted permission');
        // Even if declined, we proceed initialization to avoid errors
      }

      // Initialize Local Notifications
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(initSettings);

      // Get Token
      final token = await _fcm.getToken();
      if (token != null) {
        print('FCM Token: $token');
        _sendTokenToBackend(token);
      }

      _fcm.onTokenRefresh.listen(_sendTokenToBackend);

      // Foreground Message Handler
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                'high_importance_channel',
                'High Importance Notifications',
                channelDescription:
                    'This channel is used for important notifications.',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: const DarwinNotificationDetails(),
            ),
          );
        }
      });
    } catch (e) {
      print("NotificationService init error: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      // Wait for auth? DioProvider gets token from storage.
      // We might need to handle this only if logged in.
      // But typically dio interceptor attaches token if available.
      await _dio.put('/user/fcm-token', data: {'token': token});
    } catch (e) {
      print('Failed to send FCM token: $e');
    }
  }
}
