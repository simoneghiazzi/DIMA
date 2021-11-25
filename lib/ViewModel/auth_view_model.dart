import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/ViewModel/ObserverForms/auth_form.dart';
import 'package:sApport/Model/Services/notification_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class AuthViewModel {
  // Text Controllers
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController pswCtrl = TextEditingController();
  final TextEditingController repeatPswCtrl = TextEditingController();

  // Stream Controllers
  var _isUserLoggedCtrl = StreamController<bool>.broadcast();
  var _isUserCreatedCtrl = StreamController<bool>.broadcast();
  var _authMessageCtrl = StreamController<String>.broadcast();

  // Login Form
  final LoginForm loginForm = LoginForm();

  // Services
  final FirebaseAuthService _firebaseAuthService = GetIt.I();
  final FirestoreService firestore = GetIt.I();
  NotificationService notificationService;

  // Logged User id
  String loggedId;

  /// Register the listeners for the input text field
  AuthViewModel() {
    emailCtrl.addListener(() => loginForm.email.add(emailCtrl.text));
    pswCtrl.addListener(() => loginForm.psw.add(pswCtrl.text));
    repeatPswCtrl.addListener(() => loginForm.repeatPsw.add(repeatPswCtrl.text));
  }

  /// Log the user in with email and password
  Future<String> logIn() async {
    try {
      loggedId = await _firebaseAuthService.signInWithEmailAndPassword(emailCtrl.text, pswCtrl.text);
      if (loggedId.isEmpty) {
        _authMessageCtrl.add("The email is not verified");
      } else {
        _authMessageCtrl.add("");
      }
    } catch (e) {
      _isUserCreatedCtrl.add(false);
      if (e.code == "user-not-found" || e.code == "wrong-password") {
        _authMessageCtrl.add("Wrong email or password");
      }
    }
    return loggedId;
  }

  /// Sign up a [newUser] with email and password
  Future<String> signUpUser(User newUser) async {
    try {
      loggedId = await _firebaseAuthService.createUserWithEmailAndPassword(emailCtrl.text, pswCtrl.text, newUser);
      _firebaseAuthService.sendEmailVerification();
      _authMessageCtrl.add("");
      _isUserCreatedCtrl.add(true);
    } catch (e) {
      _isUserCreatedCtrl.add(false);
      if (e.code == 'email-already-in-use') {
        _authMessageCtrl.add('The account already exists.');
      } else if (e.code == 'weak-password') {
        _authMessageCtrl.add('The password is too weak.\nIt has to be at least 6 chars.');
      }
    }
    return loggedId;
  }

  /// Login a user with Google. If the user is new, it automatically creates a new account.
  ///
  /// If [link] is true, it links the Google account credentials to the already logged user.
  Future<String> logInWithGoogle({bool link = false}) async {
    try {
      loggedId = await _firebaseAuthService.signInWithGoogle(link);
      if (loggedId.isEmpty) {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      }
      _authMessageCtrl.add("");
    } catch (e) {
      print("Error in signing in with Google");
    }
    return loggedId;
  }

  /// Login a user with Facebook. If the user is new, it automatically creates a new account
  ///
  /// If [link] is true, it links the Facebook account credentials to the already logged user.
  Future<String> logInWithFacebook({bool link = false}) async {
    try {
      loggedId = await _firebaseAuthService.signInWithFacebook(link);
      _authMessageCtrl.add("");
    } catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      }
    }
    return loggedId;
  }

  /// Send to the user [email] the link for the password reset
  void resetPassword(String email) {
    _firebaseAuthService.resetPassword(email);
  }

  /// Get the authentication provider of the current logged user
  String authProvider() {
    return _firebaseAuthService.getAuthProvider();
  }

  /// Return true if the user associated with the [email] has the password as authentication provider
  Future<bool> hasPasswordAuthentication(String email) async {
    var list = await _firebaseAuthService.fetchSignInMethods(email);
    if (list.contains("password")) {
      return true;
    }
    return false;
  }

  /// Get the data text from the controllers
  void getData() {
    if (emailCtrl.text.isNotEmpty) {
      loginForm.email.add(emailCtrl.text);
    }
    if (pswCtrl.text.isNotEmpty) {
      loginForm.psw.add(emailCtrl.text);
    }
  }

  /// Log out the user from the app
  Future<void> logOut() async {
    await _firebaseAuthService.signOut();
    loggedId = '';
    _isUserLoggedCtrl.add(false);
    clearControllers();
  }

  /// Clear all the text and stream controllers and reset the login form
  void clearControllers() {
    pswCtrl.clear();
    repeatPswCtrl.clear();
    emailCtrl.clear();
    _authMessageCtrl.add(null);
    loginForm.resetControllers();
  }

  /// Resend the email verification to the [user]
  Future<void> resendEmailVerification(User user) async {
    await deleteUser(user);
    await signUpUser(user);
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
