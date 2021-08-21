import 'dart:convert';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart';

// Abstract class containing the base authentication methods
abstract class BaseAuth {
  Future<LoggedUser> signInWithEmailAndPassword(String email, String password);
  Future<LoggedUser> createUserWithEmailAndPassword(String email, String password, String name, String surname, String birthDate);
  Future deleteUser();
  Future<LoggedUser> currentUser();
}

class FirebaseAuthService implements BaseAuth {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential _userCredential;

  // Sign in a user with email and password
  Future<LoggedUser> signInWithEmailAndPassword(String email, String password) async {
    _userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    if (_firebaseAuth.currentUser.emailVerified) {
      return await _firestoreService.getUserFromDB(_userCredential.user.uid);
    }
    return null;
  }

  // Create a new user with email and password
  Future<LoggedUser> createUserWithEmailAndPassword(String email, String password, String name, String surname, String birthDate) async {
    _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    await _firestoreService.addUserIntoDB(_userCredential.user.uid, name, surname, birthDate);
    return await _firestoreService.getUserFromDB(_userCredential.user.uid);
  }

  /* Sign in a user if it exists or create a new user through the google account.
  It retrieves the name, surname and birthDate information from the google account of the user. */
  Future<LoggedUser> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', "https://www.googleapis.com/auth/userinfo.profile", "https://www.googleapis.com/auth/user.birthday.read" 
    ]);
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    _userCredential = await _firebaseAuth.signInWithCredential(credential);
    final headers = await googleSignIn.currentUser.authHeaders;
    final res = jsonDecode((await get(
        Uri.parse("https://people.googleapis.com/v1/people/me?personFields=birthdays&key="), 
        headers: {"Authorization": headers["Authorization"]})).body)['birthdays'][0]['date'];
    String birthDate = '${res['month']}/${res['day']}/${res['year']}';

    // Check if it is a new user. If yes, insert the data into the DB
    if (await _firestoreService.getUserFromDB(_userCredential.user.uid) == null) {
    await _firestoreService.addUserIntoDB(
        _userCredential.user.uid, 
        googleSignIn.currentUser.displayName.split(" ")[0], 
        googleSignIn.currentUser.displayName.split(" ")[1], 
        birthDate);
    }
    return await _firestoreService.getUserFromDB(_userCredential.user.uid);
  }

  /* Sign in a user if it exists or create a new user through the facebook account.
  It retrieves the name, surname and birthDate information from the facebook account of the user. */
  Future<LoggedUser> signInWithFacebook() async {
    LoginResult result = await FacebookAuth.instance.login(permissions: ['public_profile', 'user_birthday']);
    AccessToken accessToken = result.accessToken;
    var facebookAuthCredential = FacebookAuthProvider.credential(accessToken.token);
    _userCredential = await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    if (await _firestoreService.getUserFromDB(_userCredential.user.uid) == null) {
      final userData = await FacebookAuth.instance.getUserData(fields: "name, birthday");
      await _firestoreService.addUserIntoDB(
        _userCredential.user.uid, 
        userData['name'].split(" ")[0], 
        userData['name'].split(" ")[1], 
        userData['birthday']);
    }
    return await _firestoreService.getUserFromDB(_userCredential.user.uid);
  }

  /* Return the user if it is aleready logged in.
  It checks if the email is verified in case the user has signed up with the email and password method. */
  Future<LoggedUser> currentUser() async {
    if (_firebaseAuth.currentUser != null) {
      if (_firebaseAuth.currentUser.providerData[0].providerId == 'password' && !_firebaseAuth.currentUser.emailVerified) 
        return null;
      return await _firestoreService.getUserFromDB(_firebaseAuth.currentUser.uid);
    }
    return null;
  }

  // Send the email verification to the user in the sign up process
  Future sendEmailVerification() async {
    if (_userCredential != null) {
      await _firebaseAuth.currentUser.sendEmailVerification();
    }
  }

  // Delete a user 
  Future deleteUser() async {
    await _firebaseAuth.currentUser.delete();
    await _firestoreService.deleteUserFromDB(_userCredential.user.uid);
    _userCredential = null;
  }

  // Sign out a user
  Future signOut() async {
    _userCredential = null;
    await _firebaseAuth.signOut();
  }
}
