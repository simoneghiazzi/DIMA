import 'dart:async';

import 'package:dima_colombo_ghiazzi/Views/Home/Home.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/or_divider.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/social_icon.dart';
import 'package:dima_colombo_ghiazzi/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_password_field.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.authViewModel.getData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "SIGNUP",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            StreamBuilder<String>(
              stream: widget.authViewModel.getLoginForm().errorEmailText,
              builder: (context, snapshot) {
                return RoundedInputField(
                  hintText: "Your Email",
                  controller: widget.authViewModel.emailController,
                  errorText: snapshot.data,
                );
              }
            ),
            RoundedPasswordField(
                  controller: widget.authViewModel.passwordController,             
            ),
            StreamBuilder(
              stream: widget.authViewModel.getLoginForm().isButtonEnabled,
              builder: (context, snapshot) {
                return RoundedButton(text: "SIGN UP", press: () => widget.authViewModel.createUser(), enabled: snapshot.data ?? false,);
            }),
            SizedBox(height: size.height * 0.01),
            StreamBuilder<String>(
              stream: widget.authViewModel.authErrorMessage,
              builder: (context, snapshot) {
                return RichText(
                  text: TextSpan(
                    text: snapshot.data, 
                    style: TextStyle(color: Colors.red, fontSize: 15))
                );
              }
            ),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return LoginScreen(authViewModel: widget.authViewModel,);
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
                  press: () {},
                ),
                SocalIcon(
                  iconSrc: "assets/icons/google.png",
                  press: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  StreamSubscription<bool> subscribeToViewModel(){
    return widget.authViewModel.isUserLogged.listen((isSuccessfulLogin) {
      if(isSuccessfulLogin){
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) {
              return Home(authViewModel: widget.authViewModel,);
            }
          )
        );
        }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }

}
