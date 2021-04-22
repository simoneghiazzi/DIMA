import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/components/HomeComponents/header.dart';
import 'package:dima_colombo_ghiazzi/components/HomeComponents/grid.dart';

class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
          children: <Widget>[
            Header(),
            Grid(),
          ],
        ),
      );
  }
}