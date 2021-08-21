import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Services/firebase_auth_service.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/notification_service.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/auth_form.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AuthViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final LoginForm _loginForm = LoginForm();
  NotificationService notificationService;
  var _isUserLogged = StreamController<bool>.broadcast();
  var _isUserCreated = StreamController<bool>.broadcast();
  var _authMessage = StreamController<String>.broadcast();

  LoggedUser loggedUser;

  // Register the listener for the input text field
  AuthViewModel() {
    emailController
        .addListener(() => _loginForm.emailText.add(emailController.text));
    passwordController.addListener(
        () => _loginForm.passwordText.add(passwordController.text));
  }

  void getData() {
    if (emailController.text.isNotEmpty)
      _loginForm.emailText.add(emailController.text);
    if (passwordController.text.isNotEmpty)
      _loginForm.passwordText.add(emailController.text);
  }

  // Check if the user is already logged in
  void isAlreadyLogged() async {
    loggedUser = await _auth.currentUser();
    if (loggedUser != null) {
      setLoggedIn();
    } else
      _isUserCreated.add(false);
  }

  // Create a new user with email and password
  Future createUser(String name, String surname, String birthDate) async {
    try {
      loggedUser = await _auth.createUserWithEmailAndPassword(
          emailController.text,
          passwordController.text,
          name,
          surname,
          birthDate);
      await _auth.sendEmailVerification();
      setLoggedIn();
    } catch (e) {
      _isUserCreated.add(false);
      if (e.code == 'email-already-in-use')
        _authMessage.add('The account already exists.');
      else if (e.code == 'weak-password')
        _authMessage
            .add('The password is too weak.\nIt has to be at least 6 chars.');
    }
  }

  Future createExpert(String name, String surname, DateTime birthDate,
      String phoneNumber, LatLng latLng) async {
    try {
      await _auth.createExpertWithEmailAndPassword(
          emailController.text,
          passwordController.text,
          name,
          surname,
          birthDate,
          latLng.latitude,
          latLng.longitude,
          phoneNumber);
      await _auth.sendEmailVerification();
      _authMessage.add("");
      _isUserCreated.add(true);
    } catch (e) {
      _isUserCreated.add(false);
      if (e.code == 'email-already-in-use')
        _authMessage.add('The account already exists.');
      else if (e.code == 'weak-password')
        _authMessage
            .add('The password is too weak.\nIt has to be at least 6 chars.');
    }
  }

  Future logIn() async {
    try {
      loggedUser = await _auth.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (loggedUser != null)
        setLoggedIn();
      else
        _authMessage.add("The email is not verified");
    } catch (e) {
      _isUserLogged.add(false);
      if (e.code == 'user-not-found' || e.code == 'wrong-password')
        _authMessage.add("Wrong email or password.");
    }
  }

  // Login a user with google. If the user is new, it automatically creates a new account
  Future logInWithGoogle() async {
    try {
      loggedUser = await _auth.signInWithGoogle();
      setLoggedIn();
    } catch (e) {
      _isUserLogged.add(false);
      print(e);
      if (e.code == 'account-exists-with-different-credential')
        _authMessage.add(
            "An account already exists with the same email address but different sign-in credentials.");
    }
  }

  // Login a user with facebook. If the user is new, it automatically creates a new account
  Future logInWithFacebook() async {
    try {
      loggedUser = await _auth.signInWithFacebook();
      setLoggedIn();
    } catch (e) {
      _isUserLogged.add(false);
      if (e.code == 'account-exists-with-different-credential')
        _authMessage.add(
            "An account already exists with the same email address but different sign-in credentials.");
      print(e);
    }
  }

  // Log out a user from the app
  void logOut() async {
    await _auth.signOut();
    loggedUser = null;
    _isUserLogged.add(false);
    clearControllers();
  }

  // Clear the email and password controllers
  void clearControllers() {
    passwordController.clear();
    emailController.clear();
    _loginForm.emailText.add(null);
    _loginForm.passwordText.add(null);
  }

  // Resend the email verification if the user has not received it
  void resendEmailVerification() async {
    await deleteUser();
    await createUser(
        loggedUser.name, loggedUser.surname, loggedUser.dateOfBirth);
  }

  // Set the user logged in and register the notification service for that device
  void setLoggedIn() {
    _authMessage.add("");
    _isUserLogged.add(true);
    notificationService = NotificationService(loggedUser.uid);
    notificationService.registerNotification();
    notificationService.configLocalNotification();
  }

  // Delete a user
  Future<void> deleteUser() async {
    await _auth.deleteUser();
  }

  // Get the current authenticated user
  Future<LoggedUser> getUser() async {
    return await _auth.currentUser();
  }

  Stream<bool> get isUserLogged => _isUserLogged.stream;

  Stream<bool> get isUserCreated => _isUserCreated.stream;

  Stream<String> get authMessage => _authMessage.stream;

  LoginForm getLoginForm() => _loginForm;
}
