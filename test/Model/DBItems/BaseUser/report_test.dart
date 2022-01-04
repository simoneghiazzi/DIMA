import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Fields
  var id = Utils.randomId();
  var category = "Report category";
  var description = "Report description";
  var dateTime = DateTime(2021, 10, 19);

  /// Mock Report
  Report mockReport = Report(
    id: id,
    category: category,
    description: description,
    dateTime: dateTime,
  );

  /// Add the mock report to the fakeFirebase
  fakeFirebase.collection(mockReport.collection).doc(mockReport.id).set(mockReport.data);

  group("Report initialization", () {
    test("Report collection", () {
      expect(mockReport.collection, Report.COLLECTION);
    });
  });

  group("Report data", () {
    test("Report factory from document", () async {
      var result = (await fakeFirebase.collection(mockReport.collection).doc(mockReport.id).get());
      var retrievedReport = Report.fromDocument(result);
      expect(retrievedReport.id, id);
      expect(retrievedReport.category, category);
      expect(retrievedReport.description, description);
      expect(retrievedReport.dateTime, dateTime);
    });

    test("Get report data as a key-value map", () async {
      expect(mockReport.data, {
        "id": id,
        "category": category,
        "description": description,
        "dateTime": dateTime,
      });
    });
  });
}
