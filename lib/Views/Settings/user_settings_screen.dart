import 'package:sApport/Model/user.dart';
import 'package:flutter/material.dart';
import 'components/user_settings_body.dart';

class UserSettingsScreen extends StatelessWidget {
  static const route = '/userProfileScreen';
  final User user;

  UserSettingsScreen({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserSettingsBody(
        user: user,
      ),
    );
  }
}
