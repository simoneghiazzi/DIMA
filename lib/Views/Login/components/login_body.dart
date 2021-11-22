import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/forgot_password_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/components/forgot_password.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/components/background.dart';
import 'package:dima_colombo_ghiazzi/Views/components/already_have_an_account_check.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_input_field.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_password_field.dart';
import 'package:provider/provider.dart';

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  GlobalKey<State> _keyLoader;
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    _keyLoader = new GlobalKey<State>();
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    BackButtonInterceptor.add(backButtonInterceptor);
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
            Text(
              "Login",
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
            SizedBox(height: size.height * 0.07),
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
            SizedBox(height: size.height * 0.01),
            ForgotPassword(
              press: () {
                FocusScope.of(context).unfocus();
                authViewModel.clearControllers();
                routerDelegate.pushPage(name: ForgotPasswordScreen.route);
              },
            ),
            SizedBox(height: size.height * 0.03),
            StreamBuilder(
                stream: authViewModel.loginForm.isLoginEnabled,
                builder: (context, snapshot) {
                  return RoundedButton(
                    text: "LOGIN",
                    press: () async {
                      FocusScope.of(context).unfocus();
                      LoadingDialog.show(context, _keyLoader);
                      var id = await authViewModel.logIn();
                      if (id == null) {
                        LoadingDialog.hide(context, _keyLoader);
                      }
                      navigateToHome(id);
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
            SizedBox(height: size.height * 0.01),
            AlreadyHaveAnAccountCheck(
              press: () {
                authViewModel.clearControllers();
                routerDelegate.replace(name: BaseUsersSignUpScreen.route);
              },
            ),
            SizedBox(height: size.height * 0.01),
          ],
        ),
      ),
    );
  }

  void navigateToHome(String id) async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    Collection collection =
        await firestoreService.findUsersCollection(authViewModel.id);
    switch (collection) {
      case Collection.BASE_USERS:
        var baseUserViewModel =
            Provider.of<BaseUserViewModel>(context, listen: false);
        baseUserViewModel.id = id;
        await baseUserViewModel.loadLoggedUser();
        LoadingDialog.hide(context, _keyLoader);
        routerDelegate.replace(name: BaseUserHomePageScreen.route);
        break;
      case Collection.EXPERTS:
        var expertViewModel =
            Provider.of<ExpertViewModel>(context, listen: false);
        expertViewModel.id = id;
        await expertViewModel.loadLoggedUser();
        LoadingDialog.hide(context, _keyLoader);
        routerDelegate.replace(name: ExpertHomePageScreen.route);
        break;
      default:
    }
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
