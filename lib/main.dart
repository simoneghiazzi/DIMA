import 'package:dima_colombo_ghiazzi/ViewModel/authViewModel.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Creation of the initialization Future for FirebaseApp
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialization of FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          //return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          final AuthViewModel authViewModel = AuthViewModel();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'DIMA_COLOMBO_GHIAZZI',
            theme: ThemeData(
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: Colors.white,
            ),
            home: WelcomeScreen(
              authViewModel: authViewModel,
            ),
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: Image.asset(
            "assets/icons/logo.png",
          ),
        );
      },
    );
  }
}
