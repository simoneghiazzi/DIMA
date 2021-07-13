import 'dart:async';
import 'package:dima_colombo_ghiazzi/ViewModel/authViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_password_field.dart';

class MailBody extends StatefulWidget {
  final AuthViewModel authViewModel;
  final String name, surname;
  final DateTime birthDate;

  MailBody(
      {Key key,
      @required this.authViewModel,
      @required this.name,
      @required this.surname,
      @required this.birthDate})
      : super(key: key);

  @override
  _MailBodyState createState() => _MailBodyState();
}

class _MailBodyState extends State<MailBody> {
  StreamSubscription<bool> subscriber;

  @override
  void initState() {
    subscriber = subscribeToViewModel();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => widget.authViewModel.getData());
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
                }),
            RoundedPasswordField(
              controller: widget.authViewModel.passwordController,
            ),
            StreamBuilder(
                stream: widget.authViewModel.getLoginForm().isButtonEnabled,
                builder: (context, snapshot) {
                  return RoundedButton(
                    text: "SIGN UP",
                    press: () => widget.authViewModel.createUser(),
                    enabled: snapshot.data ?? false,
                  );
                }),
            SizedBox(height: size.height * 0.01),
            StreamBuilder<String>(
                stream: widget.authViewModel.authMessage,
                builder: (context, snapshot) {
                  return RichText(
                      text: TextSpan(
                          text: snapshot.data,
                          style: TextStyle(color: Colors.red, fontSize: 15)));
                }),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
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
          ],
        ),
      ),
    );
  }

  StreamSubscription<bool> subscribeToViewModel() {
    return widget.authViewModel.isUserCreated.listen((isSuccessfulLogin) {
      if (isSuccessfulLogin) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Please check your email for verification link.'),
          action: SnackBarAction(
            label: 'RESEND EMAIL',
            onPressed: () {
              widget.authViewModel.resendEmailVerification();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'Please check again your email for verification link.'),
                duration: const Duration(seconds: 100),
              ));
            },
          ),
          duration: const Duration(seconds: 100),
        ));
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return LoginScreen(
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
