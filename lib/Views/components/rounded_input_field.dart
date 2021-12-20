import 'package:flutter/material.dart';
import 'package:sApport/Views/components/text_field_container.dart';
import 'package:sApport/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String? hintText;
  final String? errorText;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const RoundedInputField({Key? key, this.hintText, this.errorText, this.icon = Icons.person, this.onChanged, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        cursorColor: kPrimaryColor,
        style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: kPrimaryColor),
          border: InputBorder.none,
          errorText: errorText,
        ),
      ),
    );
  }
}
