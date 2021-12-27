import 'package:sApport/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/components/social_icon.dart';
import 'package:sApport/Views/Welcome/components/welcome_body.dart';

/// Divider used in the [WelcomeBody] before the [SocialIcon]s.
class OrDivider extends StatelessWidget {
  /// Divider used in the [WelcomeBody] before the [SocialIcon]s.
  const OrDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.h),
      width: 80.w,
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: Color(0xFFD9D9D9), height: 1.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text("OR", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.w600, fontSize: 10.sp)),
          ),
          Expanded(child: Divider(color: Color(0xFFD9D9D9), height: 1.5)),
        ],
      ),
    );
  }
}
