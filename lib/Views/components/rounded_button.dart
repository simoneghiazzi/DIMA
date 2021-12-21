import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class RoundedButton extends StatelessWidget {
  final String? text;
  final Function? press;
  final Color color, textColor;
  final double fontSize;
  final bool enabled;

  const RoundedButton({
    Key? key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.enabled = true,
    this.textColor = Colors.white,
    this.fontSize = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 300, minHeight: 40),
      width: 50.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: ElevatedButton(
          style: ButtonStyle(
            fixedSize: MaterialStateProperty.all<Size>(Size(50.w, 5.h)),
            backgroundColor: MaterialStateProperty.all<Color>(
              enabled ? color : Color(0xFFD3D3D3),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          onPressed: enabled ? press as void Function()? : null,
          child: Text(
            text!,
            style: TextStyle(color: textColor, fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
