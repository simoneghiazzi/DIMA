import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:test/test.dart';

void main() async {
  /// Fake Firebase Auth
  final fakeFirebaseAuth = MockFirebaseAuth();
  final firebaseAuthService = FirebaseAuthService(fakeFirebaseAuth);

  /// Test Fields
  var email = "luca.colombo@prova.it";
  var password = "password";

  group("FirebaseAuth psw-email authentication", () {
    test("Sign in a user with email and password and set the current user", () async {
      await firebaseAuthService.signInWithEmailAndPassword(email, password);

      expect(firebaseAuthService.currentUserId, isNotNull);
    });
  });
}
