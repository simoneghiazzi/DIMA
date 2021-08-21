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

  final birthDate = InputFieldBloc<DateTime, Object>(
      validators: [
        FieldBlocValidators.required,
      ],
      initialValue: new DateTime(
          DateTime.now().year - 18, DateTime.now().month, DateTime.now().day));

  InfoViewModel({@required this.authViewModel, @required this.context}) {
    addFieldBlocs(fieldBlocs: [nameText, surnameText, birthDate]);
  }

  @override
  void onSubmitting() async {
    try {
      emitSuccess();
    } catch (e) {
      emitFailure();
    }
  }
}
