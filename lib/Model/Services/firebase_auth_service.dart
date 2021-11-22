import 'dart:convert';
import 'dart:io';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/base_user.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart';

class FirebaseAuthService {
  final FirestoreService _firestoreService = FirestoreService();
  final Firebase.FirebaseAuth _firebaseAuth = Firebase.FirebaseAuth.instance;
  Firebase.UserCredential _userCredential;

  /// Sign in a user with [email] and [password]
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    _userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    if (_firebaseAuth.currentUser.emailVerified) {
      return _userCredential.user.uid;
    }
    return null;
  }

  /// Create a new user with [email] and [password]
  Future<String> createUserWithEmailAndPassword(
      String email, String password, User user) async {
    _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    user.id = _userCredential.user.uid;
    if (user.getData()['profilePhoto'] != null) {
      _firestoreService.uploadProfilePhoto(
          user, File(user.getData()['profilePhoto']));
    }
    await _firestoreService.addUserIntoDB(user);
    return _userCredential.user.uid;
  }

  /// Send email for reset password
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  // Future<void> linkProviders() async {
  //   await _userCredential.user.linkWithCredential(credential)
  // }

  /// Sign in a user if it exists or create a new user through the google account.
  /// It retrieves the name, surname and birthDate information from the google account of the user.
  Future<String> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'email',
      "https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/user.birthday.read"
    ]);
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    var signInMethods =
        await fetchSignInMethods(googleSignIn.currentUser.email);
    if (signInMethods.contains("google.com") || signInMethods.isEmpty) {
      Firebase.AuthCredential credential =
          Firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      _userCredential = await _firebaseAuth.signInWithCredential(credential);

      // Check if it is a new user. If yes, insert the data into the DB
      if (await _firestoreService.getUserByIdFromDB(
              Collection.BASE_USERS, _userCredential.user.uid) ==
          null) {
        final headers = await googleSignIn.currentUser.authHeaders;
        final res = jsonDecode((await get(
                Uri.parse(
                    "https://people.googleapis.com/v1/people/me?personFields=birthdays&key="),
                headers: {"Authorization": headers["Authorization"]}))
            .body)['birthdays'][0]['date'];
        var displayName = googleSignIn.currentUser.displayName.split(" ");
        String birthDate = '${res['year']}-${res['month']}-${res['day']}';

        await _firestoreService.addUserIntoDB(BaseUser(
            id: _userCredential.user.uid,
            name: displayName[0],
            surname: displayName[1],
            birthDate: DateTime.parse(birthDate)));
      }
      return _userCredential.user.uid;
    } else {
      return null;
    }
  }

  /// Sign in a user if it exists or create a new user through the facebook account.
  /// It retrieves the name, surname and birthDate information from the facebook account of the user.
  Future<String> signInWithFacebook() async {
    LoginResult result = await FacebookAuth.instance
        .login(permissions: ['public_profile', 'user_birthday']);
    AccessToken accessToken = result.accessToken;
    var facebookAuthCredential =
        Firebase.FacebookAuthProvider.credential(accessToken.token);
    _userCredential =
        await _firebaseAuth.signInWithCredential(facebookAuthCredential);

    // Check if it is a new user. If yes, insert the data into the DB
    if (await _firestoreService.getUserByIdFromDB(
            Collection.BASE_USERS, _userCredential.user.uid) ==
        null) {
      final userData =
          await FacebookAuth.instance.getUserData(fields: "name, birthday");

      var res = userData['birthday'].split('/');
      String birthDate = '${res[2]}-${res[0]}-${res[1]}';
      await _firestoreService.addUserIntoDB(BaseUser(
          id: _userCredential.user.uid,
          name: userData['name'].split(" ")[0],
          surname: userData['name'].split(" ")[1],
          birthDate: DateTime.parse(birthDate)));
    }
    return _userCredential.user.uid;
  }

  /// Send the email verification to the user in the sign up process
  Future sendEmailVerification() async {
    if (_userCredential != null) {
      await _firebaseAuth.currentUser.sendEmailVerification();
    }
  }

  /// Get the authentication provider of the current user
  String getAuthProvider() {
    return _firebaseAuth.currentUser.providerData[0].providerId;
  }

  Future<List<String>> fetchSignInMethods(String email) async {
    return await _firebaseAuth.fetchSignInMethodsForEmail(email);
  }

  /// Delete a user
  Future deleteUser(User user) async {
    await _firestoreService.removeUserFromDB(user);
    await _firebaseAuth.currentUser.delete();
    _userCredential = null;
  }

  /// Sign out a user
  Future signOut() async {
    _userCredential = null;
    await _firebaseAuth.signOut();
  }

  /// Return the user id if it is already logged in.
  /// It checks if the email is verified in case the user has signed up with the email and password method.
  Future<String> currentUser() async {
    if (_firebaseAuth.currentUser != null) {
      if (_firebaseAuth.currentUser.providerData[0].providerId == 'password' &&
          !_firebaseAuth.currentUser.emailVerified) return null;
      return _firebaseAuth.currentUser.uid;
    }
    return null;
  }
}
