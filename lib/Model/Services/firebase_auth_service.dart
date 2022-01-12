import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:collection';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FirebaseAuthService {
  // Firebase Auth instance
  final FirebaseAuth _firebaseAuth;

  /// Service used by the view models to interact with the Firebase Auth service.
  FirebaseAuthService(this._firebaseAuth);

  /// Attempts to sign in a user with the given [email] and [password].
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **user-not-found**:
  ///   - Thrown if there is no user corresponding to the given email.
  /// - **wrong-password**:
  ///   - Thrown if the password is invalid for the given email.
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Tries to create a new user account with the given [email] address and [password].
  ///
  /// A [FirebaseAuthException] maybe thrown with the following error code:
  /// - **email-already-in-use**:
  ///   - Thrown if there already exists an account with the given email address.
  Future<void> createUserWithEmailAndPassword(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
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
        await _firebaseAuth.currentUser!.linkWithCredential(googleCredential);
      } else {
        // Check the sign in methods of the user to prevent profiles from being automatically linked
        var signInMethods = await fetchSignInMethods(googleUser.email);
        if (signInMethods != null) {
          if (signInMethods.contains("google.com") || signInMethods.isEmpty) {
            // Sign in with Google credential
            await _firebaseAuth.signInWithCredential(googleCredential);

            // Retrieve the user birthdate info from the Google account
            final res = await get(
              Uri.parse("https://people.googleapis.com/v1/people/me?personFields=birthdays&key="),
              headers: {"Authorization": (await googleUser.authHeaders)["Authorization"]!},
            );
            final birthDate = jsonDecode(res.body)["birthdays"][0]["date"];
            var month = birthDate["month"] < 10 ? ('0${birthDate["month"]}') : birthDate["month"];

            // Return the information retrieved from the Google account
            return {
              "name": googleUser.displayName!.split(" ")[0],
              "surname": googleUser.displayName!.split(" ")[1],
              "email": googleUser.email,
              "birthDate": DateTime.parse("${birthDate["year"]}-$month-${birthDate["day"]}"),
            };
          } else {
            throw (FirebaseAuthException(code: "account-exists-with-different-credential"));
          }
        }
      }
    }
    throw FirebaseException(plugin: "Error");
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
    if (result.accessToken != null) {
      AccessToken accessToken = result.accessToken!;
      var facebookCredential = FacebookAuthProvider.credential(accessToken.token);

      // If link is true, it links the Facebook account to the logged user
      if (link) {
        await _firebaseAuth.currentUser!.linkWithCredential(facebookCredential);
      } else {
        // Sign in with Facebook credential
        await _firebaseAuth.signInWithCredential(facebookCredential);
        final userData = await FacebookAuth.instance.getUserData(fields: "name, birthday");

        // Format the user birthdate info from the Facebook account
        var birthDate = userData["birthday"].split("/");
        var month = birthDate[2] < 10 ? ('0${birthDate[2]}') : birthDate[2];
        return {
          "name": userData["name"].split(" ")[0],
          "surname": userData["name"].split(" ")[1],
          "email": _firebaseAuth.currentUser?.email,
          "birthDate": DateTime.parse("${birthDate[2]}-$month-${birthDate[1]}")
        };
      }
    }
    throw FirebaseException(plugin: "Error");
  }

  /// Sends a password reset email to the given [email] address.
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      log("Reset password email sent");
    } on FirebaseAuthException catch (error) {
      log("Failed send reset password email: $error");
    }
  }

  /// Signs out the current user.
  ///
  /// It sets the firebase User to `null`.
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  /// Get the authentication provider of the current logged user.
  ///
  /// If the user is not logged in, it returns `null`.
  String? getAuthProvider() {
    return _firebaseAuth.currentUser?.providerData[0].providerId;
  }

  /// Returns the list of sign-in methods that can be used to sign in a given user (identified by its main email address).
  Future<List<String>?> fetchSignInMethods(String email) async {
    try {
      return await _firebaseAuth.fetchSignInMethodsForEmail(email);
    } on FirebaseAuthException catch (error) {
      log("Failed to fetching the signed in methods of the user: $error");
    }
  }

  /// Delete and signs out the user.
  Future<void> deleteUser() async {
    return _firebaseAuth.currentUser!.delete().then((_) => log("User deleted"));
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

  /// Send the verification email to the user in the sign up process.
  Future<void> sendVerificationEmail() async {
    return _firebaseAuth.currentUser!.sendEmailVerification().then((_) => log("Verification email sent"));
  }

  /// Get the uid of the current logged user.
  String? get currentUserId => _firebaseAuth.currentUser?.uid;
}
