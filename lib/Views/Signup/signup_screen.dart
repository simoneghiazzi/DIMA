import 'package:dima_colombo_ghiazzi/Views/Signup/components/infoBody.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/mailBody.dart';

class SignUpScreen extends StatelessWidget {
  final authViewModel;

  SignUpScreen({Key key, this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InfoBody(
        authViewModel: authViewModel,
      ),
    );
  }
}
