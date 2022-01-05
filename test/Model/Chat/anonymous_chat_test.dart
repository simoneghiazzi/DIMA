import 'package:get_it/get_it.dart';
import 'package:sApport/Model/Chat/anonymous_chat.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/Expert/expert.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/utils.dart';
import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../service.mocks.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Register Services
  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(MockFirestoreService());
  getIt.registerSingleton<UserService>(MockUserService());

  /// Mock Fields
  var userId = Utils.randomId();
  var peerUser = BaseUser(id: Utils.randomId());

  var lastMessage = "Last message test";
  var lastMessageDateTime = DateTime(2021, 10, 19, 21, 10, 50);
  var notReadMessages = 4;

  /// Mock AnonymousChat
  AnonymousChat mockAnonymousChat = AnonymousChat(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
  );

  /// Add the mock anonymous chat to the fakeFirebase
  fakeFirebase
      .collection(Expert.COLLECTION)
      .doc(userId)
      .collection(mockAnonymousChat.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  group("AnonymousChat initialization", () {
    var anonymousChatTest = AnonymousChat();

    test("Anonymous chat collection", () {
      expect(anonymousChatTest.collection, AnonymousChat.COLLECTION);
    });

    test("Anonymous chat peer user collection", () {
      expect(anonymousChatTest.peerCollection, AnonymousChat.PEER_COLLECTION);
    });

    test("Anonymous chat notReadMessages initially set to 0", () {
      expect(anonymousChatTest.notReadMessages, 0);
    });
  });

  group("AnonymousChat data", () {
    test("Anonymous chat factory from document", () async {
      var result = (await fakeFirebase.collection(Expert.COLLECTION).doc(userId).collection(mockAnonymousChat.collection).doc(peerUser.id).get());
      var retrievedAnonymousChat = AnonymousChat.fromDocument(result);

      expect(retrievedAnonymousChat.lastMessage, lastMessage);
      expect(retrievedAnonymousChat.lastMessageDateTime, lastMessageDateTime);
      expect(retrievedAnonymousChat.notReadMessages, notReadMessages);
      expect(retrievedAnonymousChat.peerUser!.id, peerUser.id);
    });
  });
}
