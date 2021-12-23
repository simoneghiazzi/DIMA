import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/Forms/Authentication/login_form.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  // View Models
  late AuthViewModel authViewModel;
  late UserViewModel userViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Background(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Column(
            children: <Widget>[
              Text(
                "sApport",
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
              ),
              SizedBox(height: 3.h),
              Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: BlocProvider(
                  create: (context) => LoginForm(),
                  child: Builder(
                    builder: (context) {
                      final loginForm = BlocProvider.of<LoginForm>(context, listen: false);
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: kPrimaryColor,
                          inputDecorationTheme: InputDecorationTheme(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                        child: FormBlocListener<LoginForm, String, String>(
                          onSuccess: (context, state) {
                            LoadingDialog.show(context);
                            authViewModel.logIn(loginForm.emailText.value, loginForm.passwordText.value);
                          },
                          child: Column(
                            children: <Widget>[
                              TextFieldBlocBuilder(
                                textFieldBloc: loginForm.emailText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: kPrimaryDarkColor),
                                  prefixIcon: Icon(Icons.email, color: kPrimaryColor),
                                ),
                              ),
                              TextFieldBlocBuilder(
                                textFieldBloc: loginForm.passwordText,
                                suffixButton: SuffixButton.obscureText,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: kPrimaryLightColor.withAlpha(100),
                                  labelText: "Password",
                                  labelStyle: TextStyle(color: kPrimaryColor),
                                  prefixIcon: Icon(Icons.lock, color: kPrimaryColor),
                                ),
                              ),
                              SizedBox(height: 2.h),
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  routerDelegate.pushPage(name: ForgotPasswordScreen.route);
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 5.h),
                              RoundedButton(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  loginForm.submit();
                                },
                                text: "LOGIN",
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
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
                  routerDelegate.replace(name: BaseUsersSignUpScreen.route);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
