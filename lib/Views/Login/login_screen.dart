import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/login_body.dart';

/// It contains the [LoginBody] used for the login process of the user.
class LoginScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/loginScreen";

  /// It contains the [LoginBody] used for the login process of the user.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBody(),
    );
  }
}
