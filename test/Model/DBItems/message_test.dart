import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/DBItems/message.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Test Fields
  var idFrom = "Random id 1";
  var idTo = "Random id 2";
  var timestamp = DateTime(2021, 10, 19, 21, 10, 50);
  var content = "Message content";

  Message message = Message(
    idFrom: idFrom,
    idTo: idTo,
    timestamp: timestamp,
    content: content,
  );

  /// Add the message into the fakeFirebase
  fakeFirebase.collection(message.collection).doc(message.id).set(message.data);

  group("Message initialization", () {
    test("Message collection", () {
      expect(message.collection, Message.COLLECTION);
    });
  });

  group("Message data", () {
    test("Message factory from document", () async {
      var result = (await fakeFirebase.collection(message.collection).doc(message.id).get());
      var retrievedDiaryPage = Message.fromDocument(result);
      expect(retrievedDiaryPage.idFrom, idFrom);
      expect(retrievedDiaryPage.idTo, idTo);
      expect(retrievedDiaryPage.timestamp, timestamp);
      expect(retrievedDiaryPage.content, content);
    });

    test("Get diary page data as a key-value map", () async {
      expect(message.data, {
        "idFrom": idFrom,
        "idTo": idTo,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "content": content,
      });
    });
  });
}
