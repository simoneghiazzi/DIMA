import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/ViewModel/Forms/auth_form.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/notification_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class AuthViewModel {
  // Services
  final FirebaseAuthService _firebaseAuthService = GetIt.I();
  final FirestoreService _firestoreService = GetIt.I();
  final NotificationService _notificationService = NotificationService();

  // Text Controllers
  final TextEditingController emailTextCtrl = TextEditingController();
  final TextEditingController pswTextCtrl = TextEditingController();
  final TextEditingController repeatPswTextCtrl = TextEditingController();

  // Stream Controllers
  var _isUserLoggedCtrl = StreamController<bool>.broadcast();
  var _isUserCreatedCtrl = StreamController<bool>.broadcast();
  var _authMessageCtrl = StreamController<String>.broadcast();

  // Login Form
  final LoginForm loginForm = LoginForm();

  AuthViewModel() {
    // Register the listeners for the input text field
    emailTextCtrl.addListener(() => loginForm.email.add(emailTextCtrl.text));
    pswTextCtrl.addListener(() => loginForm.psw.add(pswTextCtrl.text));
    repeatPswTextCtrl.addListener(() => loginForm.repeatPsw.add(repeatPswTextCtrl.text));
  }

  /// Log the user in with email and password.
  ///
  /// If the login process is successful, it adds the value to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logIn() async {
    try {
      await _firebaseAuthService.signInWithEmailAndPassword(emailTextCtrl.text, pswTextCtrl.text);
      if (_firebaseAuthService.isUserEmailVerified()) {
        _authMessageCtrl.add("");
        _isUserLoggedCtrl.add(true);
      } else {
        _authMessageCtrl.add("The email is not verified.");
      }
    } catch (error) {
      if (error.code == "user-not-found" || error.code == "wrong-password") {
        _authMessageCtrl.add("Wrong email or password.");
      } else {
        _authMessageCtrl.add("Error in signing in the user. Please try again later.");
        print("Error in signing in with email and password.");
      }
    }
  }

  /// Sign up a [newUser] with email and password and add the user into the Firebase DB.
  ///
  /// It adds the result of the signup process to the [isUserCreated] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> signUpUser(User newUser) async {
    try {
      await _firebaseAuthService.createUserWithEmailAndPassword(emailTextCtrl.text, pswTextCtrl.text);
      newUser.id = _firebaseAuthService.firebaseUser.uid;
      _firestoreService.addUserIntoDB(newUser);
      _authMessageCtrl.add("");
      _isUserCreatedCtrl.add(true);
    } catch (error) {
      if (error.code == "email-already-in-use") {
        _authMessageCtrl.add("An account associated with this email already exists.");
      } else if (error.code == "weak-password") {
        _authMessageCtrl.add("The password is too weak.\nIt has to be at least 6 chars.");
      } else {
        _authMessageCtrl.add("Error in signing up the user. Please try again later.");
        print("Error in signing up the user.");
      }
    }
  }

  /// Login a user with Google. If the user is new, it automatically creates a new account
  /// and adds the user into the Firebase DB.
  ///
  /// If [link] is true, it links the Google account credential to the already logged user.
  ///
  /// If the login process is successful, it adds the value to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logInWithGoogle({bool link = false}) async {
    try {
      var userData = await _firebaseAuthService.signInWithGoogle(link);
      _authMessageCtrl.add("");
      if (!link) {
        _firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, _firebaseAuthService.firebaseUser.uid).then((userSnap) {
          // Check if it is a new user. If yes, insert the data into the DB
          if (userSnap.docs.isEmpty) {
            _firestoreService.addUserIntoDB(BaseUser(
                id: _firebaseAuthService.firebaseUser.uid,
                name: userData["name"],
                surname: userData["surname"],
                birthDate: userData["birthDate"],
                email: userData["email"]));
          }
          _isUserLoggedCtrl.add(true);
        });
      }
    } catch (error) {
      if (error.code == "account-exists-with-different-credential") {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      } else if (error.code == "email-already-in-use" || error.code == "credential-already-in-use") {
        _authMessageCtrl.add("This social account is already linked with another profile or the email is already registered.");
      } else {
        _authMessageCtrl.add("Error in signing in with the Google account. Please try again later.");
        print("Error in signing in with the Google account");
      }
    }
  }

  /// Login a user with Facebook. If the user is new, it automatically creates a new account
  /// and adds the user into the Firebase DB.
  ///
  /// If [link] is true, it links the Facebook account credential to the already logged user.
  ///
  /// If the login process is successful, it adds the value to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logInWithFacebook({bool link = false}) async {
    try {
      var userData = await _firebaseAuthService.signInWithFacebook(link);
      _authMessageCtrl.add("");
      if (!link) {
        _firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, _firebaseAuthService.firebaseUser.uid).then((userSnap) {
          // Check if it is a new user. If yes, insert the data into the DB
          if (userSnap.docs.isEmpty) {
            _firestoreService.addUserIntoDB(BaseUser(
                id: _firebaseAuthService.firebaseUser.uid,
                name: userData["name"],
                surname: userData["surname"],
                birthDate: userData["birthDate"],
                email: userData["email"]));
          }
          _isUserLoggedCtrl.add(true);
        });
      }
    } catch (error) {
      if (error.code == "account-exists-with-different-credential") {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      } else if (error.code == "email-already-in-use" || error.code == "credential-already-in-use") {
        _authMessageCtrl.add("This social account is already linked with another profile or the email is already registered.");
      } else {
        _authMessageCtrl.add("Error in signing in with the Facebook account. Please try again later.");
        print("Error in signing in with the Facebook account");
      }
    }
  }

  /// Send to the user [email] the link for the password reset.
  void resetPassword(String email) {
    _firebaseAuthService.resetPassword(email);
  }

  /// Get the authentication provider of the current logged user.
  String authProvider() {
    return _firebaseAuthService.getAuthProvider();
  }

  /// Returns `true` if the user associated with the [email] has the password as authentication provider.
  Future<bool> hasPasswordAuthentication(String email) async {
    var list = await _firebaseAuthService.fetchSignInMethods(email);
    if (list.contains("password")) {
      return true;
    }
    return false;
  }

  /// Get the data from the text controllers and add them to the login form sinks.
  void getData() {
    if (emailTextCtrl.text.isNotEmpty) {
      loginForm.email.add(emailTextCtrl.text);
    }
    if (pswTextCtrl.text.isNotEmpty) {
      loginForm.psw.add(emailTextCtrl.text);
    }
  }

  /// Log out the user from the app, updates the [isUserLogged] stream controller and call [clearControllers].
  Future<void> logOut() async {
    await _firebaseAuthService.signOut();
    _isUserLoggedCtrl.add(false);
    clearControllers();
  }

  /// Clear all the text and stream controllers and reset the login form.
  void clearControllers() {
    emailTextCtrl.clear();
    pswTextCtrl.clear();
    repeatPswTextCtrl.clear();
    _authMessageCtrl.add(null);
    loginForm.resetControllers();
  }

  /// Register the notification service for the device of the [loggedUser].
  void setNotification(User loggedUser) {
    _notificationService.configNotification();
    _notificationService.getDeviceToken().then((token) {
      _firestoreService.updateUserFieldIntoDB(loggedUser, "pushToken", token);
    }).catchError((e) => print("Error in getting the device token: $e"));
  }

  /// Delete the [loggedUser] account both from the authentication FirebaseService and from the Firebase DB
  /// and updates the [isUserLogged] stream controller.
  Future<void> deleteUser(User loggedUser) async {
    _firebaseAuthService.deleteUser();
    _firestoreService.removeUserFromDB(loggedUser);
    _isUserLoggedCtrl.add(false);
  }

  /// Stream of the user logged controller.
  Stream<bool> get isUserLogged => _isUserLoggedCtrl.stream;

  /// Stream of the user created controller.
  Stream<bool> get isUserCreated => _isUserCreatedCtrl.stream;

  /// Stream of the authentication message controller.
  Stream<String> get authMessage => _authMessageCtrl.stream;
}
