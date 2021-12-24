import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Welcome/components/welcome_body.dart';

/// Social Icon used in the [WelcomeBody] and in the [UserSettingsBody].
///
/// It contains the [iconSrc] image and executes the [onTap] callback
/// when it is pressed.
class SocialIcon extends StatelessWidget {
  final String iconSrc;
  final Function onTap;

  /// Social Icon used in the [WelcomeBody] and in the [UserSettingsBody].
  ///
  /// It contains the [iconSrc] image and executes the [onTap] callback
  /// when it is pressed.
  const SocialIcon({Key? key, required this.iconSrc, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function(),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(width: 1, color: kPrimaryLightColor), shape: BoxShape.circle),
        child: Image.asset(iconSrc, height: 40, width: 40),
      ),
    );
  }
}
