import 'package:dima_colombo_ghiazzi/Model/logedUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseAuth {
  Future<LoggedUser> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password,
      String name, String surname, DateTime birthDate);
  Future deleteUser();
  Future<LoggedUser> currentUser();
}

class FirebaseAuthService implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential _userCredential;

  //The collection of users in the firestore DB
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<LoggedUser> signInWithEmailAndPassword(
      String email, String password) async {
    _userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    if (_firebaseAuth.currentUser.emailVerified) {
      return queryDb(_userCredential.user.uid);
    }
    return null;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password,
      String name, String surname, DateTime birthDate) async {
    _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

    users
        .add({
          'uid': _userCredential.user.uid,
          'name': name,
          'surname': surname,
          'birthDate': birthDate
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to add user: $error"));

    return _userCredential.user.uid;
  }

  Future<String> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    _userCredential = await _firebaseAuth.signInWithCredential(credential);
    return _userCredential.user.uid;
  }

  Future<String> signInWithFacebook() async {
    LoginResult result = await FacebookAuth.instance.login();
    AccessToken accessToken = result.accessToken;
    var facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken.token);
    _userCredential =
        await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    return _userCredential.user.uid;
  }

  Future<LoggedUser> currentUser() async {
    if (_firebaseAuth.currentUser != null &&
        _firebaseAuth.currentUser.emailVerified) {
      return queryDb(_firebaseAuth.currentUser.uid);
    }
    return null;
  }

  Future sendEmailVerification() async {
    if (_userCredential != null) {
      await _firebaseAuth.currentUser.sendEmailVerification();
    }
  }

  Future deleteUser() async {
    _userCredential = null;
    await _firebaseAuth.currentUser.delete();
  }

  Future signOut() async {
    _userCredential = null;
    await _firebaseAuth.signOut();
  }

  //Query the firestore DB in order to retrieve the user's info
  Future<LoggedUser> queryDb(String uid) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('users')
        .where('uid', isEqualTo: uid)
        .get();

    List<QueryDocumentSnapshot> docs = snapshot.docs;
    for (var doc in docs) {
      if (doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        Timestamp t = data['birthDate'];
        LoggedUser loggedUser = new LoggedUser(
            name: data['name'].toString(),
            surname: data['name'].toString(),
            uid: uid,
            dateOfBirth: t.toDate());

        return loggedUser;
      }
    }
    return null;
  }
}
