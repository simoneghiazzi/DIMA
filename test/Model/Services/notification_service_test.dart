import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mockito/annotations.dart';
import 'package:sApport/Model/Services/notification_service.dart';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import '../../service.mocks.dart';
import 'notification_service_test.mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class MockNotificationSetting extends Mock implements NotificationSettings {}

@GenerateMocks([FirebaseMessaging])
void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();
  final fakeFirebaseMessaging = MockFirebaseMessaging();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<FirebaseAuthService>(MockFirebaseAuthService());

  /// Test Field
  var token = "Fake_token";

  /// Fake Firebase Messaging response
  when(fakeFirebaseMessaging.requestPermission()).thenAnswer((_) => Future.value(MockNotificationSetting()));
  when(fakeFirebaseMessaging.getToken()).thenAnswer((_) => Future.value(token));

  var notificationService = NotificationService(fakeFirebaseMessaging);

  group("Notification service initialization:", () {
    test("Notification service should ask permissions when initialized", () {
      verify(fakeFirebaseMessaging.requestPermission()).called(1);
    });
  });

  group("Get token:", () {
    test("Get token should return the FCM token for the device that the firebase messaging service returns", () async {
      var res = await notificationService.getDeviceToken();

      verify(fakeFirebaseMessaging.getToken()).called(1);
      expect(res, token);
    });
  });

  group("Config notification:", () {
    notificationService.configNotification(testing: true);

    test("Check that confing notification register the on message subscriber to the firebase messaging stream for new notifications", () async {
      expect(notificationService.onMessageSubscriber, isA<StreamSubscription<RemoteMessage>>());
    });

    test("Check that confing notification register the on message opened subscriber to the firebase messaging for opening notification events",
        () async {
      expect(notificationService.onMessageOpenedSubscriber, isA<StreamSubscription<RemoteMessage>>());
    });
  });
}
