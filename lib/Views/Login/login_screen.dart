import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/login_body.dart';

class LoginScreen extends StatelessWidget {
  static const route = '/loginScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBody(),
    );
  }
}
