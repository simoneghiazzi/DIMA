import 'package:dima_colombo_ghiazzi/ViewModel/Experts/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/Experts/components/expert_grid.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:flutter/material.dart';

class ExpertHomeScreen extends StatelessWidget {
  final AuthViewModel authViewModel;
  final ExpertViewModel expertViewModel;

  ExpertHomeScreen(
      {Key key, @required this.authViewModel, @required this.expertViewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    authViewModel.setNotification(expertViewModel.loggedUser);
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
                    userViewModel: expertViewModel),
                SizedBox(height: size.height * 0.15),
                ExpertGrid(expertViewModel: expertViewModel)
              ],
            ),
          ),
        ));
  }
}
