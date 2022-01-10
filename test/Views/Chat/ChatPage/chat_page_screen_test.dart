import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Router/app_router_delegate.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/ViewModel/user_view_model.dart';
import 'package:sApport/Views/Chat/ChatPage/chat_page_screen.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_accept_deny.dart';
import 'package:sApport/Views/Chat/ChatPage/components/chat_top_bar.dart';
import 'package:sApport/Views/Chat/ChatPage/components/date_item.dart';
import 'package:sApport/Views/Chat/ChatPage/components/message_list_item.dart';
import 'package:sApport/Views/Chat/ChatPage/components/new_messages_item.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import '../../../navigator.mocks.dart';
import '../../../view_model.mocks.dart';
import '../../widget_test_helper.dart';
import 'chat_page_screen_test.mocks.dart';

@GenerateMocks([AnonymousChat, PendingChat, ExpertChat, ActiveChat])
void main() {
  /// Mock Services
  final mockChatViewModel = MockChatViewModel();
  final mockRouterDelegate = MockAppRouterDelegate();
  final mockAnonymousChat = MockAnonymousChat();
  final mockPendingChat = MockPendingChat();
  final mockUserViewModel = MockUserViewModel();

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
        Provider<UserViewModel>(create: (context) => mockUserViewModel),
      ],
      child: Sizer(builder: (context, orientation, deviceType) {
        return child;
      }),
    );
  }

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

  //Mock the logged user
  id = Utils.randomId();
  name = "Simone";
  surname = "Luca";
  email = "luca.simone@prova.it";
  birthDate = DateTime(1997, 12, 20);

  BaseUser loggedUser = BaseUser(
    id: id,
    name: name,
    surname: surname,
    email: email,
    birthDate: birthDate,
  );

  when(mockUserViewModel.loggedUser).thenAnswer((realInvocation) => loggedUser);

  ///Mocking an accepted chat and a pending chat
  //var mockChat = AnonymousChat(peerUser: randomUser, lastMessage: "Testing", lastMessageDateTime: DateTime.now(), notReadMessages: 0);
  mockAnonymousChat.peerUser = mockPendingChat.peerUser = randomUser;
  mockAnonymousChat.lastMessage = mockPendingChat.lastMessage = "Testing";
  mockAnonymousChat.lastMessageDateTime = mockPendingChat.lastMessageDateTime = DateTime.now();
  mockAnonymousChat.notReadMessages = mockPendingChat.notReadMessages = 1;

  ///Set the current chat
  when(mockAnonymousChat.messages).thenAnswer(
      (_) => ValueNotifier<List<Message>>([Message(idFrom: randomUser.id, idTo: loggedUser.id, timestamp: DateTime.now(), content: "Testing")]));

  when(mockAnonymousChat.peerUser).thenAnswer((_) => randomUser);

  when(mockAnonymousChat.notReadMessages).thenAnswer((_) => 1);

  when(mockChatViewModel.currentChat).thenAnswer((_) => ValueNotifier(mockAnonymousChat));

  ///Mock the messages text controller
  TextEditingController mockMessagesCtrl = TextEditingController();
  when(mockChatViewModel.contentTextCtrl).thenAnswer((_) => mockMessagesCtrl);

  group("Correct rendering:", () {
    testWidgets('Chat page screen with ongoing discussion (not pending)', (tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      await tester.pumpWidget(getMultiProvider(
          child: new MaterialApp(
        home: new ChatPageScreen(),
      )));

      final topBarAnonymous = find.widgetWithText(ChatTopBar, randomUser.name);
      final dateFinder = find.byType(DateItem);
      final newMessageItemFinder = find.byType(NewMessagesItem);
      final messageFinder = find.widgetWithText(MessageListItem, "Testing");

      expect(topBarAnonymous, findsOneWidget);
      expect(dateFinder, findsOneWidget);
      expect(newMessageItemFinder, findsOneWidget);
      expect(messageFinder, findsOneWidget);
    });

    testWidgets('Chat page screen pending)', (tester) async {
      /// Set the device dimensions for the test
      WidgetTestHelper.setPortraitDimensions(tester);

      ///We need to test with the pending chat
      when(mockPendingChat.messages).thenAnswer(
          (_) => ValueNotifier<List<Message>>([Message(idFrom: randomUser.id, idTo: loggedUser.id, timestamp: DateTime.now(), content: "Testing")]));

      when(mockPendingChat.peerUser).thenAnswer((_) => randomUser);

      when(mockPendingChat.notReadMessages).thenAnswer((_) => 1);

      when(mockChatViewModel.currentChat).thenAnswer((_) => ValueNotifier(mockPendingChat));

      await tester.pumpWidget(getMultiProvider(
          child: new MaterialApp(
        home: new ChatPageScreen(),
      )));

      final pendingFinder = find.byType(ChatAcceptDenyInput);

      expect(pendingFinder, findsOneWidget);
    });
  });
}
