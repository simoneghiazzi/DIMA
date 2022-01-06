import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:mockito/mockito.dart';
import 'package:sApport/Model/DBItems/message.dart';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import '../../service.mocks.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockUserService = MockUserService();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(FirestoreService(fakeFirebase));
  getIt.registerSingleton<UserService>(mockUserService);

  var loggedUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => loggedUser);

  /// Mock Fields
  var peerUser = BaseUser(id: Utils.randomId());
  var lastMessage = "Last message test";
  var lastMessageDateTime = DateTime(2021, 10, 19, 21, 10, 50);
  var notReadMessages = 4;

  /// Mock AnonymousChat used for testing the Chat abstract class
  AnonymousChat mockAnonymousChat = AnonymousChat(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
    peerUser: peerUser,
  );

  /// Add the mock anonymous chat to the fakeFirebase
  fakeFirebase
      .collection(BaseUser.COLLECTION)
      .doc(loggedUser.id)
      .collection(mockAnonymousChat.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  /// Add some mock messages to the fakeFirebase
  var pairChatId = Utils.pairChatId(loggedUser.id, peerUser.id);
  var collectionReference = fakeFirebase.collection(Message.COLLECTION).doc(pairChatId).collection(pairChatId);

  Message message1 = Message(idFrom: peerUser.id, idTo: loggedUser.id, content: "Test 1", timestamp: DateTime(2021, 10, 19, 21, 10, 50));
  Message message2 = Message(idFrom: peerUser.id, idTo: loggedUser.id, content: "Test 2", timestamp: DateTime(2021, 10, 19, 21, 11, 25));
  Message message3 = Message(idFrom: loggedUser.id, idTo: peerUser.id, content: "Test 3", timestamp: DateTime(2021, 10, 19, 21, 13, 40));
  Message message4 = Message(idFrom: peerUser.id, idTo: loggedUser.id, content: "Test 4", timestamp: DateTime(2021, 10, 19, 21, 15, 35));

  List<Message> messages = [message1, message2, message3, message4];

  collectionReference.doc(message1.timestamp.millisecondsSinceEpoch.toString()).set(message1.data);
  collectionReference.doc(message2.timestamp.millisecondsSinceEpoch.toString()).set(message2.data);
  collectionReference.doc(message3.timestamp.millisecondsSinceEpoch.toString()).set(message3.data);
  collectionReference.doc(message4.timestamp.millisecondsSinceEpoch.toString()).set(message4.data);

  group("Chat initialization", () {
    test("Initialized messages value notifier", () async {
      expect(mockAnonymousChat.messages, isA<ValueNotifier<List<Message>>>());
    });
  });

  group("Chat listeners", () {
    mockAnonymousChat.loadMessages();
    int counter = 0;
    mockAnonymousChat.messages.addListener(() {
      counter++;
    });

    test("Subscribe the messages subscriber to the message stream of the firestore service", () {
      expect(mockAnonymousChat.messagesSubscriber, isA<StreamSubscription<QuerySnapshot>>());
    });

    test("Notify the listeners of the value notifier every time a new message is added into the list", () {
      expect(counter, messages.length);
    });

    test("Parse the correct doc snapshot to the list of messages", () async {
      for (int i = 0; i < messages.length; i++) {
        expect(mockAnonymousChat.messages.value[i].idFrom, messages[i].idFrom);
        expect(mockAnonymousChat.messages.value[i].idTo, messages[i].idTo);
        expect(mockAnonymousChat.messages.value[i].content, messages[i].content);
        expect(mockAnonymousChat.messages.value[i].timestamp, messages[i].timestamp);
      }
    });

    test("Add a new message into the list when it is added to the DB in real time", () async {
      /// The fake firestore doc changes doesn't work properly, so we need to manually clear the previous list
      mockAnonymousChat.messages.value.clear();

      Message message5 = Message(idFrom: loggedUser.id, idTo: peerUser.id, content: "Test 5", timestamp: DateTime(2021, 10, 19, 21, 30, 40));
      collectionReference.doc(message5.timestamp.millisecondsSinceEpoch.toString()).set(message5.data);
      await Future.delayed(Duration(seconds: 0));

      expect(mockAnonymousChat.messages.value[4].idFrom, message5.idFrom);
      expect(mockAnonymousChat.messages.value[4].idTo, message5.idTo);
      expect(mockAnonymousChat.messages.value[4].content, message5.content);
      expect(mockAnonymousChat.messages.value[4].timestamp, message5.timestamp);
    });

    test("Clear the old values of the value notifier", () {
      mockAnonymousChat.closeListeners();
      expect(mockAnonymousChat.messages.value.isEmpty, true);
    });
  });
}
