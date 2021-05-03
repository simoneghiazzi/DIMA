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
  var _isUserLogged = StreamController<bool>.broadcast();
  var _authErrorMessage = StreamController<String>.broadcast();
  User currentUser;

  AuthViewModel(){
    emailController.addListener(() => loginForm.emailText.add(emailController.text));
    passwordController.addListener(() => loginForm.passwordText.add(passwordController.text));
  }

  void getData(){
    if(emailController.text.isNotEmpty)
      loginForm.emailText.add(emailController.text);
    if(passwordController.text.isNotEmpty)
      loginForm.passwordText.add(emailController.text);
  }

  void alreadyLogged(){
    String uid = auth.currentUser();
    if(uid != null){
      currentUser = User(uid: uid);
      _isUserLogged.add(true);
    }
    else 
      _isUserLogged.add(false);
  }

  void createUser() async{
    try{
      String uid = await auth.createUserWithEmailAndPassword(emailController.text, passwordController.text);
      currentUser = User(uid: uid);
      _isUserLogged.add(true);
      _authErrorMessage.add("");
    } catch(e){
      _isUserLogged.add(false);
      if (e.code == 'email-already-in-use') 
        _authErrorMessage.add('The account already exists.');
      else if (e.code == 'weak-password')
        _authErrorMessage.add('The password is too weak.\nIt has to be at least 6 chars.');
    }
  }
  
  void logIn( ) async{
    try{
      String uid = await auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
      currentUser = User(uid: uid);
      _isUserLogged.add(true);
      _authErrorMessage.add("");
    } catch(e){
      _isUserLogged.add(false);
      if (e.code == 'user-not-found' || e.code == 'wrong-password')
        _authErrorMessage.add("Wrong email or password.");
    }
  }

  void logOut() {
    auth.signOut();
    currentUser = null;
    _isUserLogged.add(false);
    clearControllers();
  }

  void clearControllers(){
    passwordController.clear();
    emailController.clear();
    getLoginForm().emailText.add(null);
    getLoginForm().passwordText.add(null);
  }

  Stream<bool> get isUserLogged => _isUserLogged.stream;

  Stream<String> get authErrorMessage => _authErrorMessage.stream;

  LoginForm getLoginForm() => loginForm;
}