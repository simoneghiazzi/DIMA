import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Views/Utils/sizer.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/form_text_field.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/ViewModel/Forms/Authentication/login_form.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';

/// Body of the [LoginScreen].
///
/// It contains the [LoginForm] with the [FormTextField]s for signing in the user.
class LoginBody extends StatefulWidget {
  /// Body of the [LoginScreen].
  ///
  /// It contains the [LoginForm] with the [FormTextField]s for signing in the user.
  const LoginBody({Key? key}) : super(key: key);

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

    // Add a back button interceptor for listening to the OS back button
    BackButtonInterceptor.add(backButtonInterceptor);

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
              // Title
              Text(
                "sApport",
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50.sp, fontFamily: "Gabriola"),
              ),
              SizedBox(height: 3.h),
              // Form
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
                          inputDecorationTheme: InputDecorationTheme(border: OutlineInputBorder(borderRadius: BorderRadius.circular(25))),
                        ),
                        child: FormBlocListener<LoginForm, String, String>(
                          onSuccess: (context, state) {
                            LoadingDialog.show(context);
                            authViewModel.logIn(loginForm.emailText.value, loginForm.passwordText.value);
                          },
                          child: Column(
                            children: <Widget>[
                              FormTextField(
                                textFieldBloc: loginForm.emailText,
                                hintText: "Email",
                                prefixIconData: Icons.email,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              FormTextField(
                                textFieldBloc: loginForm.passwordText,
                                hintText: "Password",
                                prefixIconData: Icons.lock,
                                suffixButton: SuffixButton.obscureText,
                                textCapitalization: TextCapitalization.none,
                              ),
                              SizedBox(height: 2.h),
                              // Forgot Password Button
                              GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  routerDelegate.pushPage(name: ForgotPasswordScreen.route);
                                },
                                child: Text("Forgot Password?", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 10.sp)),
                              ),
                              SizedBox(height: 5.h),
                              // Login Button
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
              // Stream of the authMessage
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
                            text: TextSpan(text: snapshot.data, style: TextStyle(color: Colors.red, fontSize: 14.5.sp, fontWeight: FontWeight.bold)),
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
              // Go to SignUp Button
              GestureDetector(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: TextStyle(color: kPrimaryColor, fontSize: 12.sp)),
                    Text("Sign Up", style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12.5.sp)),
                  ],
                ),
                onTap: () {
                  authViewModel.clearAuthMessage();
                  routerDelegate.replace(name: BaseUsersSignUpScreen.route);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function called by the back button interceptor.
  ///
  /// It remove the current auth message if it is present and then pop the page.
  bool backButtonInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    authViewModel.clearAuthMessage();
    routerDelegate.pop();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(backButtonInterceptor);
    super.dispose();
  }
}
