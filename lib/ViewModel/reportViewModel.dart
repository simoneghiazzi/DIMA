import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'AuthViewModel.dart';

class ReportViewModel extends FormBloc<String, String> {
  final AuthViewModel authViewModel;

  //ReportViewModel({Key key, @required this.authViewModel}) : super(key: key);

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

  //DA SETTARE LE AZIONI PER IL SALVATAGGIO DELLE INFO NEL DB
  //E GESTIRE LA COMUNICAZIONE AL BODY
  @override
  void onSubmitting() async {
    print(reportCategory.value);
    print(reportText.value);
    try {
      await Future<void>.delayed(Duration(milliseconds: 500));
      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}
