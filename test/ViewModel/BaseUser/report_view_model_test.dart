import 'dart:collection';
import 'package:test/test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';
import '../../service.mocks.dart';
import '../../test_helper.dart';

void main() async {
  /// Fake Firebase
  final fakeFirebase = FakeFirebaseFirestore();

  /// Mock Services
  final mockFirestoreService = MockFirestoreService();
  final mockUserService = MockUserService();

  var getIt = GetIt.I;
  getIt.registerSingleton<FirestoreService>(mockFirestoreService);
  getIt.registerSingleton<UserService>(mockUserService);

  /// Test Helper
  final testHelper = TestHelper();
  await testHelper.attachDB(fakeFirebase);

  /// Mock User Service responses
  when(mockUserService.loggedUser).thenAnswer((_) => testHelper.loggedUser);

  /// Mock FirestoreService responses
  when(mockFirestoreService.getReportsFromDB(testHelper.loggedUser.id)).thenAnswer((_) => testHelper.reportsFuture);

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

      test("Load reports should call the getReports method of the firestore service", () async {
        await reportViewModel.loadReports();

        verify(mockFirestoreService.getReportsFromDB(testHelper.loggedUser.id)).called(1);
      });

      test("Check that the reports are correctly parsed and added to the linked HashMap of reports in the correct order", () async {
        /// Load the reports
        await reportViewModel.loadReports();

        for (int i = 0; i < testHelper.reports.length; i++) {
          expect(reportViewModel.reports.values.elementAt(i).id, testHelper.reports[i].id);
          expect(reportViewModel.reports.values.elementAt(i).category, testHelper.reports[i].category);
          expect(reportViewModel.reports.values.elementAt(i).description, testHelper.reports[i].description);
          expect(reportViewModel.reports.values.elementAt(i).dateTime, testHelper.reports[i].dateTime);
        }
      });

      test("Check that if an error occurs when loading the reports it catches the error", () async {
        /// Mock Firebase exception
        when(mockFirestoreService.getReportsFromDB(testHelper.loggedUser.id)).thenAnswer((_) async {
          return Future.error(Error);
        });

        await reportViewModel.loadReports();
      });
    });

    group("Submit report:", () {
      test("Check that submit report sets the current report with the correct values", () async {
        /// Test Fields
        var category = "Category";
        var description = "Description";

        await reportViewModel.submitReport(category, description);

        expect(reportViewModel.currentReport.value, isNotNull);
        expect(reportViewModel.currentReport.value!.category, category);
        expect(reportViewModel.currentReport.value!.description, description);
        expect(reportViewModel.currentReport.value!.dateTime!.day, now.day);
        expect(reportViewModel.currentReport.value!.dateTime!.month, now.month);
        expect(reportViewModel.currentReport.value!.dateTime!.year, now.year);
      });

      test("Submit report should call the submit report method of the firestore service", () async {
        /// Test Fields
        var category = "Category";
        var description = "Description";

        await reportViewModel.submitReport(category, description);

        var verification = verify(mockFirestoreService.addReportIntoDB(testHelper.loggedUser.id, captureAny));
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
        reportViewModel.setCurrentReport(testHelper.report);

        expect(reportViewModel.currentReport.value, testHelper.report);
      });
    });

    group("Reset current report:", () {
      test("Check that reset current report sets the field of the value notifier to null", () {
        reportViewModel.setCurrentReport(testHelper.report);
        reportViewModel.resetCurrentReport();

        expect(reportViewModel.currentReport.value, isNull);
      });
    });

    group("Reset view model:", () {
      test("Reset view model should clear the old values of the report linked HashMap", () async {
        await reportViewModel.loadReports();
        reportViewModel.resetViewModel();

        expect(reportViewModel.reports, isEmpty);
      });

      test("Reset view model should reset the current report", () {
        reportViewModel.currentReport.value = testHelper.report;
        reportViewModel.resetViewModel();

        expect(reportViewModel.currentReport.value, isNull);
      });
    });
  });
}
