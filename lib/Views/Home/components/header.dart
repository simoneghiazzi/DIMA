import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/user.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Settings/user_profile_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  final User loggedUser;

  Header({Key key, @required this.loggedUser}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  AuthViewModel authViewModel;
  AppRouterDelegate routerDelegate;
  StreamSubscription<bool> subscriber;

  @override
  void initState() {
    authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    routerDelegate = Provider.of<AppRouterDelegate>(context, listen: false);
    subscriber = subscribeToViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: kPrimaryColor),
        child: ListTile(
          contentPadding: EdgeInsets.only(left: 20, top: 60),
          title: Text(
            'Homepage',
            style: TextStyle(color: Colors.white, fontSize: 32),
          ),
          trailing: InkWell(
              child: widget.loggedUser.getData()['profilePhoto'] == null
                  ? CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: Text(
                        "${widget.loggedUser.name[0]}",
                        style: TextStyle(color: kPrimaryColor, fontSize: 30),
                      ))
                  : CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Image.network(
                          widget.loggedUser.getData()['profilePhoto'],
                          fit: BoxFit.cover,
                          width: 60.0,
                          height: 60.0,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 57.0,
                              height: 57.0,
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                                value: loadingProgress.expectedTotalBytes !=
                                            null &&
                                        loadingProgress.expectedTotalBytes !=
                                            null
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
                                  "${widget.loggedUser.name[0]}",
                                  style: TextStyle(
                                      color: kPrimaryColor, fontSize: 30),
                                ));
                          },
                        ),
                      ),
                    ),
              onTap: () {
                routerDelegate.pushPage(name: UserProfileScreen.route, arguments: widget.loggedUser);
              }),
        ));
  }

  StreamSubscription<bool> subscribeToViewModel() {
    return authViewModel.isUserLogged.listen((isSuccessfulLogin) {
      if (!isSuccessfulLogin) {
        subscriber.cancel();
        routerDelegate.replaceAll(name: WelcomeScreen.route);
      }
    });
  }
}
