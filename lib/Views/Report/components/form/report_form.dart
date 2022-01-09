import 'dart:developer';

import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/ViewModel/BaseUser/report_view_model.dart';

class ReportForm extends FormBloc<String, String> {
  // View Model
  final ReportViewModel reportViewModel;

  ReportForm(this.reportViewModel) {
    // Add the field blocs to the create report form
    addFieldBlocs(fieldBlocs: [reportCategory, reportText]);
  }

  /// Define the report categories field bloc and add the required validator
  final reportCategory = SelectFieldBloc(
    items: [
      "Psychological violence",
      "Physical violence",
      "Threats",
      "Harassment",
    ],
    validators: [FieldBlocValidators.required],
  );

  /// Define the report text field bloc and add the required validator
  final reportText = TextFieldBloc(validators: [FieldBlocValidators.required]);

  @override
  void onSubmitting() async {
    reportViewModel.submitReport(reportCategory.value!, reportText.value.trim()).then((_) {
      reportCategory.clear();
      reportText.clear();
      emitSuccess(canSubmitAgain: true);
      log("Report correctly submitted");
    }).catchError((error) {
      emitFailure();
      log("Error in submitting the report");
    });
  }
}
