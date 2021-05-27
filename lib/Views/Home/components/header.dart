import 'dart:async';
import 'package:dima_colombo_ghiazzi/ViewModel/AuthViewModel.dart';
import 'package:flutter/material.dart';

class Header extends StatefulWidget {
  final AuthViewModel authViewModel;

  Header({Key key, @required this.authViewModel}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  StreamSubscription<bool> subscriber;

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
        trailing: CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple[500],
          child: Text(
            "S",
            style: TextStyle(color: Colors.white, fontSize: 30),
          ),
        ),
      ),
      // IconButton(
      //     icon: Icon(Icons.logout),
      //     onPressed: () => widget.authViewModel.logOut()),
    ]);
  }

  StreamSubscription<bool> subscribeToViewModel() {
    return widget.authViewModel.isUserLogged.listen((isSuccessfulLogin) {
      if (!isSuccessfulLogin) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    subscriber.cancel();
    super.dispose();
  }
}
