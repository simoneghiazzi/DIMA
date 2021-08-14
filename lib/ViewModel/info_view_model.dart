import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'auth_view_model.dart';

class InfoViewModel extends FormBloc<String, String> {
  final AuthViewModel authViewModel;
  final BuildContext context;

  final nameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final surnameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final cityText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final birthDate = InputFieldBloc<DateTime, Object>(validators: [
    FieldBlocValidators.required,
  ]);

  InfoViewModel({@required this.authViewModel, @required this.context}) {
    addFieldBlocs(fieldBlocs: [nameText, surnameText, cityText, birthDate]);
  }

  @override
  void onSubmitting() async {
    try {
      await Future<void>.delayed(Duration(milliseconds: 500));
      emitSuccess();
    } catch (e) {
      emitFailure();
    }
  }
}
