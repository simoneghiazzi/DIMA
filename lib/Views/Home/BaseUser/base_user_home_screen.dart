import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/components/base_user_grid.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:flutter/material.dart';

class BaseUserHomeScreen extends StatelessWidget {
  final AuthViewModel authViewModel;
  final BaseUserViewModel baseUserViewModel;

  BaseUserHomeScreen(
      {Key key, @required this.authViewModel, @required this.baseUserViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    authViewModel.setNotification(baseUserViewModel.loggedUser);
    Size size = MediaQuery.of(context).size;
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Header(
                    authViewModel: authViewModel,
                    userViewModel: baseUserViewModel),
                SizedBox(height: size.height * 0.15),
                BaseUserGrid(baseUserViewModel: baseUserViewModel)
              ],
            ),
          ),
        ));
  }
}
