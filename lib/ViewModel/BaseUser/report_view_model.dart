import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ReportViewModel {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  // Current opened report of the user
  ValueNotifier<Report?> _currentReport = ValueNotifier(null);

  // List of the reports of the user saved as Linked Hash Map
  LinkedHashMap<String, Report> _reports = LinkedHashMap<String, Report>();

  /// Load the list of reports.
  Future<QuerySnapshot>? loadReports() {
    _firestoreService.getReportsFromDB(_userService.loggedUser!.id).then((snapshot) {
      for (var doc in snapshot.docs) {
        Report report = Report.fromDocument(doc);
        if (!_reports.containsKey(report.id)) {
          reports[report.id] = report;
        }
      }
    }).onError((error, stackTrace) {
      print("Failed to get the list of reports: $error");
    });
  }

  /// Set the [report] as the [_currentReport].
  void setCurrentReport(Report report) {
    _currentReport.value = report;
    print("Current report setted");
  }

  /// Reset the [_currentReport].
  void resetCurrentReport() {
    _currentReport.value = null;
    print("Current report resetted");
  }

  /// Cancel all the value listeners and clear their contents.
  void closeListeners() {
    _reports.clear();
    _currentReport = ValueNotifier(null);
    print("Report listeners closed");
  }

  /// Get the [_currentReport] instance.
  ValueNotifier<Report?> get currentReport => _currentReport;

  /// Get the [_reports] list of the user.
  /// 
  /// **The function [loadReports] must be called before getting
  /// the [reports].**
  LinkedHashMap<String, Report> get reports => _reports;
}
