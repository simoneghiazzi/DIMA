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
  }

  void alreadyLogged(){
    String uid = auth.currentUser();
    if(uid != null){
      currentUser = User(uid: uid);
      _loginController.add(true);
    }
    else 
      _loginController.add(false);
  }

  void createUser() async{
    String uid = await auth.createUserWithEmailAndPassword(emailController.text, passwordController.text);
    if(uid != null){
      currentUser = User(uid: uid);
      _loginController.add(true);
    }
    else 
      _loginController.add(false);
  }
  
  void logIn( ) async{
    String uid = await auth.signInWithEmailAndPassword(emailController.text, passwordController.text);
    if(uid != null){
      currentUser = User(uid: uid);
      _loginController.add(true);
    }
    else 
      _loginController.add(false);
  } 

  void logOut() async{
    await auth.signOut();
    currentUser = null;
    _loginController.add(false);
    clearControllers();
  }

  void clearControllers(){
    passwordController.clear();
    emailController.clear();
    getLoginForm().emailText.add(null);
    getLoginForm().passwordText.add(null);
  }

  Stream<bool> get isUserLogged => _loginController.stream;

  LoginForm getLoginForm() => loginForm;
}