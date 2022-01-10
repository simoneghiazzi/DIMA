import 'dart:async';
import 'dart:collection';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/chat.dart';
import 'package:sApport/Model/Chat/request.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/ViewModel/chat_view_model.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import '../test_helper.dart';
import '../service.mocks.dart';
import '../Views/Chat/ChatPage/chat_page_screen_test.mocks.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirestoreService = MockFirestoreService();
  final mockUserService = MockUserService();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<UserService>(mockUserService);

  /// Test Helper
  final testHelper = TestHelper();
  await testHelper.attachDB(fakeFirebase);

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => testHelper.loggedUser);

  /// Mock FirestoreService responses
  when(mockFirestoreService.getUserByIdFromDB(any, any)).thenAnswer((value) =>
      fakeFirebase.collection(value.positionalArguments[0]).where(FieldPath.documentId, isEqualTo: value.positionalArguments[1]).limit(1).get());
  when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, AnonymousChat.COLLECTION)).thenAnswer((_) => testHelper.anonymousChatsStream);
  when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, PendingChat.COLLECTION)).thenAnswer((_) => testHelper.pendingChatsStream);
  when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, ExpertChat.COLLECTION)).thenAnswer((_) => testHelper.expertChatsStream);
  when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, ActiveChat.COLLECTION)).thenAnswer((_) => testHelper.activeChatsStream);
  when(mockFirestoreService.getMessagesStreamFromDB(any)).thenAnswer((_) => fakeFirebase.collection("empty").snapshots());
  when(mockFirestoreService.getRandomUserFromDB(testHelper.loggedUser, any)).thenAnswer((_) async {
    var randomUser = await fakeFirebase.collection(BaseUser.COLLECTION).where(FieldPath.documentId, isEqualTo: testHelper.baseUser2.id).get();
    return randomUser.docs.first;
  });

  final chatViewModel = ChatViewModel();
  var now = DateTime.now();

  group("ChatViewModel initialization:", () {
    test("Check that the content text controller is correctly initialized", () {
      expect(chatViewModel.contentTextCtrl, isA<TextEditingController>());
    });

    test("Check that the current chat is correctly initialized to the value notifier with null value", () {
      expect(chatViewModel.currentChat, isA<ValueNotifier<Chat?>>());
      expect(chatViewModel.currentChat.value, isNull);
    });

    test("Check that the anonymous chats list is correctly initialized to the value notifier with an empty linked HashMap", () {
      expect(chatViewModel.anonymousChats, isA<ValueNotifier<LinkedHashMap<String, AnonymousChat>>>());
      expect(chatViewModel.anonymousChats.value, isEmpty);
    });

    test("Check that the pending chats list is correctly initialized to the value notifier with an empty linked HashMap", () {
      expect(chatViewModel.pendingChats, isA<ValueNotifier<LinkedHashMap<String, PendingChat>>>());
      expect(chatViewModel.pendingChats.value, isEmpty);
    });

    test("Check that the experts chats list is correctly initialized to the value notifier with an empty linked HashMap", () {
      expect(chatViewModel.expertsChats, isA<ValueNotifier<LinkedHashMap<String, ExpertChat>>>());
      expect(chatViewModel.expertsChats.value, isEmpty);
    });

    test("Check that the active chats list is correctly initialized to the value notifier with an empty linked HashMap", () {
      expect(chatViewModel.activeChats, isA<ValueNotifier<LinkedHashMap<String, ActiveChat>>>());
      expect(chatViewModel.activeChats.value, isEmpty);
    });

    test("Check that the new random user stream is correctly initialized", () {
      expect(chatViewModel.newRandomUser, isA<Stream<bool>>());
      expect(chatViewModel.newRandomUser.isBroadcast, isTrue);
    });
  });

  group("ChatViewModel interaction with services:", () {
    setUp(() => clearInteractions(mockFirestoreService));

    group("Chatting with:", () {
      test("Update chatting with should call the update user field method of the firestore service with the id of the peer user", () async {
        chatViewModel.currentChat.value = testHelper.anonymousChat;
        await chatViewModel.updateChattingWith();

        var verification = verify(mockFirestoreService.updateUserFieldIntoDB(testHelper.loggedUser, "chattingWith", captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0], testHelper.anonymousChat.peerUser!.id);
      });

      test("Reset chatting with should call the update user field method of the firestore service with null", () async {
        chatViewModel.currentChat.value = testHelper.anonymousChat;
        await chatViewModel.resetChattingWith();

        var verification = verify(mockFirestoreService.updateUserFieldIntoDB(testHelper.loggedUser, "chattingWith", captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0], isNull);
      });
    });

    group("Send message:", () {
      var anonymousChat;
      var text;

      setUp(() {
        anonymousChat = AnonymousChat(
          lastMessage: "Message user 1",
          lastMessageDateTime: DateTime(2021, 10, 19, 21, 10, 50),
          peerUser: testHelper.baseUser,
        );
        chatViewModel.currentChat.value = anonymousChat;

        /// Test Field
        text = "New message text";
        chatViewModel.contentTextCtrl.text = text;
      });
      test("Check that send message updates the values of the current chat", () async {
        var previousDateTime = anonymousChat.lastMessageDateTime;

        await chatViewModel.sendMessage();

        expect(chatViewModel.currentChat.value!.lastMessage, text);
        expect(chatViewModel.currentChat.value!.lastMessageDateTime, isNot(equals(previousDateTime)));
        expect(chatViewModel.currentChat.value!.lastMessageDateTime!.day, now.day);
        expect(chatViewModel.currentChat.value!.lastMessageDateTime!.month, now.month);
        expect(chatViewModel.currentChat.value!.lastMessageDateTime!.year, now.year);
      });

      test("Send message should call the add message method of the firestore service with the correct parameters", () async {
        await chatViewModel.sendMessage();

        var verification = verify(mockFirestoreService.addMessageIntoDB(testHelper.loggedUser, anonymousChat, captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0].idFrom, testHelper.loggedUser.id);
        expect(verification.captured[0].idTo, anonymousChat.peerUser!.id);
        expect(verification.captured[0].timestamp, anonymousChat.lastMessageDateTime);
        expect(verification.captured[0].content, anonymousChat.lastMessage);
      });

      test("Send message should clear the content text controller value", () async {
        await chatViewModel.sendMessage();

        expect(chatViewModel.contentTextCtrl.text, isEmpty);
      });

      test("Check that if an error occurs when submitting the page it catches the error and it does not clear the text controller", () async {
        /// Mock Firebase error
        when(mockFirestoreService.addMessageIntoDB(testHelper.loggedUser, any, any)).thenAnswer((_) async {
          return Future.error(Error);
        });

        await chatViewModel.sendMessage();

        expect(chatViewModel.contentTextCtrl.text, text);
      });
    });

    group("Set message as read:", () {
      test("Check that set message as read updates the values of the current chat", () async {
        testHelper.anonymousChat.notReadMessages = 5;
        chatViewModel.currentChat.value = testHelper.anonymousChat;

        await chatViewModel.setMessagesAsRead();

        expect(chatViewModel.currentChat.value!.notReadMessages, isZero);
      });

      test("Set messages as read message should call the set messages as read method of the firestore service with the correct parameters", () async {
        testHelper.anonymousChat.notReadMessages = 5;
        chatViewModel.currentChat.value = testHelper.anonymousChat;

        await chatViewModel.setMessagesAsRead();

        verify(mockFirestoreService.setMessagesAsRead(testHelper.loggedUser, testHelper.anonymousChat)).called(1);
      });

      test("Check that if an error occurs when set messages as read it catches the error", () async {
        testHelper.anonymousChat.notReadMessages = 5;
        chatViewModel.currentChat.value = testHelper.anonymousChat;

        /// Mock Firebase error
        when(mockFirestoreService.setMessagesAsRead(testHelper.loggedUser, testHelper.anonymousChat)).thenAnswer((_) async {
          return Future.error(Error);
        });

        await chatViewModel.setMessagesAsRead();
      });
    });

    group("Get new random user:", () {
      test("Check that get new random user sets the current chat with the request", () async {
        await chatViewModel.getNewRandomUser();

        expect(chatViewModel.currentChat.value, isA<Request>());
        expect(chatViewModel.currentChat.value!.peerUser!.id, testHelper.baseUser2.id);
      });

      test("Get new random user should call the get random user method of the firestore service with the correct parameters", () async {
        await chatViewModel.getNewRandomUser();

        verify(mockFirestoreService.getRandomUserFromDB(testHelper.loggedUser, any)).called(1);
      });

      test("Get new random user should add true to the new random user controller if a new user is found", () async {
        expect(chatViewModel.newRandomUser, emits(isTrue));

        await chatViewModel.getNewRandomUser();
      });

      test("Get new random user should add false to the new random user controller if no user is found", () async {
        when(mockFirestoreService.getRandomUserFromDB(testHelper.loggedUser, any)).thenAnswer((_) => Future.value(null));

        expect(chatViewModel.newRandomUser, emits(isFalse));

        await chatViewModel.getNewRandomUser();
      });

      test("Check that if an error occurs when getting a new random user it catches the error and adds false to the new random user controller",
          () async {
        /// Mock Firebase error
        when(mockFirestoreService.getRandomUserFromDB(testHelper.loggedUser, any)).thenAnswer((_) async {
          return Future.error(Error);
        });

        expect(chatViewModel.newRandomUser, emits(isFalse));

        await chatViewModel.getNewRandomUser();
      });
    });

    group("Accept pending chat:", () {
      int counter = 0;
      chatViewModel.pendingChats.addListener(() {
        counter++;
      });

      setUp(() async {
        counter = 0;
        chatViewModel.pendingChats.value.clear();

        var pendingHashMap = LinkedHashMap<String, PendingChat>();
        pendingHashMap["${testHelper.pendingChat_5.peerUser!.id}"] = testHelper.pendingChat_5;
        pendingHashMap["${testHelper.pendingChat2_6.peerUser!.id}"] = testHelper.pendingChat2_6;
        chatViewModel.pendingChats.value = pendingHashMap;
        chatViewModel.currentChat.value = testHelper.pendingChat_5;

        await chatViewModel.acceptPendingChat();
      });

      test("Check that accept pending chat removes the chat from the pending chat list", () async {
        expect(chatViewModel.pendingChats.value, isNot(contains(testHelper.pendingChat_5)));
      });

      test("Accept pending chat should call the accept pending chat method of the firestore service with the correct parameters", () async {
        verify(mockFirestoreService.upgradePendingToActiveChatIntoDB(testHelper.loggedUser, testHelper.pendingChat_5)).called(1);
      });

      test("Check that accept pending chat sets the current chat with the anonymous chat", () async {
        expect(chatViewModel.currentChat.value, isA<AnonymousChat>());
        expect(chatViewModel.currentChat.value!.peerUser!.id, testHelper.baseUser5.id);
      });

      test("Check that the value notifier notify the listeners when the chat is accepted", () async {
        expect(counter, 1);
      });

      test("Check that if an error occurs when accepting the pending chat it catches the error", () async {
        /// Mock Firebase error
        when(mockFirestoreService.upgradePendingToActiveChatIntoDB(testHelper.loggedUser, testHelper.pendingChat_5)).thenAnswer((_) async {
          return Future.error(Error);
        });
        chatViewModel.currentChat.value = testHelper.pendingChat_5;

        await chatViewModel.acceptPendingChat();
      });
    });

    group("Deny pending chat:", () {
      int counter = 0;
      chatViewModel.pendingChats.addListener(() {
        counter++;
      });

      setUp(() async {
        counter = 0;
        chatViewModel.pendingChats.value.clear();

        var pendingHashMap = LinkedHashMap<String, PendingChat>();
        pendingHashMap["${testHelper.pendingChat_5.peerUser!.id}"] = testHelper.pendingChat_5;
        pendingHashMap["${testHelper.pendingChat2_6.peerUser!.id}"] = testHelper.pendingChat2_6;
        chatViewModel.pendingChats.value = pendingHashMap;
        chatViewModel.currentChat.value = testHelper.pendingChat_5;

        await chatViewModel.denyPendingChat();
      });

      test("Check that deny pending chat removes the chat from the pending chat list", () async {
        expect(chatViewModel.pendingChats.value, isNot(contains(testHelper.pendingChat_5)));
      });

      test("Deny pending chat should call the remove chat method of the firestore service with the correct parameters", () async {
        verify(mockFirestoreService.removeChatFromDB(testHelper.loggedUser, testHelper.pendingChat_5)).called(1);
      });

      test("Deny pending chat should call the remove messages method of the firestore service with the correct parameters", () async {
        verify(mockFirestoreService.removeMessagesFromDB(Utils.pairChatId(testHelper.loggedUser.id, testHelper.pendingChat_5.peerUser!.id)))
            .called(1);
      });

      test("Check that deny pending chat sets the current chat value to null", () async {
        expect(chatViewModel.currentChat.value, isNull);
      });

      test("Check that the value notifier notify the listeners when the chat is denied", () async {
        expect(counter, 1);
      });
    });

    group("Load anonymous chats:", () {
      int counter = 0;
      chatViewModel.anonymousChats.addListener(() {
        counter++;
      });

      setUp(() async {
        counter = 0;
        chatViewModel.anonymousChats.value.clear();

        /// Load the anonymous chats
        chatViewModel.loadAnonymousChats();
        await Future.delayed(Duration.zero);
      });

      test("Check the subscription of the anonymous chats subscriber to the get chats stream of the firestore service", () async {
        expect(chatViewModel.anonymousChatsSubscriber, isA<StreamSubscription<QuerySnapshot>>());
      });

      test("Check that the value notifier notify the listeners every time a new anonymous chat is added into the HashMap of anonymous chats",
          () async {
        expect(counter, testHelper.anonymousChats.length);
      });

      test("Check that the initially inserted anonymous chats are correctly parsed and added to the hashmap of anonymous chats in the correct order",
          () async {
        for (int i = 0; i < testHelper.anonymousChats.length; i++) {
          expect(chatViewModel.anonymousChats.value.values.elementAt(i).peerUser!.id, testHelper.anonymousChats[i].peerUser!.id);
          expect(chatViewModel.anonymousChats.value.values.elementAt(i).lastMessage, testHelper.anonymousChats[i].lastMessage);
          expect(chatViewModel.anonymousChats.value.values.elementAt(i).lastMessageDateTime, testHelper.anonymousChats[i].lastMessageDateTime);
          expect(chatViewModel.anonymousChats.value.values.elementAt(i).notReadMessages, testHelper.anonymousChats[i].notReadMessages);
        }
      });

      test("Add a new anonymous chat into the DB should trigger the listener in order to add this new chat into the chats HashMap", () async {
        /// The fake firestore doc changes doesn't work properly, so we need to manually clear the previous list
        chatViewModel.anonymousChats.value.clear();

        var anonymousChat4 = AnonymousChat(
          lastMessage: "Message user 4",
          lastMessageDateTime: DateTime(2022, 1, 10, 21, 10, 50),
          peerUser: testHelper.baseUser4,
        );

        fakeFirebase
            .collection(BaseUser.COLLECTION)
            .doc(testHelper.loggedUser.id)
            .collection(AnonymousChat.COLLECTION)
            .doc(anonymousChat4.peerUser!.id)
            .set({
          "lastMessageTimestamp": anonymousChat4.lastMessageDateTime!.millisecondsSinceEpoch,
          "notReadMessages": anonymousChat4.notReadMessages,
          "lastMessage": anonymousChat4.lastMessage
        });

        await Future.delayed(Duration.zero);

        /// Add with most recent datetime, so it should be in position 4
        expect(chatViewModel.anonymousChats.value.values.elementAt(3).peerUser!.id, anonymousChat4.peerUser!.id);
        expect(chatViewModel.anonymousChats.value.values.elementAt(3).lastMessage, anonymousChat4.lastMessage);
        expect(chatViewModel.anonymousChats.value.values.elementAt(3).lastMessageDateTime, anonymousChat4.lastMessageDateTime);
        expect(chatViewModel.anonymousChats.value.values.elementAt(3).notReadMessages, anonymousChat4.notReadMessages);
      });

      test("Check that if an error occurs when loading the anonymous chats it catches the error", () {
        /// Mock Firebase error
        when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, AnonymousChat.COLLECTION)).thenAnswer((_) async* {
          throw Exception("Firebase stream not allowed");
        });
        chatViewModel.loadAnonymousChats();
      });
    });

    group("Load pending chats:", () {
      int counter = 0;
      chatViewModel.pendingChats.addListener(() {
        counter++;
      });

      setUp(() async {
        counter = 0;
        chatViewModel.pendingChats.value.clear();

        /// Load the pending chats
        chatViewModel.loadPendingChats();
        await Future.delayed(Duration.zero);
      });

      test("Check the subscription of the pending chats subscriber to the get chats stream of the firestore service", () async {
        expect(chatViewModel.pendingChatsSubscriber, isA<StreamSubscription<QuerySnapshot>>());
      });

      test("Check that the value notifier notify the listeners every time a new pending chat is added into the HashMap of pending chats", () async {
        expect(counter, testHelper.pendingChats.length);
      });

      test("Check that the initially inserted pending chats are correctly parsed and added to the hashmap of pending chats in the correct order",
          () async {
        for (int i = 0; i < testHelper.pendingChats.length; i++) {
          expect(chatViewModel.pendingChats.value.values.elementAt(i).peerUser!.id, testHelper.pendingChats[i].peerUser!.id);
          expect(chatViewModel.pendingChats.value.values.elementAt(i).lastMessage, testHelper.pendingChats[i].lastMessage);
          expect(chatViewModel.pendingChats.value.values.elementAt(i).lastMessageDateTime, testHelper.pendingChats[i].lastMessageDateTime);
          expect(chatViewModel.pendingChats.value.values.elementAt(i).notReadMessages, testHelper.pendingChats[i].notReadMessages);
        }
      });

      test("Add a new pending chat into the DB should trigger the listener in order to add this new chat into the chats HashMap", () async {
        /// The fake firestore doc changes doesn't work properly, so we need to manually clear the previous list
        chatViewModel.pendingChats.value.clear();

        var pendingChat3 = PendingChat(
          lastMessage: "Message user 3",
          lastMessageDateTime: DateTime(2022, 1, 10, 21, 10, 50),
          peerUser: testHelper.baseUser4,
        );

        fakeFirebase
            .collection(BaseUser.COLLECTION)
            .doc(testHelper.loggedUser.id)
            .collection(PendingChat.COLLECTION)
            .doc(pendingChat3.peerUser!.id)
            .set({
          "lastMessageTimestamp": pendingChat3.lastMessageDateTime!.millisecondsSinceEpoch,
          "notReadMessages": pendingChat3.notReadMessages,
          "lastMessage": pendingChat3.lastMessage
        });

        await Future.delayed(Duration.zero);

        /// Add with most recent datetime, so it should be in position 3
        expect(chatViewModel.pendingChats.value.values.elementAt(2).peerUser!.id, pendingChat3.peerUser!.id);
        expect(chatViewModel.pendingChats.value.values.elementAt(2).lastMessage, pendingChat3.lastMessage);
        expect(chatViewModel.pendingChats.value.values.elementAt(2).lastMessageDateTime, pendingChat3.lastMessageDateTime);
        expect(chatViewModel.pendingChats.value.values.elementAt(2).notReadMessages, pendingChat3.notReadMessages);
      });

      test("Check that if an error occurs when loading the pending chats it catches the error", () {
        /// Mock Firebase error
        when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, PendingChat.COLLECTION)).thenAnswer((_) async* {
          throw Exception("Firebase stream not allowed");
        });
        chatViewModel.loadPendingChats();
      });
    });

    group("Load active chats:", () {
      int counter = 0;
      chatViewModel.activeChats.addListener(() {
        counter++;
      });

      setUp(() async {
        counter = 0;
        chatViewModel.activeChats.value.clear();

        /// Load the active chats
        chatViewModel.loadActiveChats();
        await Future.delayed(Duration.zero);
      });

      test("Check the subscription of the active chats subscriber to the get chats stream of the firestore service", () async {
        expect(chatViewModel.activeChatsSubscriber, isA<StreamSubscription<QuerySnapshot>>());
      });

      test("Check that the value notifier notify the listeners every time a new active chat is added into the HashMap of active chats", () async {
        expect(counter, testHelper.activeChats.length);
      });

      test("Check that the initially inserted active chats are correctly parsed and added to the hashmap of active chats in the correct order",
          () async {
        for (int i = 0; i < testHelper.activeChats.length; i++) {
          expect(chatViewModel.activeChats.value.values.elementAt(i).peerUser!.id, testHelper.activeChats[i].peerUser!.id);
          expect(chatViewModel.activeChats.value.values.elementAt(i).lastMessage, testHelper.activeChats[i].lastMessage);
          expect(chatViewModel.activeChats.value.values.elementAt(i).lastMessageDateTime, testHelper.activeChats[i].lastMessageDateTime);
          expect(chatViewModel.activeChats.value.values.elementAt(i).notReadMessages, testHelper.activeChats[i].notReadMessages);
        }
      });

      test("Add a new active chat into the DB should trigger the listener in order to add this new chat into the chats HashMap", () async {
        /// The fake firestore doc changes doesn't work properly, so we need to manually clear the previous list
        chatViewModel.activeChats.value.clear();

        var activeChat4 = ActiveChat(
          lastMessage: "Message user 3",
          lastMessageDateTime: DateTime(2022, 1, 10, 21, 10, 50),
          peerUser: testHelper.baseUser4,
        );

        fakeFirebase
            .collection(Expert.COLLECTION)
            .doc(testHelper.loggedExpert.id)
            .collection(ActiveChat.COLLECTION)
            .doc(activeChat4.peerUser!.id)
            .set({
          "lastMessageTimestamp": activeChat4.lastMessageDateTime!.millisecondsSinceEpoch,
          "notReadMessages": activeChat4.notReadMessages,
          "lastMessage": activeChat4.lastMessage
        });

        await Future.delayed(Duration.zero);

        /// Add with most recent datetime, so it should be in position 3
        expect(chatViewModel.activeChats.value.values.elementAt(3).peerUser!.id, activeChat4.peerUser!.id);
        expect(chatViewModel.activeChats.value.values.elementAt(3).lastMessage, activeChat4.lastMessage);
        expect(chatViewModel.activeChats.value.values.elementAt(3).lastMessageDateTime, activeChat4.lastMessageDateTime);
        expect(chatViewModel.activeChats.value.values.elementAt(3).notReadMessages, activeChat4.notReadMessages);
      });

      test("Check that if an error occurs when loading the active chats it catches the error", () {
        /// Mock Firebase error
        when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, ActiveChat.COLLECTION)).thenAnswer((_) async* {
          throw Exception("Firebase stream not allowed");
        });
        chatViewModel.loadActiveChats();
      });
    });

    group("Load experts chats:", () {
      int counter = 0;
      chatViewModel.expertsChats.addListener(() {
        counter++;
      });

      setUp(() async {
        counter = 0;
        chatViewModel.expertsChats.value.clear();

        /// Load the experts chats
        chatViewModel.loadExpertsChats();
        await Future.delayed(Duration.zero);
      });

      test("Check the subscription of the experts chats subscriber to the get chats stream of the firestore service", () async {
        expect(chatViewModel.expertsChatsSubscriber, isA<StreamSubscription<QuerySnapshot>>());
      });

      test("Check that the value notifier notify the listeners every time a new experts chat is added into the HashMap of experts chats", () async {
        expect(counter, testHelper.expertsChats.length);
      });

      test("Check that the initially inserted experts chats are correctly parsed and added to the hashmap of experts chats in the correct order",
          () async {
        for (int i = 0; i < testHelper.expertsChats.length; i++) {
          expect(chatViewModel.expertsChats.value.values.elementAt(i).peerUser!.id, testHelper.expertsChats[i].peerUser!.id);
          expect(chatViewModel.expertsChats.value.values.elementAt(i).lastMessage, testHelper.expertsChats[i].lastMessage);
          expect(chatViewModel.expertsChats.value.values.elementAt(i).lastMessageDateTime, testHelper.expertsChats[i].lastMessageDateTime);
          expect(chatViewModel.expertsChats.value.values.elementAt(i).notReadMessages, testHelper.expertsChats[i].notReadMessages);
        }
      });

      test("Add a new experts chat into the DB should trigger the listener in order to add this new chat into the chats HashMap", () async {
        /// The fake firestore doc changes doesn't work properly, so we need to manually clear the previous list
        chatViewModel.expertsChats.value.clear();

        var expertChat3 = ExpertChat(
          lastMessage: "Message user 3",
          lastMessageDateTime: DateTime(2022, 1, 10, 21, 10, 50),
          peerUser: testHelper.expert3,
        );

        fakeFirebase
            .collection(BaseUser.COLLECTION)
            .doc(testHelper.loggedUser.id)
            .collection(ExpertChat.COLLECTION)
            .doc(expertChat3.peerUser!.id)
            .set({
          "lastMessageTimestamp": expertChat3.lastMessageDateTime!.millisecondsSinceEpoch,
          "notReadMessages": expertChat3.notReadMessages,
          "lastMessage": expertChat3.lastMessage
        });

        await Future.delayed(Duration.zero);

        /// Add with most recent datetime, so it should be in position 3
        expect(chatViewModel.expertsChats.value.values.elementAt(2).peerUser!.id, expertChat3.peerUser!.id);
        expect(chatViewModel.expertsChats.value.values.elementAt(2).lastMessage, expertChat3.lastMessage);
        expect(chatViewModel.expertsChats.value.values.elementAt(2).lastMessageDateTime, expertChat3.lastMessageDateTime);
        expect(chatViewModel.expertsChats.value.values.elementAt(2).notReadMessages, expertChat3.notReadMessages);
      });

      test("Check that if an error occurs when loading the experts chats it catches the error", () {
        /// Mock Firebase error
        when(mockFirestoreService.getChatsStreamFromDB(testHelper.loggedUser, ExpertChat.COLLECTION)).thenAnswer((_) async* {
          throw Exception("Firebase stream not allowed");
        });
        chatViewModel.loadExpertsChats();
      });
    });

    group("ChatViewModel internal managment:", () {
      group("Set current chat:", () {
        setUp(() => chatViewModel.resetCurrentChat());

        test("Check that set current chat sets the correct field of the value notifier", () {
          chatViewModel.setCurrentChat(testHelper.anonymousChat);

          expect(chatViewModel.currentChat.value, testHelper.anonymousChat);
        });
      });

      group("Reset current chat:", () {
        test("Check that reset current chat sets the field of the value notifier to null", () {
          chatViewModel.currentChat.value = testHelper.anonymousChat;
          chatViewModel.resetCurrentChat();
          expect(chatViewModel.currentChat.value, isNull);
        });

        test("Check that reset current chat clears the value of the text controller", () {
          chatViewModel.contentTextCtrl.text = "Prova";
          chatViewModel.resetCurrentChat();
          expect(chatViewModel.contentTextCtrl.text, isEmpty);
        });
      });

      group("Add new chat:", () {
        setUp(() => chatViewModel.resetCurrentChat());
        test("Check that add new chat calls the load messages method of the chat", () {
          var mockAnonymousChat = MockAnonymousChat();
          chatViewModel.addNewChat(mockAnonymousChat);

          verify(mockAnonymousChat.loadMessages()).called(1);
        });

        test("Check that add new chat sets the current chat with the correct field", () {
          chatViewModel.addNewChat(testHelper.anonymousChat);

          expect(chatViewModel.currentChat.value, testHelper.anonymousChat);
        });
      });

      group("Close listeners:", () {
        var mockAnonymousChat = MockAnonymousChat();
        var mockAnonymousChat2 = MockAnonymousChat();
        var mockPendingChat = MockPendingChat();
        var mockPendingChat2 = MockPendingChat();
        var mockActiveChat = MockActiveChat();
        var mockActiveChat2 = MockActiveChat();
        var mockExpertChat = MockExpertChat();
        var mockExpertChat2 = MockExpertChat();

        setUp(() {
          var anonymousHashMap = LinkedHashMap<String, AnonymousChat>();
          anonymousHashMap["prova"] = mockAnonymousChat;
          anonymousHashMap["prova2"] = mockAnonymousChat2;
          chatViewModel.anonymousChats.value = anonymousHashMap;

          var pendingHashMap = LinkedHashMap<String, PendingChat>();
          pendingHashMap["prova"] = mockPendingChat;
          pendingHashMap["prova2"] = mockPendingChat2;
          chatViewModel.pendingChats.value = pendingHashMap;

          var activeHashMap = LinkedHashMap<String, ActiveChat>();
          activeHashMap["prova"] = mockActiveChat;
          activeHashMap["prova2"] = mockActiveChat2;
          chatViewModel.activeChats.value = activeHashMap;

          var expertsHashMap = LinkedHashMap<String, ExpertChat>();
          expertsHashMap["prova"] = mockExpertChat;
          expertsHashMap["prova2"] = mockExpertChat2;
          chatViewModel.expertsChats.value = expertsHashMap;

          clearInteractions(mockAnonymousChat);
          clearInteractions(mockAnonymousChat2);
          clearInteractions(mockPendingChat);
          clearInteractions(mockPendingChat2);
          clearInteractions(mockActiveChat);
          clearInteractions(mockActiveChat2);
          clearInteractions(mockExpertChat);
          clearInteractions(mockExpertChat2);
        });

        test("Close listeners should clear the old values of the all the chats HashMap value notifiers", () {
          chatViewModel.closeListeners();

          expect(chatViewModel.anonymousChats.value, isEmpty);
          expect(chatViewModel.pendingChats.value, isEmpty);
          expect(chatViewModel.activeChats.value, isEmpty);
          expect(chatViewModel.expertsChats.value, isEmpty);
        });

        test("Close listeners should call the close listeners method of every chat of all the chats HashMap value notifiers", () {
          chatViewModel.closeListeners();

          verify(mockAnonymousChat.closeListeners()).called(1);
          verify(mockPendingChat.closeListeners()).called(1);
          verify(mockActiveChat.closeListeners()).called(1);
          verify(mockExpertChat.closeListeners()).called(1);
          verify(mockAnonymousChat2.closeListeners()).called(1);
          verify(mockPendingChat2.closeListeners()).called(1);
          verify(mockActiveChat2.closeListeners()).called(1);
          verify(mockExpertChat2.closeListeners()).called(1);
        });

        test("Close listener should reset the current chat", () {
          chatViewModel.currentChat.value = testHelper.anonymousChat;
          chatViewModel.closeListeners();

          expect(chatViewModel.currentChat.value, isNull);
        });
      });
    });
  });
}
