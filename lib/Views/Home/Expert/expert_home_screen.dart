import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/Expert/components/expert_grid.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/components/header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertHomeScreen extends StatelessWidget {
  static const route = '/expertHomeScreen';
  @override
  Widget build(BuildContext context) {
    var expertViewModel = Provider.of<ExpertViewModel>(context, listen: false);
    var authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    authViewModel.setNotification(expertViewModel.loggedUser);
    Size size = MediaQuery.of(context).size;
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Header(loggedUser: expertViewModel.loggedUser),
                SizedBox(height: size.height * 0.15),
                ExpertGrid()
              ],
            ),
          ),
        ));
  }
}
