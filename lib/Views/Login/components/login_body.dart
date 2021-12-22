import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/rounded_input_field.dart';
import 'package:sApport/Views/components/rounded_password_field.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  // View Models
  late AuthViewModel authViewModel;
  UserViewModel? userViewModel;
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    BackButtonInterceptor.add(backButtonInterceptor);
    WidgetsBinding.instance!.addPostFrameCallback((_) => authViewModel.getData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
            ),
            SizedBox(height: 2.h),
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
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                authViewModel.clearControllers();
                routerDelegate.pushPage(name: ForgotPasswordScreen.route);
              },
              child: Text(
                "Forgot Password?",
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 4.h),
            StreamBuilder(
                stream: authViewModel.loginForm.isLoginEnabled,
                builder: (context, AsyncSnapshot snapshot) {
                  return RoundedButton(
                    text: "LOGIN",
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      LoadingDialog.show(context);
                      authViewModel.logIn();
                    },
                    enabled: snapshot.data ?? false,
                  );
                }),
            SizedBox(height: 5.h),
            StreamBuilder<String?>(
              stream: authViewModel.authMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
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
                      SizedBox(height: 5.h),
                    ],
                  );
                } else {
                  return SizedBox(height: 5.h);
                }
              },
            ),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Sign Up",
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
                routerDelegate.replace(name: BaseUsersSignUpScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    authViewModel.clearControllers();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
