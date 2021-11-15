import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:flutter/material.dart';
import 'components/user_profile_body.dart';

class UserProfileScreen extends StatelessWidget {
  static const route = '/userProfileScreen';
  final User user;

  UserProfileScreen({Key key, @required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: UserProfileBody(
        user: user,
      ),
    );
  }
}
