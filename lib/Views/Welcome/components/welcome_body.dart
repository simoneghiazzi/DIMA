import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/Views/Login/login_screen.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/social_icon.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/Views/Welcome/components/background.dart';
import 'package:sApport/Views/Welcome/components/or_divider.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Views/Signup/Expert/experts_signup_screen.dart';
import 'package:sApport/Views/Signup/BaseUser/base_users_signup_screen.dart';

/// Body of the [WelcomeScreen].
///
/// It contains the login and signup buttons and the [SocialIcon]s for the social
/// authentication. It has also the button for the expert sign up.
///
/// **Since it is the page that is always at the bottom of the stack, it contains
/// the subscription to the [isUserLogged] stream of the [AuthViewModel] that is
/// valid for the entire application.**
class WelcomeBody extends StatefulWidget {
  /// Body of the [WelcomeScreen].
  ///
  /// It contains the login and signup buttons and the [SocialIcon]s for the social
  /// authentication. It has also the button for the expert sign up.
  ///
  /// **Since it is the page that is always at the bottom of the stack, it contains
  /// the subscription to the [isUserLogged] stream of the [AuthViewModel] that is
  /// valid for the entire application.**
  const WelcomeBody({Key? key}) : super(key: key);

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
    return Background(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Title
            Text(
              "sApport",
              style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 50.sp, fontFamily: "Gabriola"),
            ),
            Image.asset("assets/icons/logo.png", scale: 6),
            SizedBox(height: 5.h),
            // Login Button
            RoundedButton(
              onTap: () {
                authViewModel.clearAuthMessage();
                routerDelegate.pushPage(name: LoginScreen.route);
              },
              text: "LOGIN",
            ),
            SizedBox(height: 2.h),
            // SignUp Button
            RoundedButton(
              onTap: () {
                authViewModel.clearAuthMessage();
                routerDelegate.pushPage(name: BaseUsersSignUpScreen.route);
              },
              text: "SIGNUP",
              color: kPrimaryLightColor,
              textColor: kPrimaryColor,
            ),
            SizedBox(height: 2.h),
            OrDivider(),
            // Social Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SocialIcon(
                  iconSrc: "assets/icons/facebook.png",
                  onTap: () {
                    LoadingDialog.show(context);
                    authViewModel.logInWithFacebook();
                  },
                ),
                SocialIcon(
                  iconSrc: "assets/icons/google.png",
                  onTap: () {
                    LoadingDialog.show(context);
                    authViewModel.logInWithGoogle();
                  },
                ),
              ],
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
            // Expert SignUp Button
            GestureDetector(
              child: Text(
                "Are you a registered psychologist?\nJoin us",
                textAlign: TextAlign.center,
                style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14.sp),
              ),
              onTap: () {
                authViewModel.clearAuthMessage();
                routerDelegate.pushPage(name: ExpertsSignUpScreen.route);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Subscriber to the stream of user logged. It returns a [StreamSubscription].
  ///
  /// **This listener is active in the entire application since this page is always
  /// at the bottom of the stack**
  ///
  /// - On sign in it load the user from the Firebase DB and push he correct home page
  /// based on the [homePageRoute].
  /// - On sign out it close all the listeners of the view models and replace the pages
  /// of the stack with the [WelcomeScreen].
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
        routerDelegate.replaceAll(name: WelcomeScreen.route);
        chatViewModel.closeListeners();
        diaryViewModel.closeListeners();
        reportViewModel.closeListeners();
      }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
