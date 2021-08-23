import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ReportViewModel extends FormBloc<String, String> {
  final String loggedId;
  //The collection of users in the firestore DB
  final CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');

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
    reports
        .add({
          'uid': loggedId,
          'category': reportCategory.value,
          'description': reportText.value,
          'date': DateTime.now()
        })
        .then((value) => emitSuccess(canSubmitAgain: true))
        .catchError((error) => emitFailure());
  }
}
