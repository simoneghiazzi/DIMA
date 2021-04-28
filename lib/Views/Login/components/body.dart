import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/signup_screen.dart';
import 'package:dima_colombo_ghiazzi/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/components/rounded_password_field.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  final _authViewModel = AuthViewModel();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState(){
    _emailController.addListener(() => _authViewModel.emailText.add(_emailController.text));
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
              stream: _authViewModel.errorText,
              builder: (context, snapshot) {
                return RoundedInputField(
                  hintText: "Your Email",
                  controller: _emailController,
                  errorText: snapshot.data,
                );
              }
            ),
            RoundedPasswordField(
              controller: _passwordController,
            ),
            StreamBuilder(
              stream: _authViewModel.isButtonEnabled,
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
                      return SignUpScreen();
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
