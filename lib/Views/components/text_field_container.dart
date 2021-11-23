import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  const TextFieldContainer({
    Key key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        border: Border.all(color: kPrimaryColor),
        color: kPrimaryLightColor.withAlpha(100),
        borderRadius: BorderRadius.circular(25),
      ),
      child: child,
    );
  }
}
