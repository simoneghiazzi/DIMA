import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Screens/Welcome/welcome_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIMA_COLOMBO_GHIAZZI',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomeScreen(),
    );
  }
}
