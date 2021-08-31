import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Expert/components/experts_info_body.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpertsSignUpScreen extends StatelessWidget {
  static const route = '/expertsSignUpScreen';
  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    return Scaffold(
      body: WillPopScope(
          child: ExpertsInfoBody(),
          onWillPop: () {
            routerDelegate.replaceAllButNumber(
                1, [RouteSettings(name: WelcomeScreen.route)]);
            return Future.value(true);
          }),
    );
  }
}
