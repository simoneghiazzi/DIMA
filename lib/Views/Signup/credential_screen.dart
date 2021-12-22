import 'package:flutter/material.dart';
import 'package:sApport/Views/Signup/components/credential_body.dart';

class CredentialScreen extends StatelessWidget {
  static const route = "/credentialScreen";

  const CredentialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CredentialBody(),
    );
  }
}
