import 'dart:io';
import 'package:dima_colombo_ghiazzi/Model/Services/collections.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firebase_auth_service.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:dima_colombo_ghiazzi/Router/app_router_delegate.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/base_user_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/BaseUser/diary_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/Expert/expert_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/auth_view_model.dart';
import 'package:dima_colombo_ghiazzi/ViewModel/chat_view_model.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/Expert/expert_home_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:dima_colombo_ghiazzi/Views/Welcome/welcome_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:dima_colombo_ghiazzi/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Disable landscape orientation
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Creation of the initialization Future for FirebaseApp
  await Firebase.initializeApp().catchError((e) {
    print('Initialization error');
    exit(-1);
  });
  print('Firebase initialization completed');
  await FirebaseAppCheck.instance
      .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
  print('FirebaseAppCheck initialization completed');
  setupServices();
  FirebaseAuthService firebaseAuthService = GetIt.I<FirebaseAuthService>();
  FirestoreService firestoreService = GetIt.I<FirestoreService>();

  var alreadyLoggedUserId = await firebaseAuthService.currentUser();

  print('Already logged user check completed');
  if (alreadyLoggedUserId != null) {
    var collection =
        await firestoreService.findUsersCollection(alreadyLoggedUserId);
    switch (collection) {
      case Collection.BASE_USERS:
        var baseUserViewModel = BaseUserViewModel();
        baseUserViewModel.id = alreadyLoggedUserId;
        await baseUserViewModel.loadLoggedUser();
        print('User logged');
        runApp(MyApp(
          expertProvider: Provider(create: (context) => ExpertViewModel()),
          baseUserProvider: Provider(create: (context) => baseUserViewModel),
          firstPage: BaseUserHomePageScreen.route,
        ));
        break;
      case Collection.EXPERTS:
        var expertViewModel = ExpertViewModel();
        expertViewModel.id = alreadyLoggedUserId;
        await expertViewModel.loadLoggedUser();
        print('Expert logged');
        runApp(MyApp(
          expertProvider: Provider(create: (context) => expertViewModel),
          baseUserProvider: Provider(create: (context) => BaseUserViewModel()),
          firstPage: ExpertHomePageScreen.route,
        ));
        break;
      default:
        return Container();
        break;
    }
  } else {
    runApp(MyApp(
      expertProvider: Provider(create: (context) => ExpertViewModel()),
      baseUserProvider: Provider(create: (context) => BaseUserViewModel()),
      firstPage: WelcomeScreen.route,
    ));
  }
}

void setupServices() {
  var getIt = GetIt.I;
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
}

class MyApp extends StatefulWidget {
  final baseUserProvider;
  final expertProvider;
  final firstPage;

  MyApp({Key key, this.baseUserProvider, this.expertProvider, this.firstPage})
      : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppRouterDelegate routerDelegate;

  @override
  void initState() {
    routerDelegate = AppRouterDelegate();
    if (widget.firstPage != WelcomeScreen.route)
      routerDelegate.addAll([
        RouteSettings(name: WelcomeScreen.route),
        RouteSettings(name: widget.firstPage)
      ]);
    else
      routerDelegate.pushPage(name: widget.firstPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(
            create: (_) => routerDelegate),
        Provider(create: (context) => AuthViewModel()),
        Provider(create: (context) => ChatViewModel()),
        Provider(create: (context) => DiaryViewModel()),
        widget.baseUserProvider,
        widget.expertProvider
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'sApport',
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
