import 'dart:async';
import 'package:dima_colombo_ghiazzi/Views/Home/home.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/authViewModel.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'or_divider.dart';
import 'social_icon.dart';

class Body extends StatefulWidget {
  final AuthViewModel authViewModel;

  Body({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  StreamSubscription<bool> subscriber;

  @override
  void initState() {
    subscriber = subscribeToViewModel();
    widget.authViewModel.alreadyLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // This size provide us total height and width of our screen
    return Background(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "WELCOME TO APPrension",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.05),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              text: "LOGIN",
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen(
                        authViewModel: widget.authViewModel,
                      );
                    },
                  ),
                );
              },
            ),
            RoundedButton(
              text: "SIGN UP",
              color: kPrimaryLightColor,
              textColor: Colors.black,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen(
                        authViewModel: widget.authViewModel,
                      );
                    },
                  ),
                );
              },
            ),
            OrDivider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocalIcon(
                  iconSrc: "assets/icons/facebook.png",
                  press: () => widget.authViewModel.logInWithFacebook(),
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google.png",
                  press: () => widget.authViewModel.logInWithGoogle(),
                ),
              ],
            ),
            StreamBuilder<String>(
                stream: widget.authViewModel.authMessage,
                builder: (context, snapshot) {
                  return Container(
                      padding: EdgeInsets.all(20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: snapshot.data,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 15))));
                }),
          ],
        ),
      ),
    );
  }

  StreamSubscription<bool> subscribeToViewModel() {
    return widget.authViewModel.isUserLogged.listen((isSuccessfulLogin) {
      if (isSuccessfulLogin) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Home(
            authViewModel: widget.authViewModel,
          );
        }));
      }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
