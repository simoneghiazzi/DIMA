import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/components/base_user_info_body.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

class BaseUsersSignUpScreen extends StatelessWidget {
  final authViewModel;

  BaseUsersSignUpScreen({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: BaseUserInfoBody(
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
