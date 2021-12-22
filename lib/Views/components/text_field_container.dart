import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

/// Box container of the password and input field.
class TextFieldContainer extends StatelessWidget {
  final Widget child;

  /// Box container of the password and input field.
  const TextFieldContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 80.w),
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: 80.w,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        color: kPrimaryLightColor.withAlpha(100),
        borderRadius: BorderRadius.circular(25),
      ),
      child: child,
    );
  }
}
