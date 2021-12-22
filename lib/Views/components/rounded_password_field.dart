import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/components/text_field_container.dart';

/// Password field component used in authentication.
///
/// It takes the [controller] that controls the [TextField].
class RoundedPasswordField extends StatelessWidget {
  final String hintText;
  final String? errorText;
  final TextEditingController controller;

  /// Password field component used in authentication.
  ///
  /// It takes the [controller] that controls the [TextField].
  const RoundedPasswordField({Key? key, required this.controller, this.hintText = "Password", this.errorText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        controller: controller,
        cursorColor: kPrimaryColor,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: kPrimaryDarkColor),
          icon: Icon(Icons.lock, color: kPrimaryColor),
          border: InputBorder.none,
          errorText: errorText,
        ),
      ),
    );
  }
}
