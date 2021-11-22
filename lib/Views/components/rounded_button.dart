import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textColor;
  final double fontSize;
  final bool enabled;

  const RoundedButton({
    Key key,
    this.text,
    this.press,
    this.color = kPrimaryColor,
    this.enabled = true,
    this.textColor = Colors.white,
    this.fontSize = 15,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: ElevatedButton(
          style: ButtonStyle(
              fixedSize: MaterialStateProperty.all<Size>(
                  Size(size.width / 2, size.height / 20)),
              backgroundColor: MaterialStateProperty.all<Color>(
                  enabled ? color : Color.fromARGB(255, 211, 211, 211)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(29)))),
          onPressed: enabled ? press : null,
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: fontSize),
          ),
        ),
      ),
    );
  }
}
