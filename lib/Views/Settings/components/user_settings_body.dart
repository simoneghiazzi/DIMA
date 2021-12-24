import 'dart:async';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/components/social_icon.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sizer/sizer.dart';

class UserSettingsBody extends StatefulWidget {
  @override
  _UserSettingsBodyState createState() => _UserSettingsBodyState();
}

class _UserSettingsBodyState extends State<UserSettingsBody> {
  late UserViewModel userViewModel;
  late AuthViewModel authViewModel;
  AppRouterDelegate? routerDelegate;
  late StreamSubscription<String?> subscriber;
  late Alert alert;

  var _hasPasswordAuthenticationFuture;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    subscriber = subscribeToAuthMessage();
    _hasPasswordAuthenticationFuture = authViewModel.hasPasswordAuthentication(userViewModel.loggedUser!.email);
    alert = createAlert();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          // background image and bottom contents
          SingleChildScrollView(
              child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 40, bottom: 10),
                alignment: Alignment.center,
                width: 100.w,
                color: kPrimaryColor,
                child: Container(
                    child: userViewModel.loggedUser!.data["profilePhoto"] != null
                        ? NetworkAvatar(
                            img: userViewModel.loggedUser!.data["profilePhoto"] as String,
                            radius: 50.0,
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 70,
                              color: kPrimaryColor,
                            ))),
              ),
              Container(
                padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 30),
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Center(
                          child: Container(
                              constraints: BoxConstraints(maxWidth: 500, minHeight: 4.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryLightColor,
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                Text(
                                  userViewModel.loggedUser!.name.toUpperCase() + " " + userViewModel.loggedUser!.surname.toUpperCase(),
                                  style: TextStyle(color: kPrimaryColor, fontSize: 15.sp, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )
                              ]))),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 5.h,
                          ),
                          if (userViewModel.loggedUser!.data["address"] != null) ...[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.house,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Flexible(
                                  child: Text(userViewModel.loggedUser!.data["address"] as String,
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 15,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                          ],
                          if (userViewModel.loggedUser!.data["phoneNumber"] != null) ...[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.phone,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: 5.h,
                                ),
                                Text(userViewModel.loggedUser!.data["phoneNumber"] as String,
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 15,
                                    ))
                              ],
                            ),
                            SizedBox(height: 4.h),
                          ],
                          if (userViewModel.loggedUser!.email != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.mail,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(width: 5.h),
                                Flexible(
                                    child: Text(userViewModel.loggedUser!.email,
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 13.sp,
                                        ))),
                              ],
                            ),
                            SizedBox(height: 4.h),
                          ],
                          FutureBuilder(
                              future: _hasPasswordAuthenticationFuture,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Column(children: [
                                    Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.lock,
                                          color: kPrimaryColor,
                                        ),
                                        SizedBox(width: 5.h),
                                        Flexible(
                                          child: GestureDetector(
                                            child: Text(
                                              "Reset password",
                                              style: TextStyle(
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                            onTap: () {
                                              authViewModel.resetPassword(userViewModel.loggedUser!.email);
                                              showSnackBar("Please check your email for the password reset link.");
                                              authViewModel.logOut();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                  ]);
                                } else {
                                  return Container();
                                }
                              }),
                          if (authViewModel.authProvider() == "google.com") ...[
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/google.png",
                                  height: 25,
                                  width: 25,
                                ),
                                SizedBox(width: 5.h),
                                Flexible(
                                    child: Text("Your Google account is linked with this profile",
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 15,
                                        ))),
                              ],
                            ),
                            SizedBox(height: 5.h),
                          ],
                          if (authViewModel.authProvider() == "facebook.com") ...[
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/facebook.png",
                                  height: 25,
                                  width: 25,
                                ),
                                SizedBox(width: 5.h),
                                Flexible(
                                    child: Text("Your Facebook account is linked with this profile",
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 15,
                                        ))),
                              ],
                            ),
                            SizedBox(height: 5.h),
                          ],
                          if (authViewModel.authProvider() == "password" && userViewModel.loggedUser is BaseUser) ...[
                            Divider(
                              color: kPrimaryLightColor,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Link your social accounts:",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              SocialIcon(
                                  iconSrc: "assets/icons/facebook.png",
                                  onTap: () {
                                    LoadingDialog.show(context);
                                    authViewModel.logInWithFacebook(link: true).then((value) {
                                      setState(() {});
                                    });
                                  }),
                              SocialIcon(
                                  iconSrc: "assets/icons/google.png",
                                  onTap: () {
                                    LoadingDialog.show(context);
                                    authViewModel.logInWithGoogle(link: true).then((value) {
                                      setState(() {});
                                    });
                                  }),
                            ]),
                            SizedBox(height: 3.h),
                          ],
                          Divider(
                            color: kPrimaryColor,
                            height: 1.5,
                          ),
                          SizedBox(height: 4.h),
                        ],
                      ),
                      Center(
                        child: InkWell(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                            height: 5.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: kPrimaryColor,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.logout,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            authViewModel.logOut();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                      Center(
                        child: InkWell(
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                            height: 5.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.red,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  "Delete account",
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            alert.show();
                          },
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  void showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 10),
    ));
  }

  Alert createAlert() {
    return Alert(
        closeIcon: null,
        context: context,
        title: "Insert password to confirm:",
        type: AlertType.warning,
        style: AlertStyle(
          animationDuration: Duration(milliseconds: 0),
          isCloseButton: false,
        ),
        content: TextField(
          obscureText: true,
          decoration: InputDecoration(
            icon: Icon(Icons.lock, color: kPrimaryColor),
            labelText: "Password",
          ),
        ),
        buttons: [
          DialogButton(
            child: Text(
              "DELETE",
              style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              authViewModel.logOut();
              alert.dismiss();
            },
            color: Colors.transparent,
          )
        ]);
  }

  StreamSubscription<String?> subscribeToAuthMessage() {
    return authViewModel.authMessage.listen((message) {
      if (message != null) {
        if (message.isNotEmpty) {
          showSnackBar(message);
        } else {
          LoadingDialog.hide(context);
        }
      }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
