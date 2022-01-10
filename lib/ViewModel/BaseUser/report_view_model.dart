import 'dart:async';
import 'dart:developer';
import 'dart:collection';
import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ReportViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Current opened report of the user
  ValueNotifier<Report?> _currentReport = ValueNotifier(null);

  // List of the reports of the user saved as Linked Hash Map
  LinkedHashMap<String, Report> _reports = LinkedHashMap<String, Report>();

  Future<void> submitReport(String category, String description) async {
    var now = DateTime.now();
    currentReport.value = Report(
      id: now.millisecondsSinceEpoch.toString(),
      category: category,
      description: description,
      dateTime: now,
    );
    return _firestoreService
        .addReportIntoDB(_userService.loggedUser!.id, currentReport.value!)
        .then((value) => log("Report added"))
        .catchError((error) => log("Failed to add the report: $error"));
  }

  /// Load the list of reports.
  Future<void> loadReports() async {
    return _firestoreService.getReportsFromDB(_userService.loggedUser!.id).then((snapshot) {
      for (var doc in snapshot.docs) {
        Report report = Report.fromDocument(doc);
        if (!_reports.containsKey(report.id)) {
          _reports[report.id] = report;
        }
      }
    }).catchError((error) {
      log("Failed to get the list of reports: $error");
    });
  }

  /// Set the [report] as the [_currentReport].
  void setCurrentReport(Report report) {
    _currentReport.value = report;
    log("Current report setted");
  }

  /// Reset the [_currentReport].
  void resetCurrentReport() {
    _currentReport.value = null;
    log("Current report resetted");
  }

  /// Cancel all the value listeners and clear their contents.
  void resetViewModel() {
    _reports.clear();
    _currentReport = ValueNotifier(null);
    log("Report listeners closed");
  }

  /// Get the [_currentReport] instance.
  ValueNotifier<Report?> get currentReport => _currentReport;

  /// Get the [_reports] list of the user.
  ///
  /// **The function [loadReports] must be called before getting
  /// the [reports].**
  LinkedHashMap<String, Report> get reports => _reports;
}
