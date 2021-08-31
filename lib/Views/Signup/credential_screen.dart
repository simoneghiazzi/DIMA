import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/credential_body.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CredentialScreen extends StatelessWidget {
  static const route = '/credentialScreen';
  final BaseUserInfoViewModel infoViewModel;
  final UserViewModel userViewModel;

  CredentialScreen({
    Key key,
    @required this.infoViewModel,
    @required this.userViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppRouterDelegate routerDelegate =
        Provider.of<AppRouterDelegate>(context, listen: false);
    return Scaffold(
      body: WillPopScope(
          child: CredentialBody(
            infoViewModel: infoViewModel,
            userViewModel: userViewModel,
          ),
          onWillPop: () {
            routerDelegate.replaceAllButNumber(
                2, [RouteSettings(name: BaseUsersSignUpScreen.route)]);
            return Future.value(true);
          }),
    );
  }
}
