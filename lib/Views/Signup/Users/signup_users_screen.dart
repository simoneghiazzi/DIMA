import 'package:dima_colombo_ghiazzi/Views/Signup/Users/Informations/info_body.dart';
import 'package:flutter/material.dart';

class SignUpUsers extends StatelessWidget {
  final authViewModel;

  SignUpUsers({Key key, this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InfoBody(
        authViewModel: authViewModel,
      ),
    );
  }
}
