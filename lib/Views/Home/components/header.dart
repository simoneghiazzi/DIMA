import 'dart:async';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class Header extends StatefulWidget {
  final AuthViewModel authViewModel;

  Header({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  StreamSubscription<bool> subscriber;
  LoggedUser loggedUser;

  @override
  void initState() {
    subscriber = subscribeToViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        contentPadding: EdgeInsets.only(left: 20, right: 20, top: 100),
        title: Text(
          'Homepage',
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
        trailing: InkWell(
          child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.deepPurple[500],
              child: Text(
                "${widget.authViewModel.loggedUser.name[0]}",
                style: TextStyle(color: Colors.white, fontSize: 30),
              )),
          onTap: () => _onAccountPressed(context),
        ),
      )
    ]);
  }

  StreamSubscription<bool> subscribeToViewModel() {
    return widget.authViewModel.isUserLogged.listen((isSuccessfulLogin) {
      if (!isSuccessfulLogin) {
        subscriber.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return WelcomeScreen(authViewModel: widget.authViewModel);
            },
          ),
          ModalRoute.withName('/'),
        );
      }
    });
  }

  _onAccountPressed(context) {
    Alert(
      context: context,
      title: "ACCOUNT SETTINGS",
      //desc: "",
      image: Image.asset("assets/icons/small_logo.png"),
      buttons: [
        DialogButton(
          child: Text(
            "SETTINGS",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {},
          gradient: LinearGradient(colors: [
            Colors.indigo[400],
            Colors.cyan[200],
          ]),
        ),
        DialogButton(
          child: Text(
            "LOGOUT",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            widget.authViewModel.logOut();
          },
          gradient: LinearGradient(colors: [
            Colors.red[400],
            Colors.red[200],
          ]),
        )
      ],
    ).show();
  }
}
