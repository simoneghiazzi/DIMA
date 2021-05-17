import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth{
  Future<String> signInWithEmailAndPassword(String email, String password);
  Future<String> createUserWithEmailAndPassword(String email, String password);
  Future deleteUser();
  String currentUser();
}

class FirebaseAuthService implements BaseAuth{

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

  Future<String> signInWithGoogle() async{
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

  String currentUser() {
    if (_firebaseAuth.currentUser != null)
      return _firebaseAuth.currentUser.uid;
    return null;
  }

  Future sendEmailVerification() async{
    if(_userCredential != null){
      await _firebaseAuth.currentUser.sendEmailVerification();
    }
  }

  Future deleteUser() async{
    _userCredential = null;
    await _firebaseAuth.currentUser.delete();
  }

  Future signOut() async {
    _userCredential = null;
    await _firebaseAuth.signOut();
  }
}