import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/Services/firebase_auth_service.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/notification_service.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/auth_form.dart';
import 'package:flutter/material.dart';

class AuthViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService auth = FirebaseAuthService();
  final LoginForm loginForm = LoginForm();
  NotificationService notificationService;
  var _isUserLogged = StreamController<bool>.broadcast();
  var _isUserCreated = StreamController<bool>.broadcast();
  var _authMessage = StreamController<String>.broadcast();

  LoggedUser loggedUser;

  AuthViewModel() {
    emailController
        .addListener(() => loginForm.emailText.add(emailController.text));
    passwordController
        .addListener(() => loginForm.passwordText.add(passwordController.text));
  }

  void getData() {
    if (emailController.text.isNotEmpty)
      loginForm.emailText.add(emailController.text);
    if (passwordController.text.isNotEmpty)
      loginForm.passwordText.add(emailController.text);
  }

  void isAlreadyLogged() async {
    loggedUser = await auth.currentUser();
    if (loggedUser != null) {
      setLoggedIn();
    } else
      _isUserCreated.add(false);
  }

  Future createUser(String name, String surname, String birthDate) async {
    try {
      loggedUser = await auth.createUserWithEmailAndPassword(emailController.text,
          passwordController.text, name, surname, birthDate);
      await auth.sendEmailVerification();
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

  Future logIn() async {
    try {
      loggedUser = await auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
      if (loggedUser != null) {
        setLoggedIn();
      } else {
        _authMessage.add("The email is not verified");
      }
    } catch (e) {
      _isUserLogged.add(false);
      if (e.code == 'user-not-found' || e.code == 'wrong-password')
        _authMessage.add("Wrong email or password.");
    }
  }

  Future logInWithGoogle() async {
    try {
      loggedUser = await auth.signInWithGoogle();
      setLoggedIn();
    } catch (e) {
      _isUserLogged.add(false);
      print(e);
      if (e.code == 'account-exists-with-different-credential')
        _authMessage.add(
            "An account already exists with the same email address but different sign-in credentials.");
    }
  }

  Future logInWithFacebook() async {
    try {
      loggedUser = await auth.signInWithFacebook();
      setLoggedIn();
    } catch (e) {
      _isUserLogged.add(false);
      if (e.code == 'account-exists-with-different-credential')
        _authMessage.add(
            "An account already exists with the same email address but different sign-in credentials.");
      print(e);
    }
  }

  void logOut() async {
    await auth.signOut();
    loggedUser = null;
    _isUserLogged.add(false);
    clearControllers();
  }

  void clearControllers() {
    passwordController.clear();
    emailController.clear();
    getLoginForm().emailText.add(null);
    getLoginForm().passwordText.add(null);
  }

  void resendEmailVerification() async {
    await deleteUser();
    await createUser(loggedUser.name, loggedUser.surname, loggedUser.dateOfBirth);
  }

  void setLoggedIn() {
    _authMessage.add("");
    _isUserLogged.add(true);
    notificationService = NotificationService(loggedUser.uid);
    notificationService.registerNotification();
    notificationService.configLocalNotification();
  }

  Future<void> deleteUser() async {
    await auth.deleteUser();
  }

  Future<LoggedUser> getUser() async {
    return await auth.currentUser();
  }

  Stream<bool> get isUserLogged => _isUserLogged.stream;

  Stream<bool> get isUserCreated => _isUserCreated.stream;

  Stream<String> get authMessage => _authMessage.stream;

  LoginForm getLoginForm() => loginForm;
}
