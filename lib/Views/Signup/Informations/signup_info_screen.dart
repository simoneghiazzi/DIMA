import 'package:dima_colombo_ghiazzi/Views/Signup/Informations/components/info_body.dart';
import 'package:flutter/material.dart';

class SignUpInfo extends StatelessWidget {
  final authViewModel;

  SignUpInfo({Key key, this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InfoBody(
        authViewModel: authViewModel,
      ),
    );
  }
}
