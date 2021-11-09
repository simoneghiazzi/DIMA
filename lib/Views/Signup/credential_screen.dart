import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/credential_body.dart';
import 'package:flutter/material.dart';

class CredentialScreen extends StatelessWidget {
  static const route = '/credentialScreen';
  final BaseUserInfoViewModel infoViewModel;
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
