import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Views/Login/components/background.dart';
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
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
            ),
            SizedBox(height: size.height * 0.02),
            StreamBuilder<String>(
                stream: authViewModel.loginForm.errorEmailText,
                builder: (context, snapshot) {
                  return RoundedInputField(
                    hintText: "Your Email",
                    controller: authViewModel.emailTextCtrl,
                    errorText: snapshot.data,
                  );
                }),
            RoundedPasswordField(
              controller: authViewModel.pswTextCtrl,
            ),
            StreamBuilder<String>(
              stream: authViewModel.loginForm.errorRepeatPasswordText,
              builder: (context, snapshot) {
                return RoundedPasswordField(controller: authViewModel.repeatPswTextCtrl, hintText: "Confirm Password", errorText: snapshot.data);
              },
            ),
            SizedBox(height: size.height * 0.04),
            StreamBuilder(
              stream: authViewModel.loginForm.isSignUpEnabled,
              builder: (context, snapshot) {
                return RoundedButton(
                  text: "SIGN UP",
                  press: () async {
                    FocusScope.of(context).unfocus();
                    LoadingDialog.show(context);
                    userViewModel.loggedUser.email = authViewModel.emailTextCtrl.text;
                    authViewModel.signUpUser(userViewModel.loggedUser);
                  },
                  enabled: snapshot.data ?? false,
                );
              },
            ),
            SizedBox(height: size.height * 0.05),
            StreamBuilder<String>(
              stream: authViewModel.authMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data.isNotEmpty) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(right: 10, left: 10),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: snapshot.data,
                            style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.05),
                    ],
                  );
                } else {
                  return SizedBox(height: size.height * 0.05);
                }
              },
            ),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              onTap: () {
                authViewModel.clearControllers();
                routerDelegate.replaceAllButNumber(1, routeSettingsList: [RouteSettings(name: LoginScreen.route)]);
              },
            ),
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
