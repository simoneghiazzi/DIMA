import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  final fakeFirebase = FakeFirebaseFirestore();

  var id = Utils.randomId();
  var name = "SIMONE";
  var surname = "GHIAZZI";
  var email = "simone.ghiazzi@prova.it";
  var birthDate = DateTime(1997, 10, 19);

  BaseUser baseUser = BaseUser(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
  );

//Create a diary page
  var now = DateTime.now();
  DiaryPage diaryPage = DiaryPage(
    id: now.millisecondsSinceEpoch.toString(),
    title: "TEST",
    content: "TEST CONTENT",
    dateTime: now,
  );

  //Populate the mock DB
  var userReference = fakeFirebase.collection(baseUser.collection).doc(baseUser.id);
  //Insert the user
  userReference.set(baseUser.data);

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  final UserService _userService = GetIt.I<UserService>();
  _userService.loggedUser = baseUser;

  group('Correct rendering:', () {
    testWidgets("Testing the correct render of the diary screen without a page already added", (WidgetTester tester) async {
      AppRouterDelegate routerDelegate = AppRouterDelegate();
      DiaryViewModel diaryViewModel = DiaryViewModel();
      diaryViewModel.loadDiaryPages();

      //Create the base user homepage widget
      Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
          home: new DiaryBody(),
        ),
      );

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
          ChangeNotifierProvider<DiaryViewModel>(create: (_) => diaryViewModel),
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

      final headerFinder = find.byType(Header);
      final calendarFinder = find.byType(SfCalendar);
      final addPageButtonFinder = find.byType(FloatingActionButton);

      expect(headerFinder, findsOneWidget);
      expect(calendarFinder, findsOneWidget);
      expect(addPageButtonFinder, findsOneWidget);
    });

    testWidgets("Testing the correct render of the diary screen with a page already added", (WidgetTester tester) async {
      //Insert the diary page
      fakeFirebase.collection(diaryPage.collection).doc(id).collection("diaryPages").doc(diaryPage.id).set(diaryPage.data);

      AppRouterDelegate routerDelegate = AppRouterDelegate();
      DiaryViewModel diaryViewModel = DiaryViewModel();
      diaryViewModel.loadDiaryPages();

      //Create the base user homepage widget
      Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(
          home: new DiaryBody(),
        ),
      );

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
          ChangeNotifierProvider<DiaryViewModel>(create: (_) => diaryViewModel),
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

      final headerFinder = find.byType(Header);
      final calendarFinder = find.byType(SfCalendar);
      final addPageButtonFinder = find.byType(FloatingActionButton);

      expect(headerFinder, findsOneWidget);
      expect(calendarFinder, findsOneWidget);

      //Expect nothing because we have added by hand a mock diary page with
      //dateTime = now, so the button must not appear
      expect(addPageButtonFinder, findsNothing);
    });
  });
}
