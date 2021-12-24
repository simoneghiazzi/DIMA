import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/forgot_password_body.dart';

/// It contains the [ForgotPasswordBody] used for sending the link for resetting
/// the user account password.
class ForgotPasswordScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/forgotPasswordScreen";

  /// It contains the [ForgotPasswordBody] used for sending the link for resetting
  /// the user account password.
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ForgotPasswordBody(),
    );
  }
}
