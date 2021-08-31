import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/welcome_body.dart';

class WelcomeScreen extends StatelessWidget {
  static const route = '/welcomeScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeBody(),
    );
  }
}
