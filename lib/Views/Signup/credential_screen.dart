import 'package:sApport/Views/Signup/components/credential_body.dart';
import 'package:flutter/material.dart';

class CredentialScreen extends StatelessWidget {
  static const route = '/credentialScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CredentialBody(),
    );
  }
}
