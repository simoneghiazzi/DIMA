import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future<void> sendEmailVerification();
  Future<void> deleteUser();
  String currentUser();
}

class AuthService implements BaseAuth{

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserCredential _userCredential;

  Future<String> signInWithEmailAndPassword(String email, String password) async{
    _userCredential = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    if(_firebaseAuth.currentUser.emailVerified)
      return _userCredential.user.uid;
    return null;
  }

  Future<String> createUserWithEmailAndPassword(String email, String password) async{
    _userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    return _userCredential.user.uid;
  }

  String currentUser() {
    if (_firebaseAuth.currentUser != null)
      return _firebaseAuth.currentUser.uid;
    return null;
  }

  Future<void> sendEmailVerification() async{
    if(_userCredential != null){
      await _firebaseAuth.currentUser.sendEmailVerification();
    }
  }

  Future<void> deleteUser() async{
    await _firebaseAuth.currentUser.delete();
  }

  Future<void> signOut() async {
    _userCredential = null;
    return _firebaseAuth.signOut();
  }
}