import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_password_field.dart';

class CredentialBody extends StatefulWidget {
  final AuthViewModel authViewModel;
  final BaseUserInfoViewModel infoViewModel;
  final UserViewModel userViewModel;

  CredentialBody(
      {Key key,
      @required this.authViewModel,
      @required this.infoViewModel,
      @required this.userViewModel})
      : super(key: key);

  @override
  _CredentialBodyState createState() => _CredentialBodyState(
      authViewModel: this.authViewModel,
      infoViewModel: this.infoViewModel,
      userViewModel: userViewModel);
}

class _CredentialBodyState extends State<CredentialBody> {
  final AuthViewModel authViewModel;
  final BaseUserInfoViewModel infoViewModel;
  final UserViewModel userViewModel;
  User user;
  bool loading = true;
  StreamSubscription<bool> subscriber;

  _CredentialBodyState(
      {@required this.authViewModel,
      @required this.infoViewModel,
      @required this.userViewModel});

  @override
  void initState() {
    subscriber = subscribeToViewModel();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => authViewModel.getData());
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
            SizedBox(height: size.height * 0.08),
            Text(
              "Email and password",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: size.height * 0.08),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.06),
            StreamBuilder<String>(
                stream: authViewModel.loginForm.errorEmailText,
                builder: (context, snapshot) {
                  return RoundedInputField(
                    hintText: "Your Email",
                    controller: authViewModel.emailController,
                    errorText: snapshot.data,
                  );
                }),
            RoundedPasswordField(
              controller: authViewModel.passwordController,
            ),
            StreamBuilder(
                stream: authViewModel.loginForm.isButtonEnabled,
                builder: (context, snapshot) {
                  return RoundedButton(
                    text: "SIGN UP",
                    press: () {
                      if (loading)
                        LoadingDialog.show(context,
                            text: 'Creating a new user...');
                      user = userViewModel.createUser(infoViewModel);
                      authViewModel.signUpUser(user).then((value) {
                        user.id = value;
                        setState(() {
                          loading = false;
                        });
                      });
                    },
                    enabled: snapshot.data ?? false,
                  );
                }),
            SizedBox(height: size.height * 0.01),
            StreamBuilder<String>(
                stream: authViewModel.authMessage,
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
                        authViewModel: authViewModel,
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
    return authViewModel.isUserCreated.listen((isSuccessfulLogin) {
      if (isSuccessfulLogin) {
        showSnackBar();
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return LoginScreen(
            authViewModel: authViewModel,
          );
        }));
      }
    });
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Please check your email for the verification link.'),
      action: SnackBarAction(
        label: 'RESEND EMAIL',
        onPressed: () {
          authViewModel.resendEmailVerification(user);
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          showSnackBar();
        },
      ),
      duration: const Duration(seconds: 100),
    ));
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
