import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/components/text_field_container.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String hintText;
  final String errorText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;

  const RoundedInputField(
      {Key key,
      this.hintText,
      this.errorText,
      this.icon = Icons.person,
      this.onChanged,
      this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        onChanged: onChanged,
        controller: controller,
        cursorColor: kPrimaryColor,
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
          errorText: errorText,
        ),
      ),
    );
  }
}
