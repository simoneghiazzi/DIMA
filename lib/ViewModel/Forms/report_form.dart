import 'package:get_it/get_it.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Model/DBItems/BaseUser/report.dart';
import 'package:sApport/Model/Services/user_service.dart';
import 'package:sApport/Model/Services/firestore_service.dart';

class ReportForm extends FormBloc<String, String> {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final UserService _userService = GetIt.I<UserService>();

  ReportForm() {
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
    var now = DateTime.now();
    Report report = Report(
      id: now.millisecondsSinceEpoch.toString(),
      category: reportCategory.value,
      description: reportText.value,
      dateTime: now,
    );
    _firestoreService.addReportIntoDB(_userService.loggedUser.id, report).then((value) {
      reportCategory.clear();
      reportText.clear();
      emitSuccess(canSubmitAgain: true);
    }).catchError((error) {
      emitFailure();
    });
  }
}
