import 'dart:io';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  User user;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();

  NotificationService(this.user);

  /// Register the token of the specific user phone and listen for new notification to show
  void registerNotification() {
    _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      if (message.notification != null) {
        showNotification(message.notification);
        FlutterAppBadger.updateBadgeCount(1);
      }
      return;
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('opened');
      FlutterAppBadger.removeBadge();
    });

    _firebaseMessaging.getToken().then((token) async {
      print('token: $token');
      await _firestoreService.updateUserFieldIntoDB(user, 'pushToken', token);
    }).catchError((err) {
      print(err);
    });
  }

  /// Show notification on Android and IOS
  void showNotification(RemoteNotification remoteNotification) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.dfa.flutterchatdemo'
          : 'com.duytq.flutterchatdemo',
      'sApport',
      channelDescription: 'messages notification',
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );
    IOSNotificationDetails iOSPlatformChannelSpecifics =
        IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      remoteNotification.title,
      remoteNotification.body,
      platformChannelSpecifics,
      payload: null,
    );
  }

  // Configuration of local notification for Android and IOS
  void configLocalNotification() {
    AndroidInitializationSettings initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings();
    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
}
