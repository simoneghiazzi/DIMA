import 'dart:async';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'firebase_auth_service_test.mocks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as FakeAuth;
import 'package:sApport/Model/Services/firebase_auth_service.dart';

@GenerateMocks([User, UserCredential, FirebaseAuth])
void main() async {
  /// Test Fields
  var email = "luca.colombo@prova.it";
  var password = "password";

  group("FirebaseAuthService tests with fake FirebaseAuth package:", () {
    /// Fake Firebase Auth
    final fakeFirebaseAuth = FakeAuth.MockFirebaseAuth();
    final firebaseAuthService = FirebaseAuthService(fakeFirebaseAuth);

    test("Check that currendUserId is null if no user is signed-in", () async {
      expect(firebaseAuthService.currentUserId, isNull);
    });

    test("Check that the sign in process with the correct email and password sets the current user", () async {
      await firebaseAuthService.signInWithEmailAndPassword(email, password);

      expect(firebaseAuthService.currentUserId, isNotNull);
    });

    test("Check that signOut sets the current user to null", () async {
      firebaseAuthService.signOut();

      expect(firebaseAuthService.currentUserId, isNull);
    });
  });

  group("FirebaseAuthService tests with mock FirebaseAuth:", () {
    /// Mock Firebase Auth
    /// **We need the mock because the package does not provide all the functions to test**
    final mockFirebaseAuth = MockFirebaseAuth();
    final firebaseAuthService = FirebaseAuthService(mockFirebaseAuth);
    final mockUser = MockUser();

    setUp(() {
      clearInteractions(mockUser);

      /// Mock FirebaseAuth responses
      when(mockFirebaseAuth.currentUser).thenAnswer((_) => mockUser);
    });

    group("Creation of a new user:", () {
      /// Mock FirebaseAuth responses
      when(mockFirebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).thenAnswer((_) {
        FutureOr<UserCredential> futureOr = MockUserCredential();
        return Future.value(futureOr);
      });

      test("Check that create a new user with email and password calls the correct FirebaseAuth function with the correct parameters", () async {
        await firebaseAuthService.createUserWithEmailAndPassword(email, password);

        verify(mockFirebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).called(1);
      });

      test("Check that create a new user calls the sendEmailVerification method of the Firebase user", () async {
        await firebaseAuthService.createUserWithEmailAndPassword(email, password);

        verify(mockUser.sendEmailVerification()).called(1);
      });
    });

    group("Deletion of the user:", () {
      test("Check that deleteUser calls the correct FirebaseAuth function", () async {
        await firebaseAuthService.deleteUser();

        verify(mockUser.delete()).called(1);
      });

      test("Check that if an exception occurs in deleting the user it catches the error", () async {
        /// Mock FirebaseAuth exception
        when(mockUser.delete()).thenThrow(FirebaseAuthException(code: "code", message: "test"));

        await firebaseAuthService.deleteUser();
      });
    });

    group("Reset the user password:", () {
      test("Check that resetPassword calls the correct FirebaseAuth function for sending the reset password email", () async {
        firebaseAuthService.resetPassword(email);

        verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
      });

      test("Check that if an exception occurs in sending the reset password email it catches the error", () async {
        /// Mock FirebaseAuth exception
        when(mockFirebaseAuth.sendPasswordResetEmail(email: email)).thenThrow(FirebaseAuthException(code: "code", message: "test"));

        firebaseAuthService.resetPassword(email);
      });
    });

    group("Retrieve the logged-user auth provider:", () {
      test("Check that getAuthProvider returns the correct string", () {
        /// Mock FirebaseAuth responses
        when(mockUser.providerData).thenAnswer((_) => [
              UserInfo({"providerId": "password"})
            ]);

        expect(firebaseAuthService.getAuthProvider(), "password");
      });

      test("Check that getAuthProvider returns null if the user is not logged-in", () {
        /// Mock FirebaseAuth responses
        when(mockFirebaseAuth.currentUser).thenAnswer((_) => null);

        expect(firebaseAuthService.getAuthProvider(), isNull);
      });
    });

    group("Retrieve the sign-in methods of the user:", () {
      test("Check that fetchSignInMethods returns the list of sign in methods associated with the email", () async {
        var list = ["password", "google"];

        /// Mock FirebaseAuth responses
        when(mockFirebaseAuth.fetchSignInMethodsForEmail(email)).thenAnswer((_) => Future.value(list));

        var signInMethods = await firebaseAuthService.fetchSignInMethods(email);

        expect(signInMethods, containsAllInOrder(list));
      });

      test("Check that if an exception occurs when fetching the sign in methods it catches the error and returns null", () async {
        /// Mock FirebaseAuth responses
        when(mockFirebaseAuth.fetchSignInMethodsForEmail(email)).thenThrow(FirebaseAuthException(code: "code", message: "test"));

        var signInMethods = await firebaseAuthService.fetchSignInMethods(email);

        expect(signInMethods, isNull);
      });
    });

    group("Email verified:", () {
      test("Check that isEmailVerified returns true if the user has the password as auth method and the email is verified", () async {
        /// Mock FirebaseAuth responses
        when(mockUser.providerData).thenAnswer((_) => [
              UserInfo({"providerId": "google"}),
              UserInfo({"providerId": "password"})
            ]);
        when(mockFirebaseAuth.currentUser).thenAnswer((_) => FakeAuth.MockUser(isEmailVerified: true));

        expect(firebaseAuthService.isUserEmailVerified(), true);
      });

      test("Check that isEmailVerified returns true if the user does not have the password as auth method", () async {
        /// Mock FirebaseAuth responses
        when(mockUser.providerData).thenAnswer((_) => [
              UserInfo({"providerId": "google"}),
            ]);
        when(mockFirebaseAuth.currentUser).thenAnswer((_) => FakeAuth.MockUser(isEmailVerified: false));

        expect(firebaseAuthService.isUserEmailVerified(), true);
      });

      test("Check that isEmailVerified returns true if the user has the password as auth method and the email is not verified", () async {
        /// Mock FirebaseAuth responses
        when(mockUser.providerData).thenAnswer((_) => [
              UserInfo({"providerId": "google"}),
            ]);
        when(mockFirebaseAuth.currentUser).thenAnswer((_) => FakeAuth.MockUser(isEmailVerified: false));

        expect(firebaseAuthService.isUserEmailVerified(), true);
      });
    });
  });
}
