import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/components/text_field_container.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final String errorText;
  const RoundedPasswordField({
    Key key,
    this.onChanged,
    this.controller,
    this.errorText
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        obscureText: true,
        onChanged: onChanged,  
        controller: controller,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          hintText: "Password",
          icon: Icon(
            Icons.lock,
            color: kPrimaryColor,
          ),
          suffixIcon: Icon(
            Icons.visibility,
            color: kPrimaryColor,
          ),
          border: InputBorder.none,
          errorText: errorText,
        ),
      ),
    );
  }
}
