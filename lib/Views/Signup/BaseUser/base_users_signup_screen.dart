import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/components/base_user_info_body.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseUsersSignUpScreen extends StatelessWidget {
  static const route = '/baseUsersSignUpScreen';
  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    return Scaffold(
      body: WillPopScope(
          child: BaseUserInfoBody(),
          onWillPop: () {
            routerDelegate.replaceAllButNumber(
                1, [RouteSettings(name: WelcomeScreen.route)]);
            return Future.value(true);
          }),
    );
  }
}
