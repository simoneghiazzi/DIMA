import 'package:flutter/material.dart';
import 'package:sApport/constants.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget? child;
  const TextFieldContainer({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        color: kPrimaryLightColor.withAlpha(100),
        borderRadius: BorderRadius.circular(25),
      ),
      child: child,
    );
  }
}
