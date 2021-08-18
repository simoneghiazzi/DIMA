import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dash_bg.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/body.dart';

class Home extends StatelessWidget {
  final AuthViewModel authViewModel;

  Home({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              DashBg(),
              HomeBody(
                authViewModel: authViewModel,
              )
            ],
          ),
        ));
  }
}
