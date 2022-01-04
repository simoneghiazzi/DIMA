import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Fields
  var id = Utils.randomId();
  var title = "Diary page title";
  var content = "Diary page content";
  var dateTime = DateTime(2021, 10, 19);
  var favourite = true;

  /// Mock DiaryPage
  DiaryPage mockDiaryPage = DiaryPage(
    id: id,
    title: title,
    content: content,
    dateTime: dateTime,
    favourite: favourite,
  );

  /// Add the mock diary page to the fakeFirebase
  fakeFirebase.collection(mockDiaryPage.collection).doc(mockDiaryPage.id).set(mockDiaryPage.data);

  group("DiaryPage initialization", () {
    var testDiaryPage = DiaryPage(dateTime: DateTime.now());

    test("Diary page collection", () {
      expect(testDiaryPage.collection, DiaryPage.COLLECTION);
    });

    test("Diary page favourite initially set to false", () {
      expect(testDiaryPage.favourite, false);
    });
  });

  group("DiaryPage data", () {
    test("Diary page factory from document", () async {
      var result = (await fakeFirebase.collection(mockDiaryPage.collection).doc(mockDiaryPage.id).get());
      var retrievedDiaryPage = DiaryPage.fromDocument(result);
      expect(retrievedDiaryPage.id, id);
      expect(retrievedDiaryPage.title, title);
      expect(retrievedDiaryPage.content, content);
      expect(retrievedDiaryPage.dateTime, dateTime);
      expect(retrievedDiaryPage.favourite, favourite);
    });

    test("Get diary page data as a key-value map", () async {
      expect(mockDiaryPage.data, {
        "id": id,
        "title": title,
        "content": content,
        "dateTime": dateTime,
        "favourite": favourite,
      });
    });
  });
}
