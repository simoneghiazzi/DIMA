import 'package:flutter/material.dart';
import 'components/user_settings_body.dart';

class UserSettingsScreen extends StatelessWidget {
  static const route = '/userProfileScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserSettingsBody(),
    );
  }
}
