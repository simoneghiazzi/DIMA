import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBarExperts extends StatefulWidget {
  final String text;
  final InkWell button;

  TopBarExperts({Key key, @required this.text, @required this.button})
      : super(key: key);

  @override
  _TopBarExpertsState createState() => _TopBarExpertsState();
}

class _TopBarExpertsState extends State<TopBarExperts> {
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
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SafeArea(
          child: SizedBox(
            width: size.width,
            child: Padding(
              padding:
                  EdgeInsets.only(right: 30, left: 30, top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  AutoSizeText(
                    widget.text,
                    style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor),
                    maxLines: 1,
                  ),
                  Spacer(),
                  widget.button ?? Container(),
                ],
              ),
            ),
          ),
        ),
        Divider(
          color: Color(0xFFD9D9D9),
          height: 1.5,
        ),
      ],
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
