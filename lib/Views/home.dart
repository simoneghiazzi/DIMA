import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/components/HomeComponents/dashBg.dart';
import 'package:dima_colombo_ghiazzi/components/HomeComponents/homeBody.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[DashBg(), HomeBody()],
      ),
    );
  }
}
