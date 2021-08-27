import 'dart:io';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firebase_auth_service.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Experts/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUsers/base_user_home_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/Experts/expert_home_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable landscape orientation
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Creation of the initialization Future for FirebaseApp
  await Firebase.initializeApp().catchError((e) {
    exit(-1);
  });
  FirebaseAuthService firebaseAuthService = FirebaseAuthService();
  FirestoreService firestoreService = FirestoreService();

  var alreadyLoggedUserId = await firebaseAuthService.currentUser();
  if (alreadyLoggedUserId != null) {
    var collection =
        await firestoreService.findUserInCollections(alreadyLoggedUserId);
    switch (collection) {
      case Collection.USERS:
        var baseUserViewModel = BaseUserViewModel(id: alreadyLoggedUserId);
        await baseUserViewModel.loadLoggedUser();
        runApp(MyApp(
            home: BaseUserHomeScreen(
                authViewModel: AuthViewModel(),
                baseUserViewModel: baseUserViewModel)));
        break;
      case Collection.EXPERTS:
        var expertViewModel = ExpertViewModel(id: alreadyLoggedUserId);
        await expertViewModel.loadLoggedUser();
        runApp(MyApp(
            home: ExpertHomeScreen(
                authViewModel: AuthViewModel(),
                expertViewModel: expertViewModel)));
        break;
      default:
        return Container();
        break;
    }
  } else {
    runApp(MyApp(home: WelcomeScreen(authViewModel: AuthViewModel())));
  }
}

class MyApp extends StatelessWidget {
  final home;

  MyApp({Key key, this.home}) : super(key: key);

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DIMA_COLOMBO_GHIAZZI',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: home,
    );
  }
}
