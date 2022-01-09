import 'dart:collection';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/utils.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import '../../service.mocks.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirestoreService = MockFirestoreService();
  final mockUserService = MockUserService();

  var loggedUser = BaseUser(
    id: Utils.randomId(),
    name: "Luca",
    surname: "Colombo",
    email: "luca.colombo@prova.it",
    birthDate: DateTime(1997, 10, 19),
  );

  /// Add some mock reports to the fakeFirebase
  var collectionReference = fakeFirebase.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList");

  /// Test Reports
  var report = Report(
    id: DateTime(2021, 8, 5, 13, 00, 25).millisecondsSinceEpoch.toString(),
    category: "Report category",
    description: "Report description",
    dateTime: DateTime(2021, 8, 5, 13, 00, 25),
  );

  var report2 = Report(
    id: DateTime(2021, 10, 5, 13, 00, 25).millisecondsSinceEpoch.toString(),
    category: "Report category 2",
    description: "Report description 2",
    dateTime: DateTime(2021, 10, 5, 13, 00, 25),
  );

  var report3 = Report(
    id: DateTime(2022, 1, 5, 13, 00, 25).millisecondsSinceEpoch.toString(),
    category: "Report category 3",
    description: "Report description 3",
    dateTime: DateTime(2022, 1, 5, 13, 00, 25),
  );

  List<Report> reports = [report, report2, report3];

  collectionReference.doc(report.id).set(report.data);
  collectionReference.doc(report2.id).set(report2.data);
  collectionReference.doc(report3.id).set(report3.data);

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => loggedUser);

  /// Mock FirestoreService responses
  when(mockFirestoreService.getReportsFromDB(loggedUser.id))
      .thenAnswer((_) => fakeFirebase.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList").orderBy(FieldPath.documentId).get());

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<UserService>(mockUserService);

  final reportViewModel = ReportViewModel();
  var now = DateTime.now();

  group("ReportViewModel initialization:", () {
    test("Check that the current report is correctly initialized to the value notifier with null value", () {
      expect(reportViewModel.currentReport, isA<ValueNotifier<Report?>>());
      expect(reportViewModel.currentReport.value, isNull);
    });

    test("Check that the report list is correctly initialized with an empty HashMap", () {
      expect(reportViewModel.reports, isA<LinkedHashMap<String, Report>>());
      expect(reportViewModel.reports, isEmpty);
    });
  });

  group("ReportViewModel interaction with services:", () {
    setUp(() => clearInteractions(mockFirestoreService));
    group("Load reports:", () {
      setUp(() => reportViewModel.reports.clear());

      test("Check that the reports are correctly parsed and added to the linked HashMap of reports in the correct order", () async {
        /// Load the diary pages
        await reportViewModel.loadReports();

        for (int i = 0; i < reports.length; i++) {
          expect(reportViewModel.reports.values.elementAt(i).id, reports[i].id);
          expect(reportViewModel.reports.values.elementAt(i).category, reports[i].category);
          expect(reportViewModel.reports.values.elementAt(i).description, reports[i].description);
          expect(reportViewModel.reports.values.elementAt(i).dateTime, reports[i].dateTime);
        }
      });

      test("Check that if an error occurs when loading the reports it catches the error", () {
        /// Mock Firebase exception
        when(mockFirestoreService.getReportsFromDB(loggedUser.id)).thenThrow(Error);

        reportViewModel.loadReports();
      });
    });

    group("Submit report:", () {
      test("Check that submit report sets the current report with the correct values", () {
        /// Test Fields
        var category = "Category";
        var description = "Description";

        reportViewModel.submitReport(category, description);

        expect(reportViewModel.currentReport.value, isNotNull);
        expect(reportViewModel.currentReport.value!.category, category);
        expect(reportViewModel.currentReport.value!.description, description);
        expect(reportViewModel.currentReport.value!.dateTime!.day, now.day);
        expect(reportViewModel.currentReport.value!.dateTime!.month, now.month);
        expect(reportViewModel.currentReport.value!.dateTime!.year, now.year);
      });

      test("Submit report should call the submit report method of the firestore service", () {
        /// Test Fields
        var category = "Category";
        var description = "Description";

        reportViewModel.submitReport(category, description);

        var verification = verify(mockFirestoreService.addReportIntoDB(loggedUser.id, captureAny));
        verification.called(1);

        /// Parameter Verification
        expect(verification.captured[0].category, category);
        expect(verification.captured[0].description, description);
        expect(verification.captured[0].dateTime.day, now.day);
        expect(verification.captured[0].dateTime.month, now.month);
        expect(verification.captured[0].dateTime.year, now.year);
      });
    });
  });

  group("ReportViewModel internal managment:", () {
    group("Set current report:", () {
      test("Check that set current report sets the correct field of the value notifier", () {
        reportViewModel.resetCurrentReport();
        reportViewModel.setCurrentReport(report);

        expect(reportViewModel.currentReport.value, report);
      });
    });

    group("Reset current report:", () {
      test("Check that reset current report sets the field of the value notifier to null", () {
        reportViewModel.setCurrentReport(report);
        reportViewModel.resetCurrentReport();

        expect(reportViewModel.currentReport.value, isNull);
      });
    });

    group("Close listeners:", () {
      test("Close listeners should clear the old values of the report linked HashMap", () async {
        /// Mock FirestoreService responses
        when(mockFirestoreService.getReportsFromDB(loggedUser.id)).thenAnswer(
            (_) => fakeFirebase.collection(Report.COLLECTION).doc(loggedUser.id).collection("reportList").orderBy(FieldPath.documentId).get());
        await reportViewModel.loadReports();
        reportViewModel.closeListeners();

        expect(reportViewModel.reports, isEmpty);
      });

      test("Close listener should reset the current report", () {
        reportViewModel.currentReport.value = report;
        reportViewModel.closeListeners();

        expect(reportViewModel.currentReport.value, isNull);
      });
    });
  });
}
