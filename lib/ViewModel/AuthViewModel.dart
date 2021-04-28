import 'dart:async';
import 'package:email_validator/email_validator.dart';
import 'package:dima_colombo_ghiazzi/Model/User.dart';
import 'package:dima_colombo_ghiazzi/Services/Auth.dart';

abstract class AuthViewModelInterface{
  Sink get emailText;
  Stream<bool> get isButtonEnabled;
  //Stream<bool> get isUserLogged;
  Stream<String> get errorText;

  void dispose();
}

class AuthViewModel implements AuthViewModelInterface{
  
  Auth auth = Auth();
  User currentUser;
  var _emailController = StreamController<String>.broadcast();

  @override
  Sink get emailText => _emailController;

  @override
  Stream<bool> get isButtonEnabled => _emailController.stream.map((email) => EmailValidator.validate(email));

  @override
  Stream<String> get errorText => isButtonEnabled.map((isEnabled) => isEnabled ? null : "Invalid email");

  @override
  void dispose() => _emailController.close();

  
  void alreadyLogged(){
    String uid = auth.currentUser();
    uid != null ? currentUser = User(uid: uid) : currentUser = null;
  }

  void createUser(String _email, String _password) async{
    String uid = await auth.createUserWithEmailAndPassword(_email, _password);
    uid != null ? currentUser = User(uid: uid) : currentUser = null;
  }
  
  void logIn(String _email, String _password) async{
    String uid = await auth.signInWithEmailAndPassword(_email, _password);
    uid != null ? currentUser = User(uid: uid) : currentUser = null;
  }

  void logOut() async{
    await auth.signOut();
    currentUser = null;
  }
}