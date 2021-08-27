import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/random_id.dart';
import 'package:dima_colombo_ghiazzi/Model/BaseUser/report.dart';
import 'package:dima_colombo_ghiazzi/Model/Services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ReportViewModel extends FormBloc<String, String> {
  FirestoreService _firestoreService = FirestoreService();
  final String loggedId;

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

  ReportViewModel({@required this.loggedId}) {
    addFieldBlocs(fieldBlocs: [reportCategory, reportText]);
  }

  @override
  void onSubmitting() async {
    _firestoreService
        .addReportIntoDB(
            loggedId,
            Report(
                id: RandomId.generate(idLength: 20),
                category: reportCategory.value,
                description: reportText.value,
                date: DateTime.now()))
        .then((value) => emitSuccess(canSubmitAgain: true))
        .catchError((error) => emitFailure());
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
}
