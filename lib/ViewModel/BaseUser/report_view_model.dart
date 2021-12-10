import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sApport/Model/random_id.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:get_it/get_it.dart';

class ReportViewModel extends FormBloc<String, String> {
  FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  String loggedId;
  Report openedReport;
  var _isReportOpenController = StreamController<bool>.broadcast();
  var _infoReportOpenController = StreamController<Report>.broadcast();

  ReportViewModel() {
    addFieldBlocs(fieldBlocs: [reportCategory, reportText]);
  }
  
  final reportCategory = SelectFieldBloc(items: [
    'Psychological violence',
    'Physical violence',
    'Threats',
    'Harassment'
  ], validators: [
    FieldBlocValidators.required,
  ]);

  final reportText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  @override
  void onSubmitting() async {
    _firestoreService
        .addReportIntoDB(
          loggedId,
          Report(
            id: RandomId.generate(idLength: 20),
            category: reportCategory.value,
            description: reportText.value,
            date: DateTime.now(),
          ),
        )
        .then((value) => emitSuccess(canSubmitAgain: true))
        .catchError((error) => emitFailure());
  }

  void clearControllers() {
    reportCategory.clear();
    reportText.clear();
  }

  void openReport(Report report) {
    openedReport = report;
    _isReportOpenController.add(true);
    _infoReportOpenController.add(report);
  }

  void checkOpenReport() {
    if (openedReport != null) _isReportOpenController.add(true);
  }

  // Get all the reports of a user from the DB
  Stream<QuerySnapshot> loadReports() {
    try {
      return _firestoreService.getReportsFromDB(loggedId);
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<bool> get isReportOpen => _isReportOpenController.stream;
  Stream<Report> get infoReportOpen => _infoReportOpenController.stream;
}
