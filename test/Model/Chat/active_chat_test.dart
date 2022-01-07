import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/active_chat.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import '../../service.mocks.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(MockFirestoreService());
  getIt.registerSingleton<UserService>(MockUserService());

  /// Test Fields
  var userId = Utils.randomId();
  var peerUser = BaseUser(id: Utils.randomId());

  var lastMessage = "Last message test";
  var lastMessageDateTime = DateTime(2021, 10, 19, 21, 10, 50);
  var notReadMessages = 4;

  ActiveChat activeChat = ActiveChat(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
  );

  /// Add the active chat to the fakeFirebase
  fakeFirebase
      .collection(Expert.COLLECTION)
      .doc(userId)
      .collection(activeChat.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  group("ActiveChat initialization", () {
    var activeChatTest = ActiveChat();

    test("Active chat collection initially set to activeChats", () {
      expect(activeChatTest.collection, ActiveChat.COLLECTION);
    });

    test("Active chat peer user collection initially set to expertsChats", () {
      expect(activeChatTest.peerCollection, ActiveChat.PEER_COLLECTION);
    });

    test("Active chat notReadMessages initially set to 0", () {
      expect(activeChatTest.notReadMessages, 0);
    });
  });

  group("ActiveChat data", () {
    test("Active chat factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(Expert.COLLECTION).doc(userId).collection(activeChat.collection).doc(peerUser.id).get());
      var retrievedActiveChat = ActiveChat.fromDocument(result);

      expect(retrievedActiveChat.lastMessage, lastMessage);
      expect(retrievedActiveChat.lastMessageDateTime, lastMessageDateTime);
      expect(retrievedActiveChat.notReadMessages, notReadMessages);
      expect(retrievedActiveChat.peerUser!.id, peerUser.id);
    });
  });
}
