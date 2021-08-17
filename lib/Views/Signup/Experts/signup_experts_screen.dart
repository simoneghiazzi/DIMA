import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/Informations/info_experts.dart';
import 'package:flutter/material.dart';

class SignUpExperts extends StatelessWidget {
  final authViewModel;

  SignUpExperts({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InfoExperts(
        authViewModel: authViewModel,
      ),
    );
  }
}
