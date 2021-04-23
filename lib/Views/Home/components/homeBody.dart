import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/grid.dart';

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
