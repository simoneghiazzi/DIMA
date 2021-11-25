import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:sApport/ViewModel/Expert/expert_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:sApport/Views/Login/forgot_password_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/components/forgot_password.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/components/background.dart';
import 'package:sApport/Views/components/already_have_an_account_check.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/rounded_input_field.dart';
import 'package:sApport/Views/components/rounded_password_field.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class LoginBody extends StatefulWidget {
  @override
  _LoginBodyState createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody> {
  GlobalKey<State> _keyLoader;
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  FirestoreService firestoreService = GetIt.I<FirestoreService>();

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
                    controller: authViewModel.emailCtrl,
                    errorText: snapshot.data,
                  );
                }),
            RoundedPasswordField(
              controller: authViewModel.pswCtrl,
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
                      } else {
                        navigateToHome(id);
                      }
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
            SizedBox(height: size.height * 0.02),
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
        await firestoreService.findUsersCollection(authViewModel.loggedId);
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
