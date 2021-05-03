import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  String currentUser();
}

class AuthService implements BaseAuth{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signInWithEmailAndPassword(String email, String password) async{
    UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      print(e.code);
    }
    return userCredential.user.uid;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async{
    UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
        print(e.code);
    }
    return userCredential.user.uid;
  }

  String currentUser() {
    if (_firebaseAuth.currentUser != null)
      return _firebaseAuth.currentUser.uid;
    return null;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}