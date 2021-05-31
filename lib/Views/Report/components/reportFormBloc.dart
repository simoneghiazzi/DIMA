import 'package:flutter_form_bloc/flutter_form_bloc.dart';

class ReportFormBloc extends FormBloc<String, String> {
  final reportCategory = SelectFieldBloc(
    items: [
      'Psychological violence',
      'Physical violence',
      'Threats',
      'Harassment'
    ],
  );

  final reportText = TextFieldBloc();

  ReportFormBloc() {
    addFieldBlocs(fieldBlocs: [reportCategory, reportText]);
  }

  @override
  void onSubmitting() async {
    try {
      await Future<void>.delayed(Duration(milliseconds: 500));
      emitSuccess(canSubmitAgain: true);
    } catch (e) {
      emitFailure();
    }
  }
}
