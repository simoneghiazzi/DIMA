import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'authViewModel.dart';

class InfoViewModel extends FormBloc<String, String> {
  final AuthViewModel authViewModel;

  final nameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final surnameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final birthDate = InputFieldBloc<DateTime, dynamic>();

  InfoViewModel({@required this.authViewModel}) {
    addFieldBlocs(fieldBlocs: [nameText, surnameText, birthDate]);
  }

  @override
  void onSubmitting() {
    // TODO: implement onSubmitting
  }
}
