import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dashBg.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/homeBody.dart';

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
