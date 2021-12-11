import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Services/notification_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/ViewModel/Forms/auth_form.dart';

class AuthViewModel {
  // Services
  final FirebaseAuthService _firebaseAuthService = GetIt.I();
  NotificationService notificationService;

  // Login Form
  final LoginForm loginForm = LoginForm();

  // Text Controllers
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController pswCtrl = TextEditingController();
  final TextEditingController repeatPswCtrl = TextEditingController();

  // Stream Controllers
  var _isUserLoggedCtrl = StreamController<bool>.broadcast();
  var _isUserCreatedCtrl = StreamController<bool>.broadcast();
  var _authMessageCtrl = StreamController<String>.broadcast();

  AuthViewModel() {
    // Register the listeners for the input text field
    emailCtrl.addListener(() => loginForm.email.add(emailCtrl.text));
    pswCtrl.addListener(() => loginForm.psw.add(pswCtrl.text));
    repeatPswCtrl.addListener(() => loginForm.repeatPsw.add(repeatPswCtrl.text));
  }

  /// Log the user in with email and password.
  ///
  /// It adds the result of the login process to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logIn() async {
    try {
      await _firebaseAuthService.signInWithEmailAndPassword(emailCtrl.text, pswCtrl.text);
      if (_firebaseAuthService.firebaseUser != null) {
        _authMessageCtrl.add("");
        _isUserLoggedCtrl.add(true);
      } else {
        _authMessageCtrl.add("The email is not verified");
        _isUserLoggedCtrl.add(false);
      }
    } catch (e) {
      if (e.code == "user-not-found" || e.code == "wrong-password") {
        _authMessageCtrl.add("Wrong email or password");
      } else {
        _authMessageCtrl.add("Error in signing in the user. Please try again later.");
        print("Error in signing in with email and password.");
      }
      _isUserLoggedCtrl.add(false);
    }
  }

  /// Sign up a [newUser] with email and password.
  ///
  /// It adds the result of the signup process to the [isUserCreated] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> signUpUser(User newUser) async {
    try {
      await _firebaseAuthService.createUserWithEmailAndPassword(emailCtrl.text, pswCtrl.text, newUser);
      _firebaseAuthService.sendEmailVerification();
      _authMessageCtrl.add("");
      _isUserCreatedCtrl.add(true);
    } catch (e) {
      if (e.code == "email-already-in-use") {
        _authMessageCtrl.add("The account already exists.");
      } else if (e.code == "weak-password") {
        _authMessageCtrl.add("The password is too weak.\nIt has to be at least 6 chars.");
      } else {
        _authMessageCtrl.add("Error in signing up the user. Please try again later.");
        print("Error in signing up the user.");
      }
      _isUserCreatedCtrl.add(false);
    }
  }

  /// Login a user with Google. If the user is new, it automatically creates a new account.
  /// If [link] is true, it links the Google account credential to the already logged user.
  ///
  /// It adds the result of the login process to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logInWithGoogle({bool link = false}) async {
    try {
      await _firebaseAuthService.signInWithGoogle(link);
      _authMessageCtrl.add("");
      _isUserLoggedCtrl.add(true);
    } catch (e) {
      if (e.code == "account-exists-with-different-credential") {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      } else {
        _authMessageCtrl.add("Error in signing in with the Google account. Please try again later.");
        print("Error in signing in with the Google account");
      }
      _isUserLoggedCtrl.add(false);
    }
  }

  /// Login a user with Facebook. If the user is new, it automatically creates a new account.
  /// If [link] is true, it links the Facebook account credential to the already logged user.
  ///
  /// It adds the result of the login process to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logInWithFacebook({bool link = false}) async {
    try {
      await _firebaseAuthService.signInWithFacebook(link);
      _authMessageCtrl.add("");
      _isUserLoggedCtrl.add(true);
    } catch (e) {
      if (e.code == "account-exists-with-different-credential") {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      } else {
        _authMessageCtrl.add("Error in signing in with the Facebook account. Please try again later.");
        print("Error in signing in with the Facebook account");
      }
      _isUserLoggedCtrl.add(false);
    }
  }

  /// Send to the user [email] the link for the password reset
  void resetPassword(String email) {
    _firebaseAuthService.resetPassword(email);
  }

  /// Get the authentication provider of the current logged user
  String authProvider() {
    return _firebaseAuthService.getAuthProvider();
  }

  /// Returns `true` if the user associated with the [email] has the password as authentication provider
  Future<bool> hasPasswordAuthentication(String email) async {
    var list = await _firebaseAuthService.fetchSignInMethods(email);
    if (list.contains("password")) {
      return true;
    }
    return false;
  }

  /// Get the data from the text controllers and add them to the login form sinks
  void getData() {
    if (emailCtrl.text.isNotEmpty) {
      loginForm.email.add(emailCtrl.text);
    }
    if (pswCtrl.text.isNotEmpty) {
      loginForm.psw.add(emailCtrl.text);
    }
  }

  /// Log out the user from the app, updates the [isUserLogged] stream controller and call [clearControllers].
  Future<void> logOut() async {
    await _firebaseAuthService.signOut();
    _isUserLoggedCtrl.add(false);
    clearControllers();
  }

  /// Clear all the text and stream controllers and reset the login form
  void clearControllers() {
    emailCtrl.clear();
    pswCtrl.clear();
    repeatPswCtrl.clear();
    _authMessageCtrl.add(null);
    loginForm.resetControllers();
  }

  /// Register the notification service for the device of the [loggedUser]
  void setNotification(User loggedUser) {
    notificationService = NotificationService(loggedUser);
    notificationService.registerNotification();
    notificationService.configLocalNotification();
  }

  /// Delete the [loggedUser] account
  Future<void> deleteUser(User loggedUser) async {
    await _firebaseAuthService.deleteUser(loggedUser);
  }

  /// Stream of the user logged controller
  Stream<bool> get isUserLogged => _isUserLoggedCtrl.stream;

  /// Stream of the user created controller
  Stream<bool> get isUserCreated => _isUserCreatedCtrl.stream;

  /// Stream of the authentication message controller
  Stream<String> get authMessage => _authMessageCtrl.stream;
}
