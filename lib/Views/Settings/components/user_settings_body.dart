import 'dart:async';
import 'package:sApport/Model/BaseUser/base_user.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Welcome/components/social_icon.dart';
import 'package:sApport/Views/components/loading_dialog.dart';
import 'package:sApport/Views/components/network_avatar.dart';
import 'package:sApport/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UserSettingsBody extends StatefulWidget {
  @override
  _UserSettingsBodyState createState() => _UserSettingsBodyState();
}

class _UserSettingsBodyState extends State<UserSettingsBody> {
  UserViewModel userViewModel;
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  StreamSubscription<String> subscriber;
  Alert alert;

  var _hasPasswordAuthenticationFuture;

  @override
  void initState() {
    userViewModel = Provider.of<UserViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    subscriber = subscribeToAuthMessage();
    _hasPasswordAuthenticationFuture = authViewModel.hasPasswordAuthentication(userViewModel.loggedUser.email);
    alert = createAlert();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                width: size.width,
                color: kPrimaryColor,
                child: Container(
                    child: userViewModel.loggedUser.data["profilePhoto"] != null
                        ? NetworkAvatar(
                            img: userViewModel.loggedUser.data["profilePhoto"],
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
                padding: EdgeInsets.only(left: size.width / 10, right: size.width / 10, top: 30),
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Center(
                          child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: kPrimaryLightColor,
                              ),
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Flexible(
                                    child: Text(
                                  userViewModel.loggedUser.name.toUpperCase() + " " + userViewModel.loggedUser.surname.toUpperCase(),
                                  style: TextStyle(color: kPrimaryColor, fontSize: 22, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ))
                              ]))),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          if (userViewModel.loggedUser.data["address"] != null) ...[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.house,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Flexible(
                                  child: Text(userViewModel.loggedUser.data["address"],
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 15,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.04,
                            ),
                          ],
                          if (userViewModel.loggedUser.data["phoneNumber"] != null) ...[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.phone,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Text(userViewModel.loggedUser.data["phoneNumber"],
                                    style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 15,
                                    ))
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.04,
                            ),
                          ],
                          if (userViewModel.loggedUser.email != null) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.mail,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Flexible(
                                    child: Text(userViewModel.loggedUser.email,
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 15,
                                        ))),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.04,
                            ),
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
                                        SizedBox(
                                          width: size.width * 0.05,
                                        ),
                                        Flexible(
                                          child: GestureDetector(
                                            child: Text(
                                              "Reset password",
                                              style: TextStyle(
                                                color: kPrimaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            onTap: () {
                                              authViewModel.resetPassword(userViewModel.loggedUser.email);
                                              showSnackBar("Please check your email for the password reset link.");
                                              authViewModel.logOut();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: size.height * 0.04,
                                    ),
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
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Flexible(
                                    child: Text("Your Google account is linked with this profile",
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 15,
                                        ))),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                          ],
                          if (authViewModel.authProvider() == "facebook.com") ...[
                            Row(
                              children: [
                                Image.asset(
                                  "assets/icons/facebook.png",
                                  height: 25,
                                  width: 25,
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Flexible(
                                    child: Text("Your Facebook account is linked with this profile",
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 15,
                                        ))),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.05,
                            ),
                          ],
                          if (authViewModel.authProvider() == "password" && userViewModel.loggedUser is BaseUser) ...[
                            Divider(
                              color: kPrimaryLightColor,
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Text(
                              "Link your social accounts:",
                              style: TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.02,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                              SocialIcon(
                                  iconSrc: "assets/icons/facebook.png",
                                  press: () {
                                    LoadingDialog.show(context);
                                    authViewModel.logInWithFacebook(link: true).then((value) {
                                      setState(() {});
                                    });
                                  }),
                              SocialIcon(
                                  iconSrc: "assets/icons/google.png",
                                  press: () {
                                    LoadingDialog.show(context);
                                    authViewModel.logInWithGoogle(link: true).then((value) {
                                      setState(() {});
                                    });
                                  }),
                            ]),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                          ],
                          Divider(
                            color: kPrimaryColor,
                            height: 1.5,
                          ),
                          SizedBox(
                            height: size.height * 0.04,
                          ),
                        ],
                      ),
                      Center(
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                            height: size.height * 0.05,
                            width: size.width * 0.5,
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
                        height: size.height * 0.03,
                      ),
                      Center(
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 2),
                            height: size.height * 0.05,
                            width: size.width * 0.5,
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
                        height: size.height * 0.03,
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

  StreamSubscription<String> subscribeToAuthMessage() {
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
