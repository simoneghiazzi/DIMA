import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/welcome_body.dart';

class WelcomeScreen extends StatelessWidget {
  final AuthViewModel authViewModel;

  WelcomeScreen({Key key, this.authViewModel}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WelcomeBody(
        authViewModel: authViewModel,
      ),
    );
  }
}
