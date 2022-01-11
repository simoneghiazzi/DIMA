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
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Diary/components/diary_body.dart';
import 'package:sApport/Views/Diary/diary_page_screen.dart';
import 'package:sApport/Views/Home/components/header.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../navigator.mocks.dart';
import '../../service.mocks.dart';
import '../../view_model.mocks.dart';
import '../widget_test_helper.dart';

void main() {
  /// Mock Services
  final mockRouterDelegate = MockAppRouterDelegate();
  final mockDiaryViewModel = MockDiaryViewModel();
  final mockUserService = MockUserService();

  var id = Utils.randomId();
  var name = "Simone";
  var surname = "Ghiazzi";
  var email = "simone.ghiazzi@prova.it";
  var birthDate = DateTime(1997, 10, 19);

  BaseUser loggedUser = BaseUser(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
  );

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => loggedUser);

  /// Create a diary page
  var now = DateTime.now();
  DiaryPage diaryPage = DiaryPage(
    id: now.millisecondsSinceEpoch.toString(),
    title: "Test",
    content: "Test content",
    dateTime: now,
  );

  /// Register services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(mockUserService);

  /// Get MultiProvider Widget for creating the test
  Widget getMultiProvider({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => mockRouterDelegate),
        ChangeNotifierProvider<DiaryViewModel>(create: (_) => mockDiaryViewModel),
        Provider(create: (context) => UserViewModel()),
      ],
      child: Sizer(builder: (context, orientation, deviceType) {
        return child;
      }),
    );
  }

  group("DiaryScreen correct rendering", () {
    testWidgets("Diary screen without a page already added should show the add page button", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Mock User Service responses
      when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([]));
      when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(null));

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: DiaryBody())));

      final headerFinder = find.byType(Header);
      final calendarFinder = find.byType(SfCalendar);
      final addPageButtonFinder = find.byType(FloatingActionButton);

      expect(headerFinder, findsOneWidget);
      expect(calendarFinder, findsOneWidget);
      expect(addPageButtonFinder, findsOneWidget);
    });

    testWidgets("Diary screen with some pages that are not today should show the add page button", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      var oldDiaryPage = DiaryPage(
        id: now.millisecondsSinceEpoch.toString(),
        title: "Test",
        content: "Test content",
        dateTime: DateTime(2022, 1, 1),
      );

      /// Mock User Service responses
      when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([oldDiaryPage]));
      when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(null));

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: DiaryBody())));

      final headerFinder = find.byType(Header);
      final calendarFinder = find.byType(SfCalendar);
      final addPageButtonFinder = find.byType(FloatingActionButton);

      expect(headerFinder, findsOneWidget);
      expect(calendarFinder, findsOneWidget);
      expect(addPageButtonFinder, findsOneWidget);
    });

    testWidgets("Diary screen with a diary page that is today should not show the add page button", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Mock User Service responses
      when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([diaryPage]));
      when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(null));

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: DiaryBody())));

      final headerFinder = find.byType(Header);
      final calendarFinder = find.byType(SfCalendar);
      final addPageButtonFinder = find.byType(FloatingActionButton);

      expect(headerFinder, findsOneWidget);
      expect(calendarFinder, findsOneWidget);

      /// Expect nothing because we have added by hand a mock diary page with
      /// dateTime = now, so the button must not appear
      expect(addPageButtonFinder, findsNothing);
    });

    testWidgets("Diary screen with a page should show the icon inside the month cell of the calendar", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Mock User Service responses
      when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([diaryPage]));
      when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(null));

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: DiaryBody())));

      /// This will cause the widget to wait for the creation of the month cell with the appointments
      await tester.pump(Duration.zero);

      final headerFinder = find.byType(Header);
      final calendarFinder = find.byType(SfCalendar);
      final iconPageFinder = find.byIcon(Icons.menu_book);

      expect(headerFinder, findsOneWidget);
      expect(calendarFinder, findsOneWidget);
      expect(iconPageFinder, findsOneWidget);
    });
  });

  group("DiaryPage navigation tests", () {
    testWidgets("Tap on the add page button and check that the diary page screen is pushed", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Mock User Service responses
      when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([]));
      when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(null));
      when(mockDiaryViewModel.addNewPage()).thenAnswer((_) {});
      when(mockDiaryViewModel.isEditing).thenAnswer((_) => true);

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: DiaryBody())));

      final addPageButtonFinder = find.byType(FloatingActionButton);
      expect(addPageButtonFinder, findsOneWidget);

      await tester.tap(addPageButtonFinder);
      var verification = verify(mockRouterDelegate.pushPage(name: DiaryPageScreen.route));
      verification.called(1);
    });

    testWidgets("Tap on the diary page icon into the calendar and check that the agenda is shown", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Mock User Service responses
      when(mockDiaryViewModel.diaryPages).thenAnswer((_) => ValueNotifier([diaryPage]));
      when(mockDiaryViewModel.currentDiaryPage).thenAnswer((_) => ValueNotifier(null));

      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: DiaryBody())));

      /// This will cause the widget to wait for the creation of the month cell with the appointments
      await tester.pump(Duration.zero);

      // Check that the agenda is shown
    });
  });
}
