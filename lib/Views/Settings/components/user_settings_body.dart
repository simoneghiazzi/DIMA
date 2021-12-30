import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Views/Utils/custom_sizer.dart';
import 'package:sApport/Model/DBItems/user.dart';
import 'package:sApport/Views/Utils/constants.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Views/components/info_dialog.dart';
import 'package:sApport/Views/components/social_icon.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Views/Settings/user_settings_screen.dart';

/// Body of the [UserSettingsScreen].
///
/// It contains all the information of the user profile based on the
/// type of [User] and his/her authentication methods.
///
/// It has the button for resetting the password, sign the user out and
/// for deleting the account.
///
/// If the user is a [BaseUser] and his/her authentication method is the email/password,
/// it shows the [SocialIcon]s for linking the profile with the social accounts.
class UserSettingsBody extends StatefulWidget {
  /// Body of the [UserSettingsScreen].
  ///
  /// It contains all the information of the user profile based on the
  /// type of [User] and his/her authentication methods.
  ///
  /// It has the button for resetting the password, sign the user out and
  /// for deleting the account.
  ///
  /// If the user is a [BaseUser] and his/her authentication method is the email/password,
  /// it shows the [SocialIcon]s for linking the profile with the social accounts.
  const UserSettingsBody({Key? key}) : super(key: key);

  @override
  _UserSettingsBodyState createState() => _UserSettingsBodyState();
}

class _UserSettingsBodyState extends State<UserSettingsBody> {
  // View Models
  late UserViewModel userViewModel;
  late AuthViewModel authViewModel;

  // Router Delegate
  late AppRouterDelegate routerDelegate;

  late StreamSubscription<String?> subscriber;
  var _hasPasswordAuthenticationFuture;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    subscriber = subscribeToAuthMessage();

