import 'package:flutter/material.dart';
import 'components/user_settings_body.dart';

class UserSettingsScreen extends StatelessWidget {
  static const route = '/userProfileScreen';

  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserSettingsBody(),
    );
  }
}
