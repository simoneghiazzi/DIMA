import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ForgotPasswordForm extends FormBloc<String, String> {
  /// Define the name text field bloc and add the required validator
  final emailText = TextFieldBloc(validators: [
    FieldBlocValidators.required,
    FieldBlocValidators.email,
  ]);

  ForgotPasswordForm() {
    // Add the field blocs to the base user signup form
    addFieldBlocs(fieldBlocs: [emailText]);
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
