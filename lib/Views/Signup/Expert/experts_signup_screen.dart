import 'package:flutter/material.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Views/Signup/Expert/components/experts_info_body.dart';

/// It contains the [ExpertsInfoBody] used for the sign up process of the [Expert].
class ExpertsSignUpScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/expertsSignUpScreen";

  /// It contains the [ExpertsInfoBody] used for the sign up process of the [Expert].
  const ExpertsSignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ExpertsInfoBody(),
    );
  }
}
