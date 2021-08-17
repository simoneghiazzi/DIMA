import 'dart:convert';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';

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
      return await queryDb(_userCredential.user.uid);
    }
    return null;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password,
      String name, String surname, DateTime birthDate) async {
    _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    users
        .doc(_userCredential.user.uid)
        .set({
          'uid': _userCredential.user.uid,
          'name': name,
          'surname': surname,
          'birthDate': birthDate.toString()
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed to add user: $error"));

    return _userCredential.user.uid;
  }

  Future<String> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
      'email',
      "https://www.googleapis.com/auth/userinfo.profile",
      "https://www.googleapis.com/auth/user.birthday.read"
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
            Uri.parse(
                "https://people.googleapis.com/v1/people/me?personFields=birthdays&key="),
            headers: {"Authorization": headers["Authorization"]}))
        .body)['birthdays'][0]['date'];
    String birthDate = '${res['month']}/${res['day']}/${res['year']}';
    if (await queryDb(_userCredential.user.uid) == null) {
      users
          .doc(_userCredential.user.uid)
          .set({
            'uid': _userCredential.user.uid,
            'name': googleSignIn.currentUser.displayName.split(" ")[0],
            'surname': googleSignIn.currentUser.displayName.split(" ")[1],
            'birthDate': birthDate,
          })
          .then((value) => print("User added"))
          .catchError((error) => print("Failed to add user: $error"));
    }

    // Map<String, dynamic> idMap = parseJwt(googleAuth.idToken);

    return _userCredential.user.uid;
  }

  Future<LoggedUser> signInWithFacebook() async {
    LoginResult result = await FacebookAuth.instance
        .login(permissions: ['public_profile', 'user_birthday']);
    AccessToken accessToken = result.accessToken;
    var facebookAuthCredential =
        FacebookAuthProvider.credential(accessToken.token);
    _userCredential =
        await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    if (await queryDb(_userCredential.user.uid) == null) {
      final userData =
          await FacebookAuth.instance.getUserData(fields: "name, birthday");
      users
          .doc(_userCredential.user.uid)
          .set({
            'uid': _userCredential.user.uid,
            'name': userData['name'].split(" ")[0],
            'surname': userData['name'].split(" ")[1],
            'birthDate': userData['birthday']
          })
          .then((value) => print("User added"))
          .catchError((error) => print("Failed to add user: $error"));
    }
    return await queryDb(_firebaseAuth.currentUser.uid);
  }

  Future<LoggedUser> currentUser() async {
    if (_firebaseAuth.currentUser != null) {
      if (_firebaseAuth.currentUser.providerData[0].providerId == 'password' &&
          !_firebaseAuth.currentUser.emailVerified) return null;
      return await queryDb(_firebaseAuth.currentUser.uid);
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
        LoggedUser loggedUser = new LoggedUser(
            name: data['name'].toString(),
            surname: data['surname'].toString(),
            uid: uid,
            dateOfBirth: data['birthDate'].toString());

        return loggedUser;
      }
    }
    return null;
  }
}
