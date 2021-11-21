import 'package:dima_colombo_ghiazzi/Model/Services/firebase_auth_service.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/notification_service.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/auth_form.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class AuthViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatedPasswordController =
      TextEditingController();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirestoreService firestore = FirestoreService();
  final LoginForm loginForm = LoginForm();
  NotificationService notificationService;
  var isUserLoggedController = StreamController<bool>.broadcast();
  var isUserCreatedController = StreamController<bool>.broadcast();
  var authMessageController = StreamController<String>.broadcast();

  String id;

  /// Register the listener for the input text field
  AuthViewModel() {
    emailController
        .addListener(() => loginForm.emailText.add(emailController.text));
    passwordController
        .addListener(() => loginForm.passwordText.add(passwordController.text));
    repeatedPasswordController.addListener(() =>
        loginForm.repeatedPasswordText.add(repeatedPasswordController.text));
  }

  /// Log the user in with email and password
  Future<String> logIn() async {
    try {
      id = await _firebaseAuthService.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (id != null) {
        authMessageController.add("");
        return id;
      } else
        authMessageController.add("The email is not verified");
    } catch (e) {
      isUserCreatedController.add(false);
      if (e.code == 'user-not-found' || e.code == 'wrong-password')
        authMessageController.add("Wrong email or password.");
    }
    return null;
  }

  /// Login a user with google. If the user is new, it automatically creates a new account
  Future<String> logInWithGoogle() async {
    try {
      id = await _firebaseAuthService.signInWithGoogle();
      authMessageController.add("");
      return id;
    } catch (e) {}
    return null;
  }

  /// Login a user with facebook. If the user is new, it automatically creates a new account
  Future<String> logInWithFacebook() async {
    try {
      id = await _firebaseAuthService.signInWithFacebook();
      authMessageController.add("");
      return id;
    } catch (e) {
      if (e.code == 'account-exists-with-different-credential')
        authMessageController.add(
            "An account already exists with the same email address but different sign-in credentials.");
    }
    return null;
  }

  Future<String> signUpUser(User loggedUser) async {
    try {
      id = await _firebaseAuthService.createUserWithEmailAndPassword(
          emailController.text, passwordController.text, loggedUser);
      await _firebaseAuthService.sendEmailVerification();
      authMessageController.add("");
      isUserCreatedController.add(true);
    } catch (e) {
      isUserCreatedController.add(false);
      if (e.code == 'email-already-in-use')
        authMessageController.add('The account already exists.');
      else if (e.code == 'weak-password')
        authMessageController
            .add('The password is too weak.\nIt has to be at least 6 chars.');
    }
    return id;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuthService.resetPassword(email);
    } catch (e) {}
  }

  String authProvider() {
    return _firebaseAuthService.getAuthProvider();
  }

  /// Get the data text from the controllers
  void getData() {
    if (emailController.text.isNotEmpty)
      loginForm.emailText.add(emailController.text);
    if (passwordController.text.isNotEmpty)
      loginForm.passwordText.add(emailController.text);
  }

  /// Log out a user from the app
  Future<void> logOut() async {
    await _firebaseAuthService.signOut();
    id = '';
    isUserLoggedController.add(false);
    clearControllers();
  }

  /// Clear the email and password controllers and text
  void clearControllers() {
    passwordController.clear();
    repeatedPasswordController.clear();
    emailController.clear();
    authMessageController.add(null);
    loginForm.resetControllers();
  }

  /// Resend the email verification if the user has not received it
  Future<void> resendEmailVerification(User user) async {
    await deleteUser(user);
    await signUpUser(user);
  }

  /// Set the user logged in and register the notification service for that device
  void setNotification(User loggedUser) {
    notificationService = NotificationService(loggedUser);
    notificationService.registerNotification();
    notificationService.configLocalNotification();
  }

  /// Delete a user
  Future<void> deleteUser(User loggedUser) async {
    await _firebaseAuthService.deleteUser(loggedUser);
  }

  Stream<bool> get isUserLogged => isUserLoggedController.stream;

  Stream<bool> get isUserCreated => isUserCreatedController.stream;

  Stream<String> get authMessage => authMessageController.stream;
}
