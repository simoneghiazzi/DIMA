import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/Informations/info_experts.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

class SignUpExperts extends StatelessWidget {
  final authViewModel;

  SignUpExperts({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: InfoExperts(
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
