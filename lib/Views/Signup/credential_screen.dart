import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUsers/base_users_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/credential_body.dart';
import 'package:flutter/material.dart';

class CredentialScreen extends StatelessWidget {
  final AuthViewModel authViewModel;
  final BaseUserInfoViewModel infoViewModel;
  final UserViewModel userViewModel;

  CredentialScreen(
      {Key key,
      @required this.authViewModel,
      @required this.infoViewModel,
      @required this.userViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: CredentialBody(
            authViewModel: authViewModel,
            infoViewModel: infoViewModel,
            userViewModel: userViewModel),
        onWillPop: () async =>
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return BaseUsersSignUpScreen(authViewModel: authViewModel);
          },
        ), (route) => true),
      ),
    );
  }
}
