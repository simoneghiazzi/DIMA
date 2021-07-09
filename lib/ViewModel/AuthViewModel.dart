import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/User.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/FirebaseAuthService.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/AuthForm.dart';
import 'package:flutter/material.dart';

class AuthViewModel {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuthService auth = FirebaseAuthService();
  final LoginForm loginForm = LoginForm();
  var _isUserLogged = StreamController<bool>.broadcast();
  var _isUserCreated = StreamController<bool>.broadcast();
  var _authMessage = StreamController<String>.broadcast();
  //User currentUser;

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

  void alreadyLogged() {
    String uid = auth.currentUser();
    if (uid != null) {
      _isUserLogged.add(true);
    } else
      _isUserLogged.add(false);
  }

  Future createUser() async {
    try {
      String uid = await auth.createUserWithEmailAndPassword(
          emailController.text, passwordController.text);
      await auth.sendEmailVerification();
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
      String uid = await auth.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
      if (uid != null) {
        _isUserLogged.add(true);
        _authMessage.add("");
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
      await auth.signInWithGoogle();
      _isUserLogged.add(true);
      _authMessage.add("");
    } catch (e) {
      _isUserLogged.add(false);
      if (e.code == 'account-exists-with-different-credential')
        _authMessage.add(
            "An account already exists with the same email address but different sign-in credentials.");
      print(e);
    }
  }

  Future logInWithFacebook() async {
    try {
      await auth.signInWithFacebook();
      _isUserLogged.add(true);
      _authMessage.add("");
    } catch (e) {
      _isUserLogged.add(false);
      if (e.code == 'account-exists-with-different-credential')
        _authMessage.add(
            "An account already exists with the same email address but different sign-in credentials.");
      print(e);
    }
  }

  void logOut() {
    auth.signOut();
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
    await createUser();
  }

  Future<void> deleteUser() async {
    await auth.deleteUser();
  }

  Stream<bool> get isUserLogged => _isUserLogged.stream;

  Stream<bool> get isUserCreated => _isUserCreated.stream;

  Stream<String> get authMessage => _authMessage.stream;

  LoginForm getLoginForm() => loginForm;
}
