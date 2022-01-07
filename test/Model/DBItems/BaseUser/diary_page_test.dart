import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/diary_page.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Test Fields
  var id = Utils.randomId();
  var title = "Diary page title";
  var content = "Diary page content";
  var dateTime = DateTime(2021, 10, 19);
  var favourite = true;

  DiaryPage diaryPage = DiaryPage(
    id: id,
    title: title,
    content: content,
    dateTime: dateTime,
    favourite: favourite,
  );

  /// Add the diary page to the fakeFirebase
  fakeFirebase.collection(diaryPage.collection).doc(diaryPage.id).set(diaryPage.data);

  group("DiaryPage initialization", () {
    var diaryPageTest = DiaryPage(dateTime: DateTime.now());

    test("Diary page collection initially set to diary", () {
      expect(diaryPageTest.collection, DiaryPage.COLLECTION);
    });

    test("Diary page favourite initially set to false", () {
      expect(diaryPageTest.favourite, false);
    });
  });

  group("DiaryPage data", () {
    test("Diary page factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(diaryPage.collection).doc(diaryPage.id).get());
      var retrievedDiaryPage = DiaryPage.fromDocument(result);
      expect(retrievedDiaryPage.id, id);
      expect(retrievedDiaryPage.title, title);
      expect(retrievedDiaryPage.content, content);
      expect(retrievedDiaryPage.dateTime, dateTime);
      expect(retrievedDiaryPage.favourite, favourite);
    });

    test("Check that diary page data returns a key-value map with the correct fields", () async {
      expect(diaryPage.data, {
        "id": id,
        "title": title,
        "content": content,
        "dateTime": dateTime,
        "favourite": favourite,
      });
    });
  });
}
