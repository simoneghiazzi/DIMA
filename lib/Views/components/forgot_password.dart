import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class ForgotPassword extends StatelessWidget {
  final Function? press;
  const ForgotPassword({
    Key? key,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press as void Function()?,
      child: Text(
        "Forgot Password?",
        style: TextStyle(
          color: kPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
