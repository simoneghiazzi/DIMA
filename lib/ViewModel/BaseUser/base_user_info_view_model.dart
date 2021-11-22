import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class BaseUserInfoViewModel extends FormBloc<String, String> {
  String email;

  final nameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final surnameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  final birthDateTime = InputFieldBloc<DateTime, Object>(
    validators: [
      FieldBlocValidators.required,
      FieldBlocValidators.underage,
    ],
  );

  BaseUserInfoViewModel() {
    addFieldBlocs(fieldBlocs: [nameText, surnameText, birthDateTime]);
  }

  Map get values {
    return {
      'name': nameText.value,
      'surname': surnameText.value,
      'birthDate': birthDateTime.value,
      'email': email,
    };
  }

  @override
  void onSubmitting() async {
    try {
      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}
