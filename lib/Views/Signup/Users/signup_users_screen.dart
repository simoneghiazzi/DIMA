import 'package:dima_colombo_ghiazzi/Views/Signup/Users/Informations/info_body.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

class SignUpUsers extends StatelessWidget {
  final authViewModel;

  SignUpUsers({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: InfoBody(
          authViewModel: authViewModel,
        ),
        onWillPop: () async =>
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return WelcomeScreen(authViewModel: authViewModel);
          },
        ), (route) => true),
      ),
    );
  }
}
