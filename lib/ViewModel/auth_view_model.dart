import 'dart:async';
import 'dart:developer';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/notification_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class AuthViewModel {
  // Services
  final FirebaseAuthService _firebaseAuthService = GetIt.I();
  final FirestoreService _firestoreService = GetIt.I();
  final NotificationService _notificationService = NotificationService();

  // Stream Controllers
  var _isUserLoggedCtrl = StreamController<bool>.broadcast();
  var _isUserCreatedCtrl = StreamController<bool>.broadcast();
  var _authMessageCtrl = StreamController<String?>.broadcast();

  /// Log the user in with email and password.
  ///
  /// If the login process is successful, it adds the value to the [isUserLogged] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> logIn(String email, String password) async {
    try {
      await _firebaseAuthService.signInWithEmailAndPassword(email, password);
      if (_firebaseAuthService.isUserEmailVerified()) {
        _authMessageCtrl.add("");
        _isUserLoggedCtrl.add(true);
      } else {
        _authMessageCtrl.add("The email is not verified.");
      }
    } on Firebase.FirebaseAuthException catch (error) {
      if (error.code == "user-not-found" || error.code == "wrong-password") {
        _authMessageCtrl.add("Wrong email or password.");
      } else {
        _authMessageCtrl.add("Error in signing in the user. Please try again later.");
        log("Error in signing in with email and password.");
      }
    }
  }

  /// Sign up a [newUser] with email and password, sends the email verification link
  /// and add the user into the Firebase DB.
  ///
  /// It adds the result of the signup process to the [isUserCreated] stream controller.
  ///
  /// In case the login is **not successful**, it adds the error message to the [authMessage] stream controller.
  Future<void> signUpUser(String email, String password, User newUser) async {
    try {
      await _firebaseAuthService.createUserWithEmailAndPassword(email, password);
    } on Firebase.FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {
        _authMessageCtrl.add("An account associated with this email already exists.");
      } else if (error.code == "weak-password") {
        _authMessageCtrl.add("The password is too weak.\nIt has to be at least 6 chars.");
      } else {
        _authMessageCtrl.add("Error in signing up the user. Please try again later.");
      }
      log("Error in creating the user: $error");
      return;
    }
    try {
      await _firebaseAuthService.sendVerificationEmail();
    } catch (error) {
      _authMessageCtrl.add("Error in signing up the user. Please try again later.");
      _firebaseAuthService.deleteUser();
      log("Error in sending the verification email to the user: $error");
      return;
    }
    newUser.id = _firebaseAuthService.currentUserId!;
    try {
      await _firestoreService.addUserIntoDB(newUser);
    } catch (error) {
      _firebaseAuthService.deleteUser();
      _authMessageCtrl.add("Error in signing up the user. Please try again later.");
      log("Failed to add the user into the DB: $error");
      return;
    }
    _authMessageCtrl.add("");
    _isUserCreatedCtrl.add(true);
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
        _firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, _firebaseAuthService.currentUserId!).then((userSnap) {
          // Check if it is a new user. If yes, insert the data into the DB
          if (userSnap.docs.isEmpty) {
            _firestoreService.addUserIntoDB(BaseUser(
                id: _firebaseAuthService.currentUserId!,
                name: userData["name"],
                surname: userData["surname"],
                birthDate: userData["birthDate"],
                email: userData["email"]));
          }
          _isUserLoggedCtrl.add(true);
        });
      }
    } on Firebase.FirebaseAuthException catch (error) {
      if (error.code == "account-exists-with-different-credential") {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      } else if (error.code == "email-already-in-use" || error.code == "credential-already-in-use") {
        _authMessageCtrl.add("This social account is already linked with another profile or the email is already registered.");
      }
    } catch (error) {
      _authMessageCtrl.add("Error in signing in with the Google account. Please try again later.");
      log("Error in signing in with the Google account");
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
        _firestoreService.getUserByIdFromDB(BaseUser.COLLECTION, _firebaseAuthService.currentUserId!).then((userSnap) {
          // Check if it is a new user. If yes, insert the data into the DB
          if (userSnap.docs.isEmpty) {
            _firestoreService.addUserIntoDB(BaseUser(
                id: _firebaseAuthService.currentUserId!,
                name: userData["name"],
                surname: userData["surname"],
                birthDate: userData["birthDate"],
                email: userData["email"]));
          }
          _isUserLoggedCtrl.add(true);
        });
      }
    } on Firebase.FirebaseAuthException catch (error) {
      if (error.code == "account-exists-with-different-credential") {
        _authMessageCtrl.add("An account already exists with the same email address but different sign-in credentials.");
      } else if (error.code == "email-already-in-use" || error.code == "credential-already-in-use") {
        _authMessageCtrl.add("This social account is already linked with another profile or the email is already registered.");
      }
    } catch (error) {
      _authMessageCtrl.add("Error in signing in with the Facebook account. Please try again later.");
      log("Error in signing in with the Facebook account");
    }
  }

  /// Send to the user [email] the link for the password reset.
  void resetPassword(String email) {
    _firebaseAuthService.resetPassword(email);
  }

  /// Get the authentication provider of the current logged user.
  ///
  /// If the user is not logged in, it return an `empty string`.
  String authProvider() {
    return _firebaseAuthService.getAuthProvider() ?? "";
  }

  /// Returns `true` if the user associated with the [email] has the password as authentication provider.
  Future<bool> hasPasswordAuthentication(String email) async {
    var list = await _firebaseAuthService.fetchSignInMethods(email);
    if (list != null) {
      if (list.contains("password")) {
        return true;
      }
    }
    return false;
  }

  /// Log out the user from the app, updates the [isUserLogged] stream controller and call [clearControllers].
  Future<void> logOut() async {
    _isUserLoggedCtrl.add(false);
    _firebaseAuthService.signOut();
  }

  /// Register the notification service for the device of the [loggedUser].
  void setNotification(User loggedUser) {
    _notificationService.configNotification();
    _notificationService.getDeviceToken().then((token) {
      _firestoreService.updateUserFieldIntoDB(loggedUser, "pushToken", token);
    }).catchError((e) {
      log("Error in getting the device token: $e");
    });
  }

  /// Delete the [loggedUser] account both from the authentication FirebaseService and from the Firebase DB
  /// and updates the [isUserLogged] stream controller.
  Future<void> deleteUser(User loggedUser) async {
    _firebaseAuthService.deleteUser();
    _firestoreService.removeUserFromDB(loggedUser);
    _isUserLoggedCtrl.add(false);
  }

  /// Clear the [_authMessageCtrl].
  void clearAuthMessage() {
    _authMessageCtrl.add("");
  }

  /// Stream of the user logged controller.
  Stream<bool> get isUserLogged => _isUserLoggedCtrl.stream;

  /// Stream of the user created controller.
  Stream<bool> get isUserCreated => _isUserCreatedCtrl.stream;

  /// Stream of the authentication message controller.
  Stream<String?> get authMessage => _authMessageCtrl.stream;
}
