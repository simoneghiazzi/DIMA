import 'dart:async';
import 'dart:convert';
import 'dart:collection';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseAuthService {
  // Firebase Auth instance
  final FirebaseAuth _firebaseAuth;

  // Instance of the firebase user returned by the FirebaseAuth SDK
  User? firebaseUser;

  /// Service used by the view models to interact with the Firebase Auth service.
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
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password).then((credential) => firebaseUser = credential.user);
  }

  /// Tries to create a new user account with the given [email] address and [password].
  ///
  /// If successfull, it also save the [firebaseUser] instance inside the auth service and
  /// calls the [_sendVerificationEmail] method.
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **email-already-in-use**:
  ///   - Thrown if there already exists an account with the given email address.
  /// - **weak-password**:
  ///   - Thrown if the password is not strong enough.
  Future<void> createUserWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password).then((credential) {
      firebaseUser = credential.user!;
      _sendVerificationEmail();
    });
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
  /// - **email-already-in-use**:
  ///   - Thrown if the email corresponding to the credential already exists
  ///    among your users.
  /// - **credential-already-in-use**:
  ///   - Thrown if the account corresponding to the credential already exists
  ///    among your users, or is already linked to a Firebase User.
  Future<Map> signInWithGoogle(bool link) async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: [
        "email",
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/user.birthday.read",
      ],
    );
    GoogleSignInAccount? googleUser = await (googleSignIn.signIn());
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      AuthCredential googleCredential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // If link is true, it links the Google account to the logged user
      if (link) {
        firebaseUser = (await firebaseUser!.linkWithCredential(googleCredential)).user;
      } else {
        // Check the sign in methods of the user to prevent profiles from being automatically linked
        var signInMethods = await fetchSignInMethods(googleUser.email);
        if (signInMethods.contains("google.com") || signInMethods.isEmpty) {
          // Sign in with Google credential
          firebaseUser = (await _firebaseAuth.signInWithCredential(googleCredential)).user!;

          // Retrieve the user birthdate info from the Google account
          final res = await get(
            Uri.parse("https://people.googleapis.com/v1/people/me?personFields=birthdays&key="),
            headers: {"Authorization": (await googleUser.authHeaders)["Authorization"]!},
          );
          final birthDate = jsonDecode(res.body)["birthdays"][0]["date"];

          // Return the information retrieved from the Google account
          return {
            "name": googleUser.displayName!.split(" ")[0],
            "surname": googleUser.displayName!.split(" ")[1],
            "email": googleUser.email,
            "birthDate": DateTime.parse("${birthDate["year"]}-${birthDate["month"]}-${birthDate["day"]}"),
          };
        } else {
          throw (FirebaseAuthException(code: "account-exists-with-different-credential"));
        }
      }
    }
    return {};
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
  /// - **email-already-in-use**:
  ///   - Thrown if the email corresponding to the credential already exists
  ///    among your users.
  /// - **credential-already-in-use**:
  ///   - Thrown if the account corresponding to the credential already exists
  ///    among your users, or is already linked to a Firebase User.
  Future<Map> signInWithFacebook(bool link) async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ["email", "public_profile", "user_birthday"]);
    AccessToken accessToken = result.accessToken!;
    var facebookCredential = FacebookAuthProvider.credential(accessToken.token);

    // If link is true, it links the Facebook account to the logged user
    if (link) {
      firebaseUser = (await firebaseUser!.linkWithCredential(facebookCredential)).user!;
    } else {
      // Sign in with Facebook credential
      firebaseUser = (await _firebaseAuth.signInWithCredential(facebookCredential)).user!;
      final userData = await FacebookAuth.instance.getUserData(fields: "name, birthday");

      // Format the user birthdate info from the Facebook account
      var birthDate = userData["birthday"].split("/");
      return {
        "name": userData["name"].split(" ")[0],
        "surname": userData["name"].split(" ")[1],
        "email": firebaseUser?.email,
        "birthDate": DateTime.parse("${birthDate[2]}-${birthDate[0]}-${birthDate[1]}")
      };
    }
    return {};
  }

  /// Sends a password reset email to the given [email] address.
  void resetPassword(String email) {
    _firebaseAuth
        .sendPasswordResetEmail(email: email)
        .then((value) => print("Reset password email sent"))
        .catchError((error) => print("Failed send reset password email: $error"));
  }

  /// Signs out the current user.
  ///
  /// It sets the firebase User to `null`.
  Future<void> signOut() {
    firebaseUser = null;
    return _firebaseAuth.signOut();
  }

  /// Get the authentication provider of the current logged user.
  ///
  /// If the user is not logged in, it return an `empty string`.
  String getAuthProvider() {
    try {
      return _firebaseAuth.currentUser!.providerData[0].providerId;
    } catch (e) {
      return "";
    }
  }

  /// Returns the list of sign-in methods that can be used to sign in a given user (identified by its main email address).
  ///
  /// An empty `List` is returned if the user could not be found.
  Future<List<String>> fetchSignInMethods(String email) {
    return _firebaseAuth.fetchSignInMethodsForEmail(email).catchError((error) {
      print("Error in getting the sign in methods: $error");
    });
  }

  /// Delete and signs out the user.
  Future deleteUser() async {
    firebaseUser = null;
    _firebaseAuth.currentUser!.delete();
  }

  /// It checks if the email is verified in case the user has signed up with the email and password method.
  bool isUserEmailVerified() {
    HashSet<String> providers = HashSet();
    _firebaseAuth.currentUser!.providerData.forEach((element) => providers.add(element.providerId));
    if (providers.contains("password") && !_firebaseAuth.currentUser!.emailVerified) {
      return false;
    }
    return true;
  }

  /// Determines the current sign-in state of the user.
  bool isUserSignedIn() {
    if (_firebaseAuth.currentUser != null) {
      firebaseUser = _firebaseAuth.currentUser;
      return true;
    }
    return false;
  }

  /// Send the verification email to the user in the sign up process
  void _sendVerificationEmail() {
    _firebaseAuth.currentUser!
        .sendEmailVerification()
        .then((value) => print("Verification email sent"))
        .catchError((error) => print("Failed to send the verification email: $error"));
  }
}
