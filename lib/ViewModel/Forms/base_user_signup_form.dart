import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Model/DBItems/BaseUser/base_user.dart';
import 'package:sApport/Model/DBItems/user.dart';

class BaseUserSignUpForm extends FormBloc<String, String> {
  late String email;

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
  ], initialValue: DateTime.now());

  /// Get the user from the data of the signup form.
  User get user {
    return BaseUser(
      name: nameText.value,
      surname: surnameText.value,
      birthDate: birthDate.value,
      email: email,
    );
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
