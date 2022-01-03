// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/auth_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Home/BaseUser/base_user_home_page_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:sApport/Views/Home/BaseUser/components/base_user_home_page_body.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';
import 'package:sizer/sizer.dart';

void main() async {
  final fakeFirebase = FakeFirebaseFirestore();
  FirestoreService _firestoreService = FirestoreService(fakeFirebase);

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

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  AppRouterDelegate routerDelegate = AppRouterDelegate();
  ChatViewModel chatViewModel = ChatViewModel();

  testWidgets("Testing the correct render of a basic user's homepage", (WidgetTester tester) async {
    var userReference = fakeFirebase.collection(baseUser.collection).doc(baseUser.id);
    userReference.set(baseUser.data);

    //Create the base user homepage widget
    Widget testWidget = new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(home: new BaseUserHomePageBody()),
    );

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => routerDelegate),
        ChangeNotifierProvider<ChatViewModel>(create: (_) => chatViewModel),
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
    final gridFinder = find.byType(Table);
    final dashCardFinder = find.byType(DashCard);
    final expertsChatsCardFinder = find.widgetWithText(DashCard, 'Experts\nchats');

    expect(spacerFinder, findsNWidgets(2));
    expect(gridFinder, findsOneWidget);
    expect(dashCardFinder, findsNWidgets(4));
    expect(expertsChatsCardFinder, findsOneWidget);
  });
}
