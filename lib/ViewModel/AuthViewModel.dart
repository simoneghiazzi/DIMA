import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/User.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/AuthService.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/ObserverForms/AuthForm.dart';
import 'package:flutter/material.dart';

class AuthViewModel{
  
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService auth = AuthService();
  final LoginForm loginForm = LoginForm();
  var _loginController = StreamController<bool>.broadcast();
  User currentUser;

  AuthViewModel(){
    emailController.addListener(() => loginForm.emailText.add(emailController.text));
    passwordController.addListener(() => loginForm.passwordText.add(passwordController.text));
    alreadyLogged();
  }

  void alreadyLogged(){
    String uid = auth.currentUser();
    if(uid != null){
      currentUser = User(uid: uid);
      _loginController.add(true);
      loginForm.dispose();
    }
    else 
      _loginController.add(false);
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

  Stream<bool> get isUserLogged => _loginController.stream;

  LoginForm getLoginForm() => loginForm;
}