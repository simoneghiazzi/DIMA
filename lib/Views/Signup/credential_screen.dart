import 'package:flutter/material.dart';
import 'package:sApport/Views/Signup/components/credential_body.dart';

/// It contains the [CredentialBody] used for the sign up process of the user.
class CredentialScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/credentialScreen";

  /// It contains the [CredentialBody] used for the sign up process of the user.
  const CredentialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CredentialBody(),
    );
  }
}
