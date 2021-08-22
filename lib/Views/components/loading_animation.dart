import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String text;

  Loading({this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
          ),
          Text(text)
        ]));
  }
}
