import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ReportViewModel extends ChangeNotifier {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  Report? _currentReport;

  /// Get the stream of reports.
  Stream<QuerySnapshot>? loadReports() {
    try {
      return _firestoreService.getReportsFromDB(_userService.loggedUser!.id);
    } catch (e) {
      print("Failed to get the stream of reports: $e");
      return null;
    }
  }

  /// Set the [report] as the [_currentReport].
  void setCurrentReport(Report report) {
    _currentReport = report;
    print("Current report setted");
    notifyListeners();
  }

  /// Reset the [_currentReport].
  void resetCurrentReport() {
    _currentReport = null;
    print("Current report resetted");
  }

  /// Get the [_currentReport] instance.
  Report? get currentReport => _currentReport;
}
