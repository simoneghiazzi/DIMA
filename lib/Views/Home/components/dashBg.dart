import 'package:flutter/material.dart';

class DashBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(color: Colors.deepPurple),
          flex: 2,
        ),
        Expanded(
          child: Container(color: Colors.transparent),
          flex: 5,
        ),
      ],
    );
  }
}