    // Registering the future for the has password auth method
    _hasPasswordAuthenticationFuture = authViewModel.hasPasswordAuthentication(userViewModel.loggedUser!.email);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Top Bar with Image
        Row(
          children: [
            Expanded(
              child: Container(
                color: kPrimaryColor,
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    alignment: Alignment.center,
                    color: kPrimaryColor,
                    child: userViewModel.loggedUser!.data["profilePhoto"] != null
                        ?
                        // If the profile photo is not null, show the image
                        NetworkAvatar(img: userViewModel.loggedUser!.data["profilePhoto"] as String, radius: 50.0)
                        :
                        // Otherwise show the circle avatar with the person icon
                        CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 70, color: kPrimaryColor)),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        // Full Name
        Container(
          width: 70.w,
          padding: EdgeInsets.only(top: 2.5, bottom: 2.5),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: kPrimaryLightColor),
          child: Text(
            userViewModel.loggedUser!.fullName.toUpperCase(),
            style: TextStyle(color: kPrimaryColor, fontSize: 17.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 5.h),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: 10.w, right: 10.w),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: ListView(
                physics: (MediaQuery.of(context).orientation == Orientation.portrait) ? const NeverScrollableScrollPhysics() : null,
                children: [
                  // Address
                  if (userViewModel.loggedUser!.data["address"] != null) ...[
                    Row(
                      children: <Widget>[
                        Icon(Icons.house, color: kPrimaryColor),
                        SizedBox(width: 5.w),
                        Flexible(
                            child:
                                Text(userViewModel.loggedUser!.data["address"].toString(), style: TextStyle(color: kPrimaryColor, fontSize: 13.sp))),
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                  // Phone Number
                  if (userViewModel.loggedUser!.data["phoneNumber"] != null) ...[
                    Row(
                      children: <Widget>[
                        Icon(Icons.phone, color: kPrimaryColor),
                        SizedBox(width: 5.w),
                        Text(userViewModel.loggedUser!.data["phoneNumber"].toString(), style: TextStyle(color: kPrimaryColor, fontSize: 13.sp))
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                  // Email
                  Row(
                    children: [
                      Icon(Icons.mail, color: kPrimaryColor),
                      SizedBox(width: 5.w),
                      Flexible(child: Text(userViewModel.loggedUser!.email, style: TextStyle(color: kPrimaryColor, fontSize: 13.sp))),
                    ],
                  ),
                  SizedBox(height: 4.5.h),
                  // Reset Password
                  FutureBuilder(
                    future: _hasPasswordAuthenticationFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Row(
                              children: <Widget>[
                                Icon(Icons.lock, color: kPrimaryColor),
                                SizedBox(width: 5.w),
                                GestureDetector(
                                  child: Text(
                                    "Reset password",
                                    style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                                  ),
                                  onTap: () {
                                    authViewModel.resetPassword(userViewModel.loggedUser!.email);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Please check your email for the password reset link."),
                                      duration: const Duration(seconds: 10),
                                    ));
                                    authViewModel.logOut();
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                  // Google Account
                  if (authViewModel.authProvider().contains("google.com")) ...[
                    Row(
                      children: [
                        Image.asset("assets/icons/google.png", height: 25, width: 25),
                        SizedBox(width: 5.w),
                        Flexible(
                            child: Text("Your Google account is linked with this profile", style: TextStyle(color: kPrimaryColor, fontSize: 13.sp))),
                      ],
                    ),
                    SizedBox(height: 5.h),
                  ],
                  // Facebook Account
                  if (authViewModel.authProvider().contains("facebook.com")) ...[
                    Row(
                      children: [
                        Image.asset("assets/icons/facebook.png", height: 25, width: 25),
                        SizedBox(width: 5.w),
                        Flexible(
                            child:
                                Text("Your Facebook account is linked with this profile", style: TextStyle(color: kPrimaryColor, fontSize: 13.sp))),
                      ],
                    ),
                    SizedBox(height: 5.h),
                  ],
                  // Link Social Accounts
                  if (authViewModel.authProvider().contains("password") && userViewModel.loggedUser is BaseUser) ...[
                    // If the user has the password as auth provider and it is a base user,
                    // show the link your social accounts option
                    Divider(color: kPrimaryLightColor),
                    SizedBox(height: 2.h),
                    Text(
                      "Link your social accounts:",
                      style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13.sp),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        // Facebook
                        SocialIcon(
                          iconSrc: "assets/icons/facebook.png",
                          onTap: () {
                            LoadingDialog.show(context);
                            authViewModel.logInWithFacebook(link: true).then((value) => setState(() {}));
                          },
                        ),
                        // Google
                        SocialIcon(
                          iconSrc: "assets/icons/google.png",
                          onTap: () {
                            LoadingDialog.show(context);
                            authViewModel.logInWithGoogle(link: true).then((value) => setState(() {}));
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                  ],
                  Divider(color: kPrimaryColor, height: 1.5),
                  SizedBox(height: 5.h),
                  (MediaQuery.of(context).orientation == Orientation.landscape)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Logout Button
                            RoundedButton(
                              text: "Logout ",
                              onTap: () => authViewModel.logOut(),
                              suffixIcon: Icon(Icons.logout, color: Colors.white, size: 20),
                            ),
                            SizedBox(height: 2.h),
                            // Delete Account Button
                            RoundedButton(
                              text: "Delete Account",
                              color: Colors.red,
                              onTap: () => InfoDialog.show(context,
                                  infoType: InfoDialogType.warning,
                                  title: "Delete account",
                                  content: "Insert the password to confirm:",
                                  buttonType: ButtonType.confirm,
                                  closeButton: true,
                                  onTap: () => authViewModel.logOut(),
                                  body: TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(icon: Icon(Icons.lock, color: kPrimaryColor), hintText: "Password"),
                                  )),
                              suffixIcon: Icon(Icons.delete, color: Colors.white, size: 20),
                            ),
                            SizedBox(height: 3.h),
                          ],
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
        (MediaQuery.of(context).orientation == Orientation.portrait)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Logout Button
                  RoundedButton(
                    text: "Logout ",
                    onTap: () => authViewModel.logOut(),
                    suffixIcon: Icon(Icons.logout, color: Colors.white, size: 20),
                  ),
                  SizedBox(height: 2.h),
                  // Delete Account Button
                  RoundedButton(
                    text: "Delete Account",
                    color: Colors.red,
                    onTap: () => InfoDialog.show(context,
                        infoType: InfoDialogType.warning,
                        title: "Delete account",
                        content: "Insert the password to confirm:",
                        buttonType: ButtonType.confirm,
                        closeButton: true,
                        onTap: () => authViewModel.logOut(),
                        body: TextField(
                          obscureText: true,
                          decoration: InputDecoration(icon: Icon(Icons.lock, color: kPrimaryColor), hintText: "Password"),
                        )),
                    suffixIcon: Icon(Icons.delete, color: Colors.white, size: 20),
                  ),
                  SizedBox(height: 3.h),
                ],
              )
            : Container(),
      ],
    );
  }

  /// Subscriber to the stream of auth message. It returns a [StreamSubscription].
  ///
  /// When the user links his/her social accounts, if an error occured, the
  /// message is shown into a snack bar.
  StreamSubscription<String?> subscribeToAuthMessage() {
    return authViewModel.authMessage.listen((message) {
      if (message != null && message.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 10),
        ));
      }
      LoadingDialog.hide(context);
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}

/// Used to avoid shadows in the scrollable widgets like ListView
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
