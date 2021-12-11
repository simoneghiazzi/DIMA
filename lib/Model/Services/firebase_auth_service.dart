import 'dart:collection';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sApport/Model/user.dart';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class FirebaseAuthService {
  // Firebase Auth instance
  final Firebase.FirebaseAuth _firebaseAuth;

  // Services
  final FirestoreService _firestoreService = GetIt.I();

  // Instance of the firebase user returned by the FirebaseAuth SDK
  Firebase.User _firebaseUser;

  /// Service used by the view models to interact with the Firebase Auth service
  FirebaseAuthService(this._firebaseAuth);

  /// Attempts to sign in a user with the given [email] and [password].
  ///
  /// If successfull, it also save the [firebaseUser] instance inside the auth service.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **user-not-found**:
  ///   - Thrown if there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///   - Thrown if the password is invalid for the given email.
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    _firebaseUser = (await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)).user;
  }

  /// Tries to create a new user account with the given [email] address and [password].
  ///
  /// If successfull, it also save the [firebaseUser] instance inside the auth service.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **email-already-in-use**:
  ///   - Thrown if there already exists an account with the given email address.
  /// - **weak-password**:
  ///   - Thrown if the password is not strong enough.
  Future<void> createUserWithEmailAndPassword(String email, String password, User user) async {
    _firebaseUser = (await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)).user;
    user.id = _firebaseUser.uid;
    if (user.data["profilePhoto"] != null) {
      _firestoreService.uploadProfilePhoto(user, File(user.data["profilePhoto"]));
    }
    _firestoreService.addUserIntoDB(user);
  }

  /// Sends a password reset email to the given [email] address.
  void resetPassword(String email) {
    _firebaseAuth
        .sendPasswordResetEmail(email: email)
        .then((value) => print("Reset password email sent"))
        .catchError((error) => print("Failed send reset password email: $error"));
  }

  /// Attempts to sign in a user with the Google account.
  /// If the user doesn't have an account already, one will be created automatically.
  ///
  /// If [link] is true, it links the Google account to the logged user.
  ///
  /// If successfull, it also save the [firebaseUser] instance inside the auth service.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **account-exists-with-different-credential**:
  ///   - Thrown if there already exists an account with the email address
  ///    asserted by the credential.
  Future<void> signInWithGoogle(bool link) async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        "email",
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/user.birthday.read",
      ],
    );
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    Firebase.AuthCredential googleCredential = Firebase.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // If link is true, it links the Google account to the logged user and exit
    if (link) {
      _firebaseUser = (await _firebaseUser.linkWithCredential(googleCredential)).user;
      return;
    }

    // Check the sign in methods of the user to prevent profiles from being automatically linked
    var signInMethods = await fetchSignInMethods(googleSignIn.currentUser.email);
    if (signInMethods.contains("google.com") || signInMethods.isEmpty) {
      // Sign in with Google credential
      _firebaseUser = (await _firebaseAuth.signInWithCredential(googleCredential)).user;

      // Check if it is a new user. If yes, insert the data into the DB
      var userSnap = await _firestoreService.getUserByIdFromDB(Collection.BASE_USERS, _firebaseUser.uid);
      if (userSnap.docs.isEmpty) {
        // Retrieve the user birthdate info from the Google account
        final currentGoogleUser = googleSignIn.currentUser;
        final res = await get(
          Uri.parse("https://people.googleapis.com/v1/people/me?personFields=birthdays&key="),
          headers: {"Authorization": (await currentGoogleUser.authHeaders)["Authorization"]},
        );
        final birthDate = jsonDecode(res.body)["birthdays"][0]["date"];

        await _firestoreService.addUserIntoDB(BaseUser(
            id: _firebaseUser.uid,
            name: currentGoogleUser.displayName.split(" ")[0],
            surname: currentGoogleUser.displayName.split(" ")[1],
            email: currentGoogleUser.email,
            birthDate: DateTime.parse("${birthDate["year"]}-${birthDate["month"]}-${birthDate["day"]}")));
      }
    }
  }

  /// Attempts to sign in a user with the Facebook account.
  /// If the user doesn't have an account already, one will be created automatically.
  ///
  /// If [link] is true, it links the Facebook account to the logged user.
  ///
  /// If successfull, it also save the [firebaseUser] instance inside the auth service.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **account-exists-with-different-credential**:
  ///   - Thrown if there already exists an account with the email address
  ///    asserted by the credential.
  Future<void> signInWithFacebook(bool link) async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ["email", "public_profile", "user_birthday"]);
    AccessToken accessToken = result.accessToken;
    var facebookCredential = Firebase.FacebookAuthProvider.credential(accessToken.token);

    // If link is true, it links the Facebook account to the logged user and exit
    if (link) {
      _firebaseUser = (await _firebaseUser.linkWithCredential(facebookCredential)).user;
      return;
    }

    // Sign in with Google credential
    _firebaseUser = (await _firebaseAuth.signInWithCredential(facebookCredential)).user;

    // Check if it is a new user. If yes, insert the data into the DB
    var userSnap = await _firestoreService.getUserByIdFromDB(Collection.BASE_USERS, _firebaseUser.uid);
    if (userSnap.docs.isEmpty) {
      final userData = await FacebookAuth.instance.getUserData(fields: "name, birthday");

      // Format the user birthdate info from the Google account
      var birthDate = userData["birthday"].split("/");

      await _firestoreService.addUserIntoDB(BaseUser(
          id: _firebaseUser.uid,
          name: userData["name"].split(" ")[0],
          surname: userData["name"].split(" ")[1],
          email: _firebaseUser.email,
          birthDate: DateTime.parse("${birthDate[2]}-${birthDate[0]}-${birthDate[1]}")));
    }
  }

  /// Send the email verification to the user in the sign up process
  void sendEmailVerification() {
    if (_firebaseUser != null) {
      _firebaseAuth.currentUser
          .sendEmailVerification()
          .then((value) => print("Email verification sent"))
          .catchError((error) => print("Failed to send email verification: $error"));
    }
  }

  /// Get the authentication provider of the current logged user.
  ///
  /// If the user is not logged in, it return an `empty string`.
  String getAuthProvider() {
    try {
      return _firebaseAuth.currentUser.providerData[0].providerId;
    } catch (e) {
      return "";
    }
  }

  /// Returns a list of sign-in methods that can be used to sign in a given user (identified by its main email address).
  ///
  /// An empty `List` is returned if the user could not be found.
  Future<List<String>> fetchSignInMethods(String email) async {
    return await _firebaseAuth.fetchSignInMethodsForEmail(email);
  }

  /// Deletes and signs out the user.
  Future deleteUser(User user) async {
    _firestoreService.removeUserFromDB(user);
    _firebaseAuth.currentUser.delete();
    _firebaseUser = null;
  }

  /// Signs out the current user.
  ///
  /// It sets the firebase User to `null`.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _firebaseUser = null;
  }

  /// It returns the `firebaseUser` if the user is already logged in.
  /// It also checks if the email is verified in case the user has signed up with the email and password method.
  ///
  /// If the user is not logged in or the email is not verified, it returns `null`.
  Firebase.User get firebaseUser {
    if (_firebaseAuth.currentUser != null) {
      HashSet<String> providers = HashSet();
      _firebaseAuth.currentUser.providerData.forEach((element) => providers.add(element.providerId));
      if (providers.contains("password") && !_firebaseAuth.currentUser.emailVerified) {
        return null;
      }
      _firebaseUser = _firebaseAuth.currentUser;
      return _firebaseUser;
    }
    return null;
  }
}
