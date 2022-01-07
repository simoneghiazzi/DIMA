import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/expert_chat.dart';
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
  var peerUser = Expert(id: Utils.randomId());

  var lastMessage = "Last message test";
  var lastMessageDateTime = DateTime(2021, 10, 19, 21, 10, 50);
  var notReadMessages = 4;

  ExpertChat expertChat = ExpertChat(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
  );

  /// Add the expert chat to the fakeFirebase
  fakeFirebase
      .collection(BaseUser.COLLECTION)
      .doc(userId)
      .collection(expertChat.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  group("ExpertChat initialization", () {
    var expertChatTest = ExpertChat();

    test("Expert chat collection initially set to expertsChats", () {
      expect(expertChatTest.collection, ExpertChat.COLLECTION);
    });

    test("Expert chat peer user collection initially set to activeChats", () {
      expect(expertChatTest.peerCollection, ExpertChat.PEER_COLLECTION);
    });

    test("Expert chat notReadMessages initially set to 0", () {
      expect(expertChatTest.notReadMessages, 0);
    });
  });

  group("ExpertChat data", () {
    test("Expert chat factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(BaseUser.COLLECTION).doc(userId).collection(expertChat.collection).doc(peerUser.id).get());
      var retrievedExpertChat = ExpertChat.fromDocument(result);

      expect(retrievedExpertChat.lastMessage, lastMessage);
      expect(retrievedExpertChat.lastMessageDateTime, lastMessageDateTime);
      expect(retrievedExpertChat.notReadMessages, notReadMessages);
      expect(retrievedExpertChat.peerUser!.id, peerUser.id);
    });
  });
}
