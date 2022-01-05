import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/Forms/Authentication/login_form.dart';

class CredentialForm extends LoginForm {
  /// Define the name text field bloc and add the required validator
  final confirmPasswordText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  CredentialForm() {
    // Add the validators for the credential screen
    passwordText.addValidators([FieldBlocValidators.passwordMin6Chars]);
    confirmPasswordText.addValidators([FieldBlocValidators.confirmPassword(passwordText)]);

    // Add the field blocs to the base user signup form
    addFieldBlocs(fieldBlocs: [confirmPasswordText]);
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
