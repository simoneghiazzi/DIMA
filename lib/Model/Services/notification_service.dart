import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Services
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService() {
    // Setup of the firebase messaging service
    _firebaseMessaging.requestPermission();
  }

  /// Returns the default FCM token for this device.
  Future<String?> getDeviceToken() {
    return _firebaseMessaging.getToken();
  }

  /// Configuration of the notification for Android and IOS and register the notification listeners.
  void configNotification() {
    AndroidInitializationSettings initializationSettingsAndroid = new AndroidInitializationSettings("@mipmap/ic_splash");
    IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _registerNotificationListeners();
  }

  /// Register the listeners for new notifications
  void _registerNotificationListeners() {
    // Handle notification messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showNotification(message.notification!);
        FlutterAppBadger.updateBadgeCount(1);
      }
      return;
    });

    // Handle notification open
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      FlutterAppBadger.removeBadge();
    });
  }

  /// Show notification on Android and IOS
  void _showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? "com.dfa.flutterchatdemo" : "com.duytq.flutterchatdemo",
      "sApport",
      channelDescription: "messages notification",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }
}
