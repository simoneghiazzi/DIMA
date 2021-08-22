import 'dart:async';
import 'package:dima_colombo_ghiazzi/Views/Home/home.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Experts/signup_experts_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Users/signup_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
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
    widget.authViewModel.isAlreadyLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This size provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "APPrension",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: size.height * 0.07),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.07),
            ElevatedButton(
              onPressed: () {
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
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                      Size(size.width / 2, size.height / 20)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29)))),
              child: Text('LOGIN'),
            ),
            SizedBox(height: size.height * 0.02),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpUsers(
                        authViewModel: widget.authViewModel,
                      );
                    },
                  ),
                );
              },
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                      Size(size.width / 2, size.height / 20)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryLightColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29)))),
              child: Text(
                'SIGNUP',
                style: TextStyle(color: Colors.black),
              ),
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
            SizedBox(height: size.height * 0.05),
            GestureDetector(
              child: Text(
                "Are you a psychologist? Join us",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpExperts(
                        authViewModel: widget.authViewModel,
                      );
                    },
                  ),
                );
              },
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
        subscriber.cancel();
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Home(
            authViewModel: widget.authViewModel,
          );
        }));
      }
    });
  }
}
