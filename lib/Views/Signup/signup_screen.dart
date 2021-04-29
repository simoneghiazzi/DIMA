import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/body.dart';

class SignUpScreen extends StatelessWidget {

  final authViewModel;

  SignUpScreen({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(authViewModel: authViewModel,),
    );
  }
}
