import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_colombo_ghiazzi/Model/logged_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'auth_view_model.dart';

class ReportViewModel extends FormBloc<String, String> {
  final AuthViewModel authViewModel;
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

  ReportViewModel({@required this.authViewModel}) {
    addFieldBlocs(fieldBlocs: [reportCategory, reportText]);
  }

  @override
  void onSubmitting() async {
    LoggedUser loggedUser = await authViewModel.getUser();
    reports
        .add({
          'uid': loggedUser.uid,
          'category': reportCategory.value,
          'description': reportText.value,
          'date': DateTime.now()
        })
        .then((value) => emitSuccess(canSubmitAgain: true))
        .catchError((error) => emitFailure());
  }
}
