import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:flutter/cupertino.dart';

import 'base_user_grid.dart';

class BaseUserHomePage extends StatefulWidget {
  @override
  _BaseUserHomePageState createState() => _BaseUserHomePageState();
}

class _BaseUserHomePageState extends State<BaseUserHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[Header(), Spacer(), BaseUserGrid(), Spacer()],
      ),
    );
  }
}
