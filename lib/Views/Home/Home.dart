import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/dashBg.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/homeBody.dart';

class Home extends StatelessWidget {

  final AuthViewModel authViewModel;

  Home({Key key, @required this.authViewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[DashBg(), HomeBody(authViewModel: authViewModel,)],
      ),
    );
  }
}
