import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class BaseUserSignUpForm extends FormBloc<String, String> {
  String email;

  BaseUserSignUpForm() {
    // Add the field blocs to the base user signup form
    addFieldBlocs(fieldBlocs: [nameText, surnameText, birthDate]);
  }

  /// Define the name text field bloc and add the required validator
  final nameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  /// Define the surname text field bloc and add the required validator
  final surnameText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  /// Define the birthdate field bloc and add the required and underage validators
  final birthDate = InputFieldBloc<DateTime, Object>(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.underage,
  ], initialValue: null);

  /// Get the data of the base user signup form as a key-value map
  Map<String, Object> get data {
    return {
      "name": nameText.value,
      "surname": surnameText.value,
      "birthDate": birthDate.value,
      "email": email,
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
