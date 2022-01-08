import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:sApport/Views/Chat/ChatList/components/anonymous_chat_list_body.dart';
import 'package:sApport/Views/Chat/ChatList/components/chat_list_item.dart';
import 'package:sizer/sizer.dart';

import '../../../../navigator.mocks.dart';
import '../../../../view_model.mocks.dart';
import '../../../widget_test_helper.dart';

void main() {
  /// Mock Services
  final mockChatViewModel = MockChatViewModel();
  final mockRouterDelegate = MockAppRouterDelegate();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(FakeFirebaseFirestore()));
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService(MockFirebaseAuth()));
  getIt.registerSingleton<UserService>(UserService());

  //Mock a new random user
  var id = Utils.randomId();
  var name = "Test";
  var surname = "user";
  var email = "test.user@prova.it";
  var birthDate = DateTime(1997, 11, 12);

  BaseUser randomUser = BaseUser(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
  );

  /// Not look for a new user
  when(mockChatViewModel.newRandomUser).thenAnswer((_) => Stream<bool>.value(false));

  /// No pending chats
  when(mockChatViewModel.pendingChats).thenAnswer((_) => ValueNotifier<LinkedHashMap<String, Chat>>(LinkedHashMap<String, Chat>()));

  ///No curent chat
  when(mockChatViewModel.currentChat).thenAnswer((_) => ValueNotifier<Chat?>(null));

  //Add the mock chat to the list
  var mockAnonymousChat = ValueNotifier<LinkedHashMap<String, AnonymousChat>>(LinkedHashMap<String, AnonymousChat>());
  mockAnonymousChat.value['0'] = AnonymousChat(peerUser: randomUser, lastMessage: "test", lastMessageDateTime: DateTime.now(), notReadMessages: 1);
  when(mockChatViewModel.anonymousChats).thenAnswer((_) => mockAnonymousChat);

  /// Get MultiProvider Widget for creating the test
  Widget getMultiProvider({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppRouterDelegate>(create: (_) => mockRouterDelegate),
        ChangeNotifierProvider<ChatViewModel>(create: (_) => mockChatViewModel),
        Provider(create: (context) => ReportViewModel()),
        Provider(create: (context) => UserViewModel()),
      ],
      child: Sizer(builder: (context, orientation, deviceType) {
        return child;
      }),
    );
  }

  group("Correct rendering: ", () {
    testWidgets('Anonymous chat list page with a mock chat listed', (tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      await tester.pumpWidget(getMultiProvider(
          child: new MaterialApp(
        home: new Scaffold(
          body: AnonymousChatListBody(),
        ),
      )));

      final addChatFinder = find.byIcon(Icons.add);
      final chatListItemFinder = find.byType(ChatListItem);

      expect(addChatFinder, findsOneWidget);
      expect(chatListItemFinder, findsOneWidget);
    });
  });

  // group("Correct functions: ", () {
  //   testWidgets('Look for a new user test', (tester) async {
  //     /// Set the device dimensions for the test
  //     WidgetTestHelper.setPortraitDimensions(tester);

  //     await tester.pumpWidget(getMultiProvider(
  //         child: new MaterialApp(
  //       home: new Scaffold(
  //         body: AnonymousChatListBody(),
  //       ),
  //     )));

  //     final addChatFinder = find.byType(FloatingActionButton);
  //     expect(addChatFinder, findsOneWidget);

  //     await tester.ensureVisible(addChatFinder);

  //     await tester.tap(addChatFinder);

  //     var verification = verify(mockChatViewModel.getNewRandomUser());
  //     verification.called(1);
  //   });
  // });
}
