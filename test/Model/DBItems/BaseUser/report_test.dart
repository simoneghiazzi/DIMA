import 'package:test/test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Test Fields
  var id = Utils.randomId();
  var category = "Report category";
  var description = "Report description";
  var dateTime = DateTime(2021, 10, 19);

  Report report = Report(
    id: id,
    category: category,
    description: description,
    dateTime: dateTime,
  );

  /// Add the report to the fakeFirebase
  fakeFirebase.collection(report.collection).doc(report.id).set(report.data);

  group("Report initialization", () {
    test("Report collection initially set to report", () {
      expect(report.collection, Report.COLLECTION);
    });
  });

  group("Report data", () {
    test("Report factory returns the instance with the fields retrived from the document snapshot correctly setted", () async {
      var result = (await fakeFirebase.collection(report.collection).doc(report.id).get());
      var retrievedReport = Report.fromDocument(result);
      expect(retrievedReport.id, id);
      expect(retrievedReport.category, category);
      expect(retrievedReport.description, description);
      expect(retrievedReport.dateTime, dateTime);
    });

    test("Check that report data returns a key-value map with the correct fields", () async {
      expect(report.data, {
        "id": id,
        "category": category,
        "description": description,
        "dateTime": dateTime,
      });
    });
  });
}
