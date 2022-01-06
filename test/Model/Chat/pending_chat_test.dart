import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/pending_chat.dart';
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

  PendingChat pendingChat = PendingChat(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
  );

  /// Add the pending chat to the fakeFirebase
  fakeFirebase
      .collection(BaseUser.COLLECTION)
      .doc(userId)
      .collection(pendingChat.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  group("PendingChat initialization", () {
    var pendingChatTest = PendingChat();

    test("Pending chat collection", () {
      expect(pendingChatTest.collection, PendingChat.COLLECTION);
    });

    test("Pending chat peer user collection", () {
      expect(pendingChatTest.peerCollection, PendingChat.PEER_COLLECTION);
    });

    test("Pending chat notReadMessages initially set to 0", () {
      expect(pendingChatTest.notReadMessages, 0);
    });
  });

  group("PendingChat data", () {
    test("Pending chat factory from document", () async {
      var result = (await fakeFirebase.collection(BaseUser.COLLECTION).doc(userId).collection(pendingChat.collection).doc(peerUser.id).get());
      var retrievedPendingChat = PendingChat.fromDocument(result);

      expect(retrievedPendingChat.lastMessage, lastMessage);
      expect(retrievedPendingChat.lastMessageDateTime, lastMessageDateTime);
      expect(retrievedPendingChat.notReadMessages, notReadMessages);
      expect(retrievedPendingChat.peerUser!.id, peerUser.id);
    });
  });
}
