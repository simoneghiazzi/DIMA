import 'package:sApport/ViewModel/Forms/base_user_signup_form.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Signup/components/credential_body.dart';
import 'package:flutter/material.dart';

class CredentialScreen extends StatelessWidget {
  static const route = '/credentialScreen';
  final BaseUserSignUpForm infoViewModel;
  final UserViewModel userViewModel;

  CredentialScreen({
    Key key,
    @required this.infoViewModel,
    @required this.userViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CredentialBody(
        infoViewModel: infoViewModel,
        userViewModel: userViewModel,
      ),
    );
  }
}
