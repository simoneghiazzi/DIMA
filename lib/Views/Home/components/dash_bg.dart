import 'package:flutter/material.dart';

class DashBg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo[400], Colors.cyan[200]])),
          ),
          flex: 2,
        ),
        Expanded(
          child: Container(color: Colors.transparent),
          flex: 6,
        ),
      ],
    );
  }
}
