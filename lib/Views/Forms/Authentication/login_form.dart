import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Views/Forms/Authentication/forgot_password_form.dart';

class LoginForm extends ForgotPasswordForm {
  /// Define the surname text field bloc and add the required validator
  final passwordText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
  ]);

  LoginForm() {
    // Add the field blocs to the base user signup form
    addFieldBlocs(fieldBlocs: [emailText, passwordText]);
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
