import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/user_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/base_user_home_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Signup/Expert/experts_signup_screen.dart';
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
              "APPrension",
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            SizedBox(height: size.height * 0.07),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.15,
            ),
            SizedBox(height: size.height * 0.07),
            ElevatedButton(
              onPressed: () {
                routerDelegate.pushPage(name: LoginScreen.route);
              },
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                      Size(size.width / 2, size.height / 20)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29)))),
              child: Text('LOGIN'),
            ),
            SizedBox(height: size.height * 0.02),
            ElevatedButton(
              onPressed: () {
                routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
              },
              style: ButtonStyle(
                  fixedSize: MaterialStateProperty.all<Size>(
                      Size(size.width / 2, size.height / 20)),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(kPrimaryLightColor),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29)))),
              child: Text(
                'SIGNUP',
                style: TextStyle(color: Colors.black),
              ),
            ),
            OrDivider(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SocialIcon(
                  iconSrc: "assets/icons/facebook.png",
                  press: () async {
                    id = await authViewModel.logInWithFacebook();
                    if (id != null) navigateToHome();
                  }),
              SocialIcon(
                  iconSrc: "assets/icons/google.png",
                  press: () async {
                    id = await authViewModel.logInWithGoogle();
                    if (id != null) navigateToHome();
                  }),
            ]),
            SizedBox(height: size.height * 0.05),
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
    routerDelegate.pushPage(name: BaseUserHomeScreen.route);
  }
}
