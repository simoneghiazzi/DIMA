import 'package:flutter/material.dart';
import 'components/user_settings_body.dart';

/// It contains the [UserSettingsBody] that is used to show the user profile
/// information and the authentication information.
class UserSettingsScreen extends StatelessWidget {
  /// Route of the page used by the Navigator.
  static const route = "/userProfileScreen";

  /// It contains the [UserSettingsBody] that is used to show the user profile
  /// information and the authentication information.
  const UserSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserSettingsBody(),
    );
  }
}
