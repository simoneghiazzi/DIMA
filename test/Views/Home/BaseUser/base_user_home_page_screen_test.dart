import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/Diary/diary_view_model.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:sApport/Views/Chat/ChatList/chat_list_screen.dart';
import 'package:sApport/Views/Chat/ChatList/components/anonymous_chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/expert_chat_list_body.dart';
import 'package:sApport/Views/Home/BaseUser/components/base_user_home_page_body.dart';
import 'package:sApport/Views/Home/BaseUser/components/dash_card.dart';
import 'package:sApport/Views/Map/map_screen.dart';
import 'package:sApport/Views/Report/create_report_screen.dart';
import 'package:sizer/sizer.dart';

import '../../../navigator.mocks.dart';
import '../../../view_model.mocks.dart';
import '../../widget_test_helper.dart';

void main() async {
  /// Mock Services
  final mockChatViewModel = MockChatViewModel();
  final mockRouterDelegate = MockAppRouterDelegate();
  final mockDiaryViewModel = MockDiaryViewModel();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  /// Get MultiProvider Widget for creating the test
  Widget getMultiProvider({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => mockRouterDelegate),
        ChangeNotifierProvider<ChatViewModel>(create: (_) => mockChatViewModel),
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
    testWidgets("Testing the correct render of a basic user's homepage", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Create the base user homepage widget
      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: BaseUserHomePageBody())));

      /// Verify that the main elements of the user's home page are found
      final spacerFinder = find.byType(Spacer);
      final gridFinder = find.byType(Table);
      final dashCardFinder = find.byType(DashCard);

      expect(spacerFinder, findsNWidgets(2));
      expect(gridFinder, findsOneWidget);
      expect(dashCardFinder, findsNWidgets(4));
    });
  });

  group("Navigation tests:", () {
    testWidgets("Testing the correct call of the experts' chats list screen", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Create the base user homepage widget
      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: BaseUserHomePageBody())));

      /// Look for the dash card that brings to the expters chats list
      final expertsChatsCardFinder = find.widgetWithText(DashCard, "Experts\nchats");
      expect(expertsChatsCardFinder, findsOneWidget);

      /// Check the push page call
      await tester.tap(expertsChatsCardFinder);
      var verification = verify(mockRouterDelegate.pushPage(name: ChatListScreen.route, arguments: captureAnyNamed("arguments")));
      verification.called(1);

      /// Push page parameters verification
      expect(verification.captured[0], isA<ExpertChatListBody>());
    });

    testWidgets("Testing the correct call of the anonymous chats list screen", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Create the base user homepage widget
      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: BaseUserHomePageBody())));

      /// Look for the dash card that brings to the anonymous chats list
      final anonymousChatsCardFinder = find.widgetWithText(DashCard, "Anonymous\nchats");
      expect(anonymousChatsCardFinder, findsOneWidget);

      /// Check the push page call
      await tester.tap(anonymousChatsCardFinder);
      var verification = verify(mockRouterDelegate.pushPage(name: ChatListScreen.route, arguments: captureAnyNamed("arguments")));
      verification.called(1);

      /// Push page parameters verification
      expect(verification.captured[0], isA<AnonymousChatListBody>());
    });

    testWidgets("Testing the correct call of the map screen", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Create the base user homepage widget
      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: BaseUserHomePageBody())));

      /// Look for the dash card that brings to the map page
      final mapCardFinder = find.widgetWithText(DashCard, "Find an\nexpert");
      expect(mapCardFinder, findsOneWidget);

      /// Check the push page call
      await tester.tap(mapCardFinder);
      var verification = verify(mockRouterDelegate.pushPage(name: MapScreen.route));
      verification.called(1);
    });

    testWidgets("Testing the correct call of the reports screen", (WidgetTester tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      /// Create the base user homepage widget
      await tester.pumpWidget(getMultiProvider(child: MaterialApp(home: BaseUserHomePageBody())));

      /// Look for the dash card that brings to the anonymous reports page
      final reportsCardFinder = find.widgetWithText(DashCard, 'Anonymous\nreports');
      expect(reportsCardFinder, findsOneWidget);

      /// Check the push page call
      await tester.tap(reportsCardFinder);
      var verification = verify(mockRouterDelegate.pushPage(name: CreateReportScreen.route));
      verification.called(1);
    });
  });
}
