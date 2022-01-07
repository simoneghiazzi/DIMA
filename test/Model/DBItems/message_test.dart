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
    test("Message collection initially set to messages", () {
      expect(message.collection, Message.COLLECTION);
    });
  });

  group("Message data", () {
    test("Message factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(message.collection).doc(message.id).get());
      var retrievedDiaryPage = Message.fromDocument(result);
      expect(retrievedDiaryPage.idFrom, idFrom);
      expect(retrievedDiaryPage.idTo, idTo);
      expect(retrievedDiaryPage.timestamp, timestamp);
      expect(retrievedDiaryPage.content, content);
    });

    test("Check that message data returns a key-value map with the correct fields", () async {
      expect(message.data, {
        "idFrom": idFrom,
        "idTo": idTo,
        "timestamp": timestamp.millisecondsSinceEpoch,
        "content": content,
      });
    });
  });
}
