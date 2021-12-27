import 'package:flutter/material.dart';
import 'package:sApport/Views/Signup/components/credential_body.dart';
import 'package:sApport/Views/Signup/BaseUser/components/base_user_info_body.dart';
import 'package:sApport/Views/Signup/Expert/components/experts_info_body.dart';

/// Background of the [BaseUserInfoBody], the [ExpertsInfoBody] and the [CredentialBody].
///
/// It takes the [child] that is shown above the background.
class Background extends StatelessWidget {
  final Widget child;

  /// Background of the [BaseUserInfoBody], the [ExpertsInfoBody] and the [CredentialBody].
  ///
  /// It takes the [child] that is shown above the background.
  const Background({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Top Left Image
          Positioned(top: 0, left: 0, child: Image.asset("assets/images/signup_top.png", scale: 2.5)),
          // Bottom Right Image
          Positioned(bottom: 0, right: 0, child: Image.asset("assets/images/login_bottom.png", scale: 2.5)),
          child,
        ],
      ),
    );
  }
}
