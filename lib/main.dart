import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_device_type/flutter_device_type.dart';
import 'package:sApport/constants.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Model/Services/map_service.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Views/Welcome/welcome_screen.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

Future<void> main() async {
  // Flutter initialization
  WidgetsFlutterBinding.ensureInitialized();

  // Check the device type and disable the landscape orientation if it is not a tablet
  // if (!Device.get().isTablet) {
  //   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // }

  // Firebase initialization and functional checks
  await Firebase.initializeApp().then((_) => print("Firebase initialization completed")).catchError((e) {
    print('Initialization error $e');
    exit(-1);
  });
  await FirebaseAppCheck.instance
      .activate(webRecaptchaSiteKey: "recaptcha-v3-site-key")
      .then((_) => print("FirebaseAppCheck initialization completed"))
      .catchError((e) {
    print("FirebaseAppCheck error $e");
    exit(-1);
  });

  // Services initialization
  setupServices();
  FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();
  UserService _userService = GetIt.I<UserService>();

  // Already logged user check: if the user is already logged
  // fetch the correct user data from the DB and load the relative homePage.
  //
  // If the user is not already logged or the email has not been verified, load the welcome page.
  if (_firebaseAuthService.isUserSignedIn() && _firebaseAuthService.isUserEmailVerified()) {
    await _userService.loadLoggedUserFromDB().then((_) => print("User of category ${_userService.loggedUser.collection} logged"));
    runApp(MyApp(homePage: _userService.loggedUser.homePageRoute));
  } else {
    runApp(MyApp());
  }
}

/// Initialization of the services into the GetIt service locator
void setupServices() {
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FirebaseFirestore.instance));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(FirebaseAuth.instance));
  getIt.registerSingleton<UserService>(UserService());
  getIt.registerSingleton<MapService>(MapService());
}

class MyApp extends StatefulWidget {
  final String homePage;

  MyApp({Key key, this.homePage}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppRouterDelegate routerDelegate = AppRouterDelegate();

  @override
  void initState() {
    // Add the WelcomePage to the routerDelegate and the homePage only if the user is already logged
    routerDelegate.addAll([
      RouteSettings(name: WelcomeScreen.route),
      if (widget.homePage != null) ...[RouteSettings(name: widget.homePage)],
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
        Provider(create: (context) => AuthViewModel()),
        Provider(create: (context) => ChatViewModel()),
        Provider(create: (context) => DiaryViewModel()),
        Provider(create: (context) => ReportViewModel()),
        Provider(create: (context) => UserViewModel()),
        Provider(create: (context) => MapViewModel(), lazy: false),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "sApport",
        theme: ThemeData(
          primaryColor: kPrimaryColor,
          scaffoldBackgroundColor: Colors.white,
        ),
        home: Router(
          routerDelegate: routerDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
