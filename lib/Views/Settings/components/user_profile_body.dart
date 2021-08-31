import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        // background image and bottom contents
        SingleChildScrollView(
            child: Column(
          children: <Widget>[
            Container(
              height: 165.0,
              color: kPrimaryColor,
            ),
            Padding(
                padding: EdgeInsets.only(top: 90),
                child: Container(
                  padding: EdgeInsets.only(
                      left: size.width / 10, right: size.width / 10),
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
                            widget.user.getData()['profilePhoto'] != null
                                ? Row(
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
                                  )
                                : Image.asset(
                                    "assets/icons/small_logo.png",
                                    height: size.height * 0.1,
                                  ),
                            Container(),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            Row(
                              children: <Widget>[
                                Icon(
                                  Icons.mail,
                                  color: kPrimaryColor,
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Flexible(
                                    child: widget.user.email != null
                                        ? Text(widget.user.email,
                                            style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 15,
                                            ))
                                        : Text(
                                            "You are logged in with Facebook or with a Google account",
                                            style: TextStyle(
                                              color: kPrimaryColor,
                                              fontSize: 15,
                                            ))),
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
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
                                    },
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: size.height * 0.03,
                            ),
                            widget.user.getData()['profilePhoto'] != null
                                ? Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.house,
                                        color: kPrimaryColor,
                                      ),
                                      SizedBox(
                                        width: size.width * 0.05,
                                      ),
                                      Flexible(
                                        child: GestureDetector(
                                          child: Text(
                                              widget.user.getData()['address'],
                                              style: TextStyle(
                                                color: kPrimaryColor,
                                                fontSize: 15,
                                              )),
                                          onTap: () {
                                            openMaps();
                                          },
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: size.height * 0.06,
                            ),
                            Divider(
                              color: kPrimaryColor,
                              height: 1.5,
                            ),
                            SizedBox(
                              height: size.height * 0.1,
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
                                  _onDeleteAccount(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ))
          ],
        )),
        Positioned(
          top: 100.0, // (background container size) - (circle height / 2)
          child: widget.user.getData()['profilePhoto'] != null
              ? CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: Image.network(
                      widget.user.getData()['profilePhoto'],
                      fit: BoxFit.cover,
                      width: 120.0,
                      height: 120.0,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 120.0,
                          height: 120.0,
                          child: CircularProgressIndicator(
                            color: kPrimaryColor,
                            value: loadingProgress.expectedTotalBytes != null &&
                                    loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, object, stackTrace) {
                        return CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: Text(
                              "${widget.user.name[0]}",
                              style:
                                  TextStyle(color: kPrimaryColor, fontSize: 30),
                            ));
                      },
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 100,
                    color: kPrimaryColor,
                  )),
        ),
        Positioned(
          top: 60,
          left: 25,
          child: FloatingActionButton(
            mini: true,
            onPressed: () {
              routerDelegate.pop();
            },
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: Colors.transparent,
            child: const Icon(Icons.arrow_back, size: 40.0),
          ),
        ),
      ],
    );
  }

  void openMaps() async {
    var lat = widget.user.getData()['latLng'].latitude;
    var lng = widget.user.getData()['latLng'].longitude;
    var uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      throw 'Could not launch ${uri.toString()}';
    }
  }

  _onDeleteAccount(context) {
    alert.show();
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
