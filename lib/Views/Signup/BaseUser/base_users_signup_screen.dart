import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/components/base_user_info_body.dart';
import 'package:flutter/material.dart';

class BaseUsersSignUpScreen extends StatelessWidget {
  static const route = '/baseUsersSignUpScreen';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseUserInfoBody(),
    );
  }
}
