import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/DBItems/message.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Fields
  var idFrom = "Random id 1";
  var idTo = "Random id 2";
  var timestamp = DateTime(2021, 10, 19, 21, 10, 50);
  var content = "Message content";

  /// Mock Message
  Message mockMessage = Message(
    idFrom: idFrom,
    idTo: idTo,
    timestamp: timestamp,
    content: content,
  );

  /// Add the mock message into the fakeFirebase
  fakeFirebase.collection(mockMessage.collection).doc(mockMessage.id).set(mockMessage.data);

  group("Message initialization", () {
    test("Message collection", () {
      expect(mockMessage.collection, Message.COLLECTION);
    });
  });

  group("Message data", () {
    test("Message factory from document", () async {
      var result = (await fakeFirebase.collection(mockMessage.collection).doc(mockMessage.id).get());
      var retrievedDiaryPage = Message.fromDocument(result);
      expect(retrievedDiaryPage.idFrom, idFrom);
      expect(retrievedDiaryPage.idTo, idTo);
      expect(retrievedDiaryPage.timestamp, timestamp);
      expect(retrievedDiaryPage.content, content);
    });

    test("Get diary page data as a key-value map", () async {
      expect(mockMessage.data, {
        "idFrom": idFrom,
        "idTo": idTo,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "content": content,
      });
    });
  });
}
