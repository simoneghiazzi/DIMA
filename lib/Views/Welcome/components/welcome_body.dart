import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/Welcome/components/background.dart';
import 'package:sApport/Views/Welcome/components/or_divider.dart';
import 'package:sApport/Views/Welcome/components/social_icon.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';

class WelcomeBody extends StatefulWidget {
  @override
  _WelcomeBodyState createState() => _WelcomeBodyState();
}

class _WelcomeBodyState extends State<WelcomeBody> {
  // View Models
  late AuthViewModel authViewModel;
  late UserViewModel userViewModel;
  late ChatViewModel chatViewModel;
  late ReportViewModel reportViewModel;
  late DiaryViewModel diaryViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  // Subscriber
  late StreamSubscription subscriber;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    reportViewModel = Provider.of<ReportViewModel>(context, listen: false);
    diaryViewModel = Provider.of<DiaryViewModel>(context, listen: false);
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
        child: Column(
          children: <Widget>[
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 60, fontFamily: "Gabriola"),
            ),
            Image.asset(
              "assets/icons/logo.png",
              height: size.height * 0.12,
            ),
            SizedBox(height: size.height * 0.05),
            RoundedButton(
              press: () {
                routerDelegate.pushPage(name: LoginScreen.route);
              },
              text: "LOGIN",
            ),
            SizedBox(height: size.height * 0.02),
            RoundedButton(
              press: () {
                routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
              },
              text: "SIGNUP",
              color: kPrimaryLightColor,
              textColor: kPrimaryColor,
            ),
            SizedBox(height: size.height * 0.02),
            OrDivider(),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SocialIcon(
                  iconSrc: "assets/icons/facebook.png",
                  press: () {
                    LoadingDialog.show(context);
                    authViewModel.logInWithFacebook();
                  }),
              SocialIcon(
                  iconSrc: "assets/icons/google.png",
                  press: () {
                    LoadingDialog.show(context);
                    authViewModel.logInWithGoogle();
                  }),
            ]),
            SizedBox(height: size.height * 0.05),
            StreamBuilder<String?>(
              stream: authViewModel.authMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  LoadingDialog.hide(context);
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
                  return SizedBox(height: size.height * 0.04);
                }
              },
            ),
            GestureDetector(
              child: Text(
                "Are you a registered psychologist?\nJoin us",
                textAlign: TextAlign.center,
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 17),
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
        // Called on sign in
        await userViewModel.loadLoggedUser().then((_) => print("User of category ${userViewModel.loggedUser!.collection} logged"));
        LoadingDialog.hide(context);
        if (userViewModel.loggedUser != null) {
          routerDelegate.replaceAllButNumber(1, routeSettingsList: [RouteSettings(name: userViewModel.loggedUser!.homePageRoute)]);
        } else {
          print("Error in logging the user in");
        }
      } else {
        // Called on sign out
        chatViewModel.resetViewModel();
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
