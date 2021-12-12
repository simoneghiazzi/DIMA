import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Views/Signup/components/background.dart';
import 'package:sApport/Views/components/already_have_an_account_check.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/rounded_input_field.dart';
import 'package:sApport/Views/components/rounded_password_field.dart';
import 'package:provider/provider.dart';

class CredentialBody extends StatefulWidget {
  @override
  _CredentialBodyState createState() => _CredentialBodyState();
}

class _CredentialBodyState extends State<CredentialBody> {
  // View Models
  AuthViewModel authViewModel;
  UserViewModel userViewModel;
  AppRouterDelegate routerDelegate;

  // Subscriber
  StreamSubscription<bool> subscriber;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    subscriber = subscribeToUserCreatedStream();
    BackButtonInterceptor.add(backButtonInterceptor);
    WidgetsBinding.instance.addPostFrameCallback((_) => authViewModel.getData());
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
                    controller: authViewModel.emailCtrl,
                    errorText: snapshot.data,
                  );
                }),
            RoundedPasswordField(
              controller: authViewModel.pswCtrl,
            ),
            StreamBuilder<String>(
                stream: authViewModel.loginForm.errorRepeatPasswordText,
                builder: (context, snapshot) {
                  return RoundedPasswordField(controller: authViewModel.repeatPswCtrl, hintText: "Confirm Password", errorText: snapshot.data);
                }),
            StreamBuilder(
                stream: authViewModel.loginForm.isSignUpEnabled,
                builder: (context, snapshot) {
                  return RoundedButton(
                    text: "SIGN UP",
                    press: () async {
                      FocusScope.of(context).unfocus();
                      LoadingDialog.show(context);
                      userViewModel.loggedUser.email = authViewModel.emailCtrl.text;
                      await authViewModel.signUpUser(userViewModel.loggedUser);
                    },
                    enabled: snapshot.data ?? false,
                  );
                }),
            SizedBox(height: size.height * 0.01),
            StreamBuilder<String>(
                stream: authViewModel.authMessage,
                builder: (context, snapshot) {
                  return RichText(text: TextSpan(text: snapshot.data, style: TextStyle(color: Colors.red, fontSize: 15)));
                }),
            SizedBox(height: size.height * 0.02),
            AlreadyHaveAnAccountCheck(
              login: false,
              press: () {
                authViewModel.clearControllers();
                routerDelegate.replaceAllButNumber(1, [RouteSettings(name: LoginScreen.route)]);
              },
            ),
            SizedBox(height: size.height * 0.06),
          ],
        ),
      ),
    );
  }

  StreamSubscription<bool> subscribeToUserCreatedStream() {
    return authViewModel.isUserCreated.listen((isUserCreated) {
      LoadingDialog.hide(context);
      if (isUserCreated) {
        showSnackBar();
        routerDelegate.pushPage(name: LoginScreen.route);
      }
    });
  }

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Please check your email for the verification link."),
      duration: const Duration(seconds: 10),
    ));
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    authViewModel.clearControllers();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    subscriber.cancel();
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
