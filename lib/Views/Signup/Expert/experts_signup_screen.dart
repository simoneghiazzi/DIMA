import 'package:sApport/Views/Signup/Expert/components/experts_info_body.dart';
import 'package:flutter/material.dart';

class ExpertsSignUpScreen extends StatelessWidget {
  static const route = '/expertsSignUpScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ExpertsInfoBody());
  }
}
