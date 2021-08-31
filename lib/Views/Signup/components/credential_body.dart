import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_info_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_acheck.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_password_field.dart';
import 'package:provider/provider.dart';

class CredentialBody extends StatefulWidget {
  final BaseUserInfoViewModel infoViewModel;
  final UserViewModel userViewModel;

  CredentialBody({
    Key key,
    @required this.infoViewModel,
    @required this.userViewModel,
  }) : super(key: key);

  @override
  _CredentialBodyState createState() => _CredentialBodyState(
        infoViewModel: this.infoViewModel,
      );
}

class _CredentialBodyState extends State<CredentialBody> {
  final BaseUserInfoViewModel infoViewModel;
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  User user;
  bool loading = true;
  StreamSubscription<bool> subscriber;

  _CredentialBodyState({
    @required this.infoViewModel,
  });

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
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
                      // LoadingDialog.show(context, _keyLoader, text: 'Creating a new user...');
                      infoViewModel.email = authViewModel.emailController.text;
                      user = widget.userViewModel.createUser(infoViewModel);
                      authViewModel.signUpUser(user);
                    },
                    enabled: snapshot.data ?? false,
                  );
                }),
            SizedBox(height: size.height * 0.01),
            StreamBuilder<String>(
                stream: authViewModel.authMessage,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
                  }
                  return RichText(
                      text: TextSpan(
                          text: snapshot.data,
                          style: TextStyle(color: Colors.red, fontSize: 15)));
                }),
            SizedBox(height: size.height * 0.03),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                routerDelegate.replace(name: LoginScreen.route);
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
        routerDelegate.pushPage(name: LoginScreen.route);
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
