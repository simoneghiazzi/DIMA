import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/Services/notification_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import '../service.mocks.dart';
import '../test_helper.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirestoreService = MockFirestoreService();
  final mockAuthService = MockFirebaseAuthService();
  final mockNotificationService = MockNotificationService();
  final mockUserService = MockUserService();

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<FirebaseAuthService>(mockAuthService);
  getIt.registerSingleton<NotificationService>(mockNotificationService);
  getIt.registerSingleton<UserService>(mockUserService);

  /// Test Helper
  final testHelper = TestHelper();
  await testHelper.attachDB(fakeFirebase);

  /// Test Fields
  var email = "prova@sApport.it";
  var password = "password";
  var userId = "New_random_id";
  var token = "Fake_token";

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => testHelper.loggedUser);

  /// Mock Notification Service response
  when(mockNotificationService.getDeviceToken()).thenAnswer((_) => Future.value(token));

  final authViewModel = AuthViewModel();

  group("AuthViewModel interaction with services:", () {
    setUp(() async {
      reset(mockFirestoreService);
      reset(mockAuthService);

      /// Mock Auth Service responses
      when(mockAuthService.isUserEmailVerified()).thenAnswer((_) => true);
      when(mockAuthService.currentUserId).thenAnswer((_) => userId);
      when(mockAuthService.signInWithGoogle(any)).thenAnswer((_) => Future.value({
            "name": "Test",
            "surname": "User",
            "email": "test.user@sApport.it",
            "birthDate": DateTime.now(),
          }));
      when(mockAuthService.signInWithFacebook(any)).thenAnswer((_) => Future.value({
            "name": "Test",
            "surname": "User",
            "email": "test.user@sApport.it",
            "birthDate": DateTime.now(),
          }));

      /// Mock Firestore Service responses
      when(mockFirestoreService.getUserByIdFromDB(BaseUser.COLLECTION, userId))
          .thenAnswer((_) => fakeFirebase.collection(BaseUser.COLLECTION).where(FieldPath.documentId, isEqualTo: userId).get());
      await fakeFirebase.collection(BaseUser.COLLECTION).doc(userId).delete();
    });
    group("LogIn:", () {
      test("LogIn should call the signInWithEmailAndPassword method of the authentication service", () async {
        await authViewModel.logIn(email, password);

        verify(mockAuthService.signInWithEmailAndPassword(email, password)).called(1);
      });

      test(
          "LogIn should add an empty message to the auth message controller and add true to the is user logged controller if the logIn process was successful and the email is verified",
          () async {
        expect(authViewModel.authMessage, emits(isEmpty));
        expect(authViewModel.isUserLogged, emits(isTrue));

        await authViewModel.logIn(email, password);
      });

      test("LogIn should add the correct message to the auth message controller if the logIn process was successful but the email is not verified",
          () async {
        /// Mock Auth Service responses
        when(mockAuthService.isUserEmailVerified()).thenAnswer((_) => false);

        String authMessage = "The email is not verified.";
        expect(authViewModel.authMessage, emits(authMessage));

        await authViewModel.logIn(email, password);
      });

      test(
          "Check that if logIn throws a user-not-found FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "Wrong email or password.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithEmailAndPassword(email, password))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "user-not-found")));

        await authViewModel.logIn(email, password);
      });

      test(
          "Check that if logIn throws a wrong-password FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "Wrong email or password.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithEmailAndPassword(email, password))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "user-not-found")));

        await authViewModel.logIn(email, password);
      });

      test(
          "Check that if logIn throws a generic FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "Error in signing in the user. Please try again later.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithEmailAndPassword(email, password))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "generic-exception")));

        await authViewModel.logIn(email, password);
      });
    });

    group("SignUp user:", () {
      test("SignUp user should call the createUserWithEmailAndPassword method of the authentication service", () async {
        await authViewModel.signUpUser(email, password, testHelper.loggedUser);

        verify(mockAuthService.createUserWithEmailAndPassword(email, password)).called(1);
      });

      test("SignUp should call the sendEmailVerification method of the auth service if the signUp process was successful", () async {
        await authViewModel.signUpUser(email, password, testHelper.loggedUser);

        verify(mockAuthService.sendVerificationEmail()).called(1);
      });

      test(
          "SignUp should set the new ID retrieved from the firebase auth to the new user if the signUp process was successful and the email is correctly sent",
          () async {
        var newUser = BaseUser(name: "New User", surname: "Test", email: "l.t@sApport.it", birthDate: DateTime(2022, 1, 13));

        await authViewModel.signUpUser(email, password, newUser);

        expect(newUser.id, userId);
      });

      test("SignUp should call the addUserIntoDB if the signUp process was successful and the email is correctly sent", () async {
        var newUser = BaseUser(name: "New User", surname: "Test", email: "l.t@sApport.it", birthDate: DateTime(2022, 1, 13));

        await authViewModel.signUpUser(email, password, newUser);

        verify(mockFirestoreService.addUserIntoDB(newUser)).called(1);
      });

      test(
          "SignUp should add an empty message to the auth message controller and add true to the is user created controller if all the signUp process was successful",
          () async {
        expect(authViewModel.authMessage, emits(isEmpty));
        expect(authViewModel.isUserCreated, emits(isTrue));

        await authViewModel.signUpUser(email, password, testHelper.loggedUser);
      });

      test(
          "Check that if signUp throws a email-already-in-use FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "An account associated with this email already exists.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.createUserWithEmailAndPassword(email, password))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "email-already-in-use")));

        await authViewModel.signUpUser(email, password, testHelper.loggedUser);
      });

      test(
          "Check that if signUp throws a generic FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "Error in signing up the user. Please try again later.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.createUserWithEmailAndPassword(email, password))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "generic-exception")));

        await authViewModel.signUpUser(email, password, testHelper.loggedUser);
      });

      test(
          "Check that if sendEmailVerification throws an exception it adds the correct message to the auth message controller and calls the delete user method of the firebase auth service",
          () async {
        String authMessage = "Error in signing up the user. Please try again later.";

        /// Mock FirebaseAuth Exception
        when(mockAuthService.sendVerificationEmail()).thenAnswer((_) => Future.error(Exception));

        expect(authViewModel.authMessage, emits(authMessage));

        await authViewModel.signUpUser(email, password, testHelper.loggedUser);

        verify(mockAuthService.deleteUser()).called(1);
      });

      test(
          "Check that if addUserIntoDB throws an exception it adds the correct message to the auth message controller and calls the delete user method of the firebase auth service",
          () async {
        var newUser = BaseUser(name: "New User", surname: "Test", email: "l.t@sApport.it", birthDate: DateTime(2022, 1, 13));
        String authMessage = "Error in signing up the user. Please try again later.";

        /// Mock FirebaseAuth Exception
        when(mockFirestoreService.addUserIntoDB(newUser)).thenAnswer((_) => Future.error(Exception));

        expect(authViewModel.authMessage, emits(authMessage));

        await authViewModel.signUpUser(email, password, newUser);

        verify(mockAuthService.deleteUser()).called(1);
      });
    });

    group("LogIn with Google:", () {
      test("LogIn with Google should call the signInWithGoogle method of the authentication service", () async {
        await authViewModel.logInWithGoogle();

        verify(mockAuthService.signInWithGoogle(any)).called(1);
      });

      test(
          "LogIn with Google should call the add user method of the firestore service if link is false and the user does not already exists into the DB",
          () async {
        await authViewModel.logInWithGoogle();

        verify(mockFirestoreService.getUserByIdFromDB(BaseUser.COLLECTION, userId)).called(1);
        verify(mockFirestoreService.addUserIntoDB(any)).called(1);
      });

      test("LogIn with Google should not call the add user method of the firestore service if link is true", () async {
        await authViewModel.logInWithGoogle(link: true);

        verifyNever(mockFirestoreService.addUserIntoDB(any));
      });

      test("LogIn with Google should not call the add user method of the firestore service if the user already exists into the DB", () async {
        /// Mock Firestore Service responses with a user that already exists into the DB
        when(mockFirestoreService.getUserByIdFromDB(BaseUser.COLLECTION, userId))
            .thenAnswer((_) => fakeFirebase.collection(BaseUser.COLLECTION).where(FieldPath.documentId, isEqualTo: testHelper.baseUser2.id).get());

        await authViewModel.logInWithGoogle();

        verifyNever(mockFirestoreService.addUserIntoDB(any));
      });

      test(
          "Check that if signInWithGoogle throws a account-exists-with-different-credential FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "An account already exists with the same email address but different sign-in credentials.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithGoogle(any))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "account-exists-with-different-credential")));

        await authViewModel.logInWithGoogle();
      });

      test(
          "Check that if signInWithGoogle throws a email-already-in-use FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "This social account is already linked with another profile or the email is already registered.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithGoogle(any)).thenAnswer((_) => Future.error(FirebaseAuthException(code: "email-already-in-use")));

        await authViewModel.logInWithGoogle();
      });

      test(
          "Check that if signInWithGoogle throws a credential-already-in-use FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "This social account is already linked with another profile or the email is already registered.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithGoogle(any)).thenAnswer((_) => Future.error(FirebaseAuthException(code: "credential-already-in-use")));

        await authViewModel.logInWithGoogle();
      });

      test("Check that if a generic exception is thrown it catches the error and adds the correct message to the auth message controller", () async {
        String authMessage = "Error in signing in with the Google account. Please try again later.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithGoogle(any)).thenAnswer((_) => Future.error(Error()));

        await authViewModel.logInWithGoogle();
      });

      test(
          "LogIn with Google should add an empty message to the auth message controller and add true to the is user logged controller if the logIn with Google process was successful",
          () async {
        expect(authViewModel.authMessage, emits(isEmpty));
        expect(authViewModel.isUserLogged, emits(isTrue));

        await authViewModel.logInWithGoogle();
      });
    });

    group("LogIn with Facebook:", () {
      test("LogIn with Facebook should call the signInWithFacebook method of the authentication service", () async {
        await authViewModel.logInWithFacebook();

        verify(mockAuthService.signInWithFacebook(any)).called(1);
      });

      test(
          "LogIn with Facebook should call the add user method of the firestore service if link is false and the user does not already exists into the DB",
          () async {
        await authViewModel.logInWithFacebook();

        verify(mockFirestoreService.getUserByIdFromDB(BaseUser.COLLECTION, userId)).called(1);
        verify(mockFirestoreService.addUserIntoDB(any)).called(1);
      });

      test("LogIn with Facebook should not call the add user method of the firestore service if link is true", () async {
        await authViewModel.logInWithFacebook(link: true);

        verifyNever(mockFirestoreService.addUserIntoDB(any));
      });

      test("LogIn with Facebook should not call the add user method of the firestore service if the user already exists into the DB", () async {
        /// Mock Firestore Service responses with a user that already exists into the DB
        when(mockFirestoreService.getUserByIdFromDB(BaseUser.COLLECTION, userId))
            .thenAnswer((_) => fakeFirebase.collection(BaseUser.COLLECTION).where(FieldPath.documentId, isEqualTo: testHelper.baseUser2.id).get());

        await authViewModel.logInWithFacebook();

        verifyNever(mockFirestoreService.addUserIntoDB(any));
      });

      test(
          "Check that if signInWithFacebook throws a account-exists-with-different-credential FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "An account already exists with the same email address but different sign-in credentials.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithFacebook(any))
            .thenAnswer((_) => Future.error(FirebaseAuthException(code: "account-exists-with-different-credential")));

        await authViewModel.logInWithFacebook();
      });

      test(
          "Check that if signInWithFacebook throws a email-already-in-use FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "This social account is already linked with another profile or the email is already registered.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithFacebook(any)).thenAnswer((_) => Future.error(FirebaseAuthException(code: "email-already-in-use")));

        await authViewModel.logInWithFacebook();
      });

      test(
          "Check that if signInWithFacebook throws a credential-already-in-use FirebaseAuthException it catches the error and adds the correct message to the auth message controller",
          () async {
        String authMessage = "This social account is already linked with another profile or the email is already registered.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithFacebook(any)).thenAnswer((_) => Future.error(FirebaseAuthException(code: "credential-already-in-use")));

        await authViewModel.logInWithFacebook();
      });

      test("Check that if a generic exception is thrown it catches the error and adds the correct message to the auth message controller", () async {
        String authMessage = "Error in signing in with the Facebook account. Please try again later.";

        expect(authViewModel.authMessage, emits(authMessage));

        /// Mock FirebaseAuth Exception
        when(mockAuthService.signInWithFacebook(any)).thenAnswer((_) => Future.error(Error()));

        await authViewModel.logInWithFacebook();
      });

      test(
          "LogIn with Facebook should add an empty message to the auth message controller and add true to the is user logged controller if the logIn with Google process was successful",
          () async {
        expect(authViewModel.authMessage, emits(isEmpty));
        expect(authViewModel.isUserLogged, emits(isTrue));

        await authViewModel.logInWithFacebook();
      });
    });

    group("Reset password:", () {
      test("Reset password should call the reset password method of the authentication service", () async {
        await authViewModel.resetPassword(email);

        verify(mockAuthService.resetPassword(email)).called(1);
      });
    });

    group("Auth provider:", () {
      test("Auth provider should return the authProvider retrived by the auth service if it is not null ", () {
        var provider = "Fake_auth_provider";

        /// Mock Authentication Service response
        when(mockAuthService.getAuthProvider()).thenAnswer((_) => provider);

        expect(authViewModel.authProvider(), provider);
      });

      test("Auth provider should return an empty string if the authProvider retrived by the auth service is null ", () {
        /// Mock Authentication Service response
        when(mockAuthService.getAuthProvider()).thenAnswer((_) => null);

        expect(authViewModel.authProvider(), isEmpty);
      });
    });

    group("Has password authentication:", () {
      test("Has password authentication should return true if the fetch sign in methods of the firebase auth service contains the password",
          () async {
        /// Mock Authentication Service response
        when(mockAuthService.fetchSignInMethods(email)).thenAnswer((_) => Future.value(["google", "password"]));

        var res = await authViewModel.hasPasswordAuthentication(email);

        expect(res, isTrue);
      });

      test("Has password authentication should return false if the fetch sign in methods of the firebase auth service does not contains the password",
          () async {
        /// Mock Authentication Service response
        when(mockAuthService.fetchSignInMethods(email)).thenAnswer((_) => Future.value([]));

        var res = await authViewModel.hasPasswordAuthentication(email);

        expect(res, isFalse);
      });

      test("Has password authentication should return false if the fetch sign in methods of the firebase auth service is null", () async {
        /// Mock Authentication Service response
        when(mockAuthService.fetchSignInMethods(email)).thenAnswer((_) => Future.value(null));

        var res = await authViewModel.hasPasswordAuthentication(email);

        expect(res, isFalse);
      });
    });

    group("Log out:", () {
      test("Log out should call the signOut method of the authentication service", () async {
        await authViewModel.logOut();

        verify(mockAuthService.signOut()).called(1);
      });

      test("Log out should add false to the is user logged controller", () async {
        expect(authViewModel.isUserLogged, emits(isFalse));

        await authViewModel.logOut();
      });
    });

    group("Delete user:", () {
      test("Delete user should call the deleteUser method of the firebase authentication service", () async {
        await authViewModel.deleteUser(testHelper.loggedUser);

        verify(mockAuthService.deleteUser()).called(1);
      });

      test("Delete user should call the removeUser method of the firestore service", () async {
        await authViewModel.deleteUser(testHelper.loggedUser);

        verify(mockFirestoreService.removeUserFromDB(testHelper.loggedUser)).called(1);
      });

      test("Delete user should add false to the is user logged controller ", () async {
        expect(authViewModel.isUserLogged, emits(isFalse));

        await authViewModel.deleteUser(testHelper.loggedUser);
      });
    });

    group("Set notification:", () {
      test("Set notification should call the configNotification method of the notification service", () async {
        await authViewModel.setNotification(testHelper.loggedUser);

        verify(mockNotificationService.configNotification()).called(1);
      });

      test(
          "Set notification should call the getDeviceToken method of the notification service and add call the updateUserField of the firestore service in order to add the token into the DB",
          () async {
        await authViewModel.setNotification(testHelper.loggedUser);

        verify(mockFirestoreService.updateUserFieldIntoDB(testHelper.loggedUser, "pushToken", token)).called(1);
      });
    });

    group("Clear auth message:", () {
      test("Clear auth message should add an empty string to the auth message controller", () {
        expect(authViewModel.authMessage, emits(isEmpty));

        authViewModel.clearAuthMessage();
      });
    });
  });
}
