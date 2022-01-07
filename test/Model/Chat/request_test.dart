import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Chat/request.dart';
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

  Request request = Request(
    lastMessage: lastMessage,
    lastMessageDateTime: lastMessageDateTime,
    notReadMessages: notReadMessages,
  );

  /// Add the request to the fakeFirebase
  fakeFirebase
      .collection(BaseUser.COLLECTION)
      .doc(userId)
      .collection(request.collection)
      .doc(peerUser.id)
      .set({"lastMessageTimestamp": lastMessageDateTime.millisecondsSinceEpoch, "notReadMessages": notReadMessages, "lastMessage": lastMessage});

  group("Request initialization", () {
    var requestTest = Request();

    test("Request collection", () {
      expect(requestTest.collection, Request.COLLECTION);
    });

    test("Request peer user collection", () {
      expect(requestTest.peerCollection, Request.PEER_COLLECTION);
    });

    test("Request notReadMessages initially set to 0", () {
      expect(requestTest.notReadMessages, 0);
    });
  });

  group("Request data", () {
    test("Request factory from document", () async {
      var result = (await fakeFirebase.collection(BaseUser.COLLECTION).doc(userId).collection(request.collection).doc(peerUser.id).get());
      var retrievedRequest = Request.fromDocument(result);

      expect(retrievedRequest.lastMessage, lastMessage);
      expect(retrievedRequest.lastMessageDateTime, lastMessageDateTime);
      expect(retrievedRequest.notReadMessages, notReadMessages);
      expect(retrievedRequest.peerUser!.id, peerUser.id);
    });
  });
}
