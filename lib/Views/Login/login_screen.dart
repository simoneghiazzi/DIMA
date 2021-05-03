import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/components/body.dart';

class LoginScreen extends StatelessWidget {

  final authViewModel;

  LoginScreen({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(authViewModel: authViewModel,),
    );
  }
}
