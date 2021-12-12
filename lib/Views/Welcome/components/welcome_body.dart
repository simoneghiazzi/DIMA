import 'dart:async';
import 'package:sApport/Model/Services/collections.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/Views/Welcome/components/background.dart';
import 'package:sApport/constants.dart';
import 'package:provider/provider.dart';
import 'or_divider.dart';
import 'social_icon.dart';

class WelcomeBody extends StatefulWidget {
  @override
  _WelcomeBodyState createState() => _WelcomeBodyState();
}

class _WelcomeBodyState extends State<WelcomeBody> {
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
    subscriber = subscribeToUserLoggedStream();
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
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50, fontFamily: 'Gabriola'),
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
                  press: () {
                    LoadingDialog.show(context);
                    authViewModel.logInWithFacebook().catchError((_) => LoadingDialog.hide(context));
                  }),
              SocialIcon(
                  iconSrc: "assets/icons/google.png",
                  press: () {
                    LoadingDialog.show(context);
                    authViewModel.logInWithGoogle().catchError((_) => LoadingDialog.hide(context));
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
                        style: TextStyle(color: Colors.red, fontSize: 15),
                      ),
                    ),
                  );
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

  StreamSubscription<bool> subscribeToUserLoggedStream() {
    return authViewModel.isUserLogged.listen((isUserLogged) async {
      if (isUserLogged) {
        await userViewModel.loadLoggedUser().then((_) => print("User of category ${userViewModel.loggedUser.collection.value} logged"));
        LoadingDialog.hide(context);
        routerDelegate.replace(name: userViewModel.loggedUser.collection.homePageRoute);
      } else {
        routerDelegate.replaceAll(name: WelcomeScreen.route);
      }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
