import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/body.dart';

class WelcomeScreen extends StatelessWidget {

  final AuthViewModel authViewModel;

  WelcomeScreen({Key key, @required this.authViewModel}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(authViewModel: authViewModel,),
    );
  }
}
