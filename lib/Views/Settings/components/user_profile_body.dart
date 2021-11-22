import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/components/network_avatar.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UserProfileBody extends StatefulWidget {
  final User user;

  UserProfileBody({Key key, @required this.user}) : super(key: key);

  @override
  _UserProfileBodyState createState() => _UserProfileBodyState();
}

class _UserProfileBodyState extends State<UserProfileBody> {
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  Alert alert;

  @override
  void initState() {
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
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
                    child: widget.user.getData()['profilePhoto'] != null
                        ? NetworkAvatar(
                            img: widget.user.getData()['profilePhoto'],
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
                padding: EdgeInsets.only(
                    left: size.width / 10, right: size.width / 10, top: 30),
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
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                        child: Text(
                                      widget.user.name.toUpperCase() +
                                          " " +
                                          widget.user.surname.toUpperCase(),
                                      style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ))
                                  ]))),
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          if (widget.user.getData()['address'] != null) ...[
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
                                  child: Text(widget.user.getData()['address'],
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
                          if (widget.user.getData()['phoneNumber'] != null) ...[
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.phone,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Text(widget.user.getData()['phoneNumber'],
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
                          Column(
                            children: <Widget>[
                              if (widget.user.email != null) ...[
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
                                        child: Text(widget.user.email,
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
                              if (authViewModel.authProvider() ==
                                  "google.com") ...[
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
                                        child: Text(
                                            "You are logged in with a Google account",
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
                              if (authViewModel.authProvider() ==
                                  "facebook.com") ...[
                                Row(
                                  children: [
                                    Image.asset(
                                      "assets/icons/facebook.pn",
                                      height: 25,
                                      width: 25,
                                    ),
                                    SizedBox(
                                      width: size.width * 0.05,
                                    ),
                                    Flexible(
                                        child: Text(
                                            "You are logged in with a Facebook account",
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
                            ],
                          ),
                          if (widget.user.email != null) ...[
                            Column(children: [
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
                                        authViewModel
                                            .resetPassword(widget.user.email);
                                        showSnackBar();
                                        authViewModel.logOut();
                                      },
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.05,
                              ),
                            ]),
                          ],
                          Divider(
                            color: kPrimaryColor,
                            height: 1.5,
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                        ],
                      ),
                      Center(
                        child: InkWell(
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 2, bottom: 2),
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
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                            padding: EdgeInsets.only(
                                left: 8, right: 8, top: 2, bottom: 2),
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
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
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
                        height: size.height * 0.05,
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

  void showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          const Text('Please check your email for the password reset link.'),
      duration: const Duration(seconds: 20),
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
            labelText: 'Password',
          ),
        ),
        buttons: [
          DialogButton(
            child: Text(
              "DELETE",
              style: TextStyle(
                  color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              authViewModel.logOut();
              alert.dismiss();
            },
            color: Colors.transparent,
          )
        ]);
  }
}
