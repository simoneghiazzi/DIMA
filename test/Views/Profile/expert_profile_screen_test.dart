// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/map_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:sApport/Views/Home/BaseUser/components/base_user_home_page_body.dart';
import 'package:sApport/Views/Profile/expert_profile_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:sApport/Views/components/rounded_button.dart';
import 'package:sizer/sizer.dart';

void main() {
  final fakeFirebase = FakeFirebaseFirestore();
  FirestoreService _firestoreService = FirestoreService(fakeFirebase);

  var id = Utils.randomId();
  var name = "SIMONE";
  var surname = "GHIAZZI";
  var email = "simone.ghiazzi@prova.it";
  var birthDate = DateTime(1997, 10, 19);
  var latitude = 100.0;
  var longitude = 300.5;
  var address = "Piazza Leonardo da Vinci, 32, Milan, Province of Milan, Italia";
  var phoneNumber = "3333333333";
  var profilePhoto = "https://example.com/image.png";

  Expert expert = Expert(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
    latitude: latitude,
    longitude: longitude,
    address: address,
    phoneNumber: phoneNumber,
    profilePhoto: profilePhoto,
  );

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  AppRouterDelegate routerDelegate = AppRouterDelegate();

  testWidgets("Testing the correct render of an expert's profile page", (WidgetTester tester) async {
    //Create the expert profile screen page widget passing the expert's info
    Widget testWidget = new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: new ExpertProfileScreen(expert: expert)),
    );

    //The mockNetwork is required because by default Flutter testing gives 404 as response to network requests
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
          ChangeNotifierProvider<ChatViewModel>(create: (_) => ChatViewModel()),
        ],
        child: Sizer(builder: (context, orientation, deviceType) {
          // Check the device type and disable the landscape orientation if it is not a tablet

          /*************************** RIGA DA DECOMMENTARE IN DEPLOY ***************************/
          if (!(deviceType == DeviceType.tablet)) {
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
          }

          return testWidget;
        }),
      ));
    });

    final nameFinder = find.text(expert.name.toUpperCase() + " " + expert.surname.toUpperCase());
    final phoneFinder = find.text(expert.phoneNumber);
    final emailFinder = find.text(expert.email);
    final addressFinder = find.text(expert.address);

    expect(nameFinder, findsOneWidget);
    expect(phoneFinder, findsOneWidget);
    expect(emailFinder, findsOneWidget);
    expect(addressFinder, findsOneWidget);
  });

  testWidgets("Testing the correct render of a basic user's homepage", (WidgetTester tester) async {
    //Create the base user homepage widget
    Widget testWidget = new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: new BaseUserHomePageBody()),
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
        ChangeNotifierProvider<ChatViewModel>(create: (_) => ChatViewModel()),
        ChangeNotifierProvider<DiaryViewModel>(create: (_) => DiaryViewModel()),
        Provider(create: (context) => ReportViewModel()),
        Provider(create: (context) => AuthViewModel()),
        Provider(create: (context) => UserViewModel()),
      ],
      child: Sizer(builder: (context, orientation, deviceType) {
        // Check the device type and disable the landscape orientation if it is not a tablet

        /*************************** RIGA DA DECOMMENTARE IN DEPLOY ***************************/
        if (!(deviceType == DeviceType.tablet)) {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
        }

        return testWidget;
      }),
    ));

    final spacerFinder = find.byType(Spacer);

    expect(spacerFinder, findsNWidgets(2));
  });
}
