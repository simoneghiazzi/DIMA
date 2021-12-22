import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/components/text_field_container.dart';

/// Input field component used in the authentication.
///
/// It takes the [icon] that is drawn before the input text
/// and the [controller] that controls the [TextField].
class RoundedInputField extends StatelessWidget {
  final String hintText;
  final String? errorText;
  final IconData icon;
  final TextEditingController controller;

  /// Input field component used in the entire application.
  ///
  /// It takes the [icon] that is drawn before the input text
  /// and the [controller] that controls the [TextField].
  const RoundedInputField({Key? key, required this.hintText, this.errorText, this.icon = Icons.email, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        controller: controller,
        cursorColor: kPrimaryColor,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          icon: Icon(icon, color: kPrimaryColor),
          hintText: hintText,
          hintStyle: TextStyle(color: kPrimaryDarkColor),
          border: InputBorder.none,
          errorText: errorText,
        ),
      ),
    );
  }
}
