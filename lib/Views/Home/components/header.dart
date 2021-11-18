import 'dart:async';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  Header({Key key}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  StreamSubscription<bool> subscriber;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    subscriber = subscribeToViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kPrimaryColor),
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text(
              "sApport",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                  fontFamily: 'Gabriola'),
            ),
          ),
        ],
      ),
    );
  }

  StreamSubscription<bool> subscribeToViewModel() {
    return authViewModel.isUserLogged.listen((isSuccessfulLogin) {
      if (!isSuccessfulLogin) {
        subscriber.cancel();
        routerDelegate.replaceAll(name: WelcomeScreen.route);
      }
    });
  }
}
