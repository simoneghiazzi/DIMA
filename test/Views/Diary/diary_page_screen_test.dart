import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sizer/sizer.dart';

import '../../navigator.mocks.dart';
import '../../view_model.mocks.dart';

void main() {
  final mockRouterDelegate = MockAppRouterDelegate();
  final mockDiaryViewModel = MockDiaryViewModel();
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

  ///Register services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([diaryPage]));
  when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(diaryPage));
  //when(mockDiaryViewModel.contentTextCtrl).thenAnswer((_) => );

  ///This is needed to mock the bool for editing the page
  when(mockDiaryViewModel.isEditing).thenAnswer((_) => false);

  /// Get MultiProvider Widget for creating the test
  Widget getMultiProvider({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => mockRouterDelegate),
        ChangeNotifierProvider<DiaryViewModel>(create: (_) => mockDiaryViewModel),
        Provider(create: (context) => ReportViewModel()),
        Provider(create: (context) => UserViewModel()),
      ],
      child: Sizer(builder: (context, orientation, deviceType) {
        return child;
      }),
    );
  }

  group("Correct rendering:", () {
    testWidgets('Testing the correct render of a page and its content', (tester) async {
      // TODO: Implement test
    });
  });
}
