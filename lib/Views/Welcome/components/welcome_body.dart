import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/components/loading_dialog.dart';
import 'package:dima_colombo_ghiazzi/Views/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Login/login_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/components/background.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:provider/provider.dart';
import 'or_divider.dart';
import 'social_icon.dart';

class WelcomeBody extends StatefulWidget {
  @override
  _WelcomeBodyState createState() => _WelcomeBodyState();
}

class _WelcomeBodyState extends State<WelcomeBody> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  AuthViewModel authViewModel;
  BaseUserViewModel baseUserViewModel;
  String id;
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This size provide us total height and width of our screen
    Size size = MediaQuery.of(context).size;
    return Background(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "sApport",
              style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  fontFamily: 'Gabriola'),
            ),
            SizedBox(height: size.height * 0.03),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              press: () {
                routerDelegate.pushPage(name: LoginScreen.route);
              },
              text: "LOGIN",
            ),
            RoundedButton(
              press: () {
                routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
              },
              text: "SIGNUP",
              color: kPrimaryLightColor,
              textColor: Colors.black,
            ),
            OrDivider(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SocialIcon(
                  iconSrc: "assets/icons/facebook.png",
                  press: () async {
                    LoadingDialog.show(context, _keyLoader);
                    id = await authViewModel.logInWithFacebook();
                    LoadingDialog.hide(context, _keyLoader);
                    if (id != null) navigateToHome();
                  }),
              SocialIcon(
                  iconSrc: "assets/icons/google.png",
                  press: () async {
                    LoadingDialog.show(context, _keyLoader);
                    id = await authViewModel.logInWithGoogle();
                    LoadingDialog.hide(context, _keyLoader);
                    if (id != null) navigateToHome();
                  }),
            ]),
            StreamBuilder<String>(
                stream: authViewModel.authMessage,
                builder: (context, snapshot) {
                  return Container(
                      padding: EdgeInsets.all(20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              text: snapshot.data,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 15))));
                }),
            GestureDetector(
              child: Text(
                "Are you a psychologist? Join us",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              onTap: () {
                routerDelegate.pushPage(name: ExpertsSignUpScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  void navigateToHome() async {
    Provider<UserViewModel>.value(value: BaseUserViewModel());
    baseUserViewModel = Provider.of<BaseUserViewModel>(context, listen: false);
    baseUserViewModel.id = id;
    await baseUserViewModel.loadLoggedUser();
    routerDelegate.pushPage(name: BaseUserHomePageScreen.route);
  }
}
