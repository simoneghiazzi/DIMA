import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/components/base_user_grid.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseUserHomeScreen extends StatelessWidget {
  static const route = '/baseUserHomeScreen';
  @override
  Widget build(BuildContext context) {
    var baseUserViewModel =
        Provider.of<BaseUserViewModel>(context, listen: false);
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setNotification(baseUserViewModel.loggedUser);
    Size size = MediaQuery.of(context).size;
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Header(loggedUser: baseUserViewModel.loggedUser),
                SizedBox(height: size.height * 0.15),
                BaseUserGrid()
              ],
            ),
          ),
        ));
  }
}
