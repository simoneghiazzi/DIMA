import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/signup_screen.dart';
import 'package:dima_colombo_ghiazzi/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_password_field.dart';

class Body extends StatefulWidget {

  final authViewModel;

  Body({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Background(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "LOGIN",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height * 0.03),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.03),
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
                return RoundedButton(text: "LOGIN", press: () {}, enabled: snapshot.data ?? false,);
            }),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return SignUpScreen(authViewModel: widget.authViewModel,);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
