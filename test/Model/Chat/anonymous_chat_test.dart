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

  AnonymousChat anonymousChat = AnonymousChat(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
  );

  /// Add the anonymous chat to the fakeFirebase
  fakeFirebase
      .collection(BaseUser.COLLECTION)
      .doc(userId)
      .collection(anonymousChat.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  group("AnonymousChat initialization", () {
    var anonymousChatTest = AnonymousChat();

    test("Anonymous chat collection initially set to anonymousChats", () {
      expect(anonymousChatTest.collection, AnonymousChat.COLLECTION);
    });

    test("Anonymous chat peer user collection initially set to anonymousChats", () {
      expect(anonymousChatTest.peerCollection, AnonymousChat.PEER_COLLECTION);
    });

    test("Anonymous chat notReadMessages initially set to 0", () {
      expect(anonymousChatTest.notReadMessages, 0);
    });
  });

  group("AnonymousChat data", () {
    test("Anonymous chat factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(BaseUser.COLLECTION).doc(userId).collection(anonymousChat.collection).doc(peerUser.id).get());
      var retrievedAnonymousChat = AnonymousChat.fromDocument(result);

      expect(retrievedAnonymousChat.lastMessage, lastMessage);
      expect(retrievedAnonymousChat.lastMessageDateTime, lastMessageDateTime);
      expect(retrievedAnonymousChat.notReadMessages, notReadMessages);
      expect(retrievedAnonymousChat.peerUser!.id, peerUser.id);
    });
  });
}
