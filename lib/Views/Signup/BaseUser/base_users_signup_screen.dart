import 'package:flutter/material.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Signup/BaseUser/components/base_user_info_body.dart';

/// It contains the [BaseUserInfoBody] used for the sign up process of the [BaseUser].
class BaseUsersSignUpScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/baseUsersSignUpScreen";

  /// It contains the [BaseUserInfoBody] used for the sign up process of the [BaseUser].
  const BaseUsersSignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BaseUserInfoBody(),
    );
  }
}
