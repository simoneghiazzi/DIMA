import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:sApport/Model/random_id.dart';
import 'package:sApport/Model/BaseUser/report.dart';
import 'package:sApport/Model/Services/firestore_service.dart';
import 'package:sApport/Model/Services/firebase_auth_service.dart';

class ReportViewModel extends FormBloc<String, String> {
  // Services
  final FirestoreService _firestoreService = GetIt.I<FirestoreService>();
  final FirebaseAuthService _firebaseAuthService = GetIt.I<FirebaseAuthService>();

  ReportViewModel() {
    // Add the field blocs to the create report form
    addFieldBlocs(fieldBlocs: [reportCategory, reportText]);
  }

  /// Define the report categories field bloc and add the required validator
  final reportCategory = SelectFieldBloc(
    items: [
      'Psychological violence',
      'Physical violence',
      'Threats',
      'Harassment',
    ],
    validators: [FieldBlocValidators.required],
  );

  /// Define the report text field bloc and add the required validator
  final reportText = TextFieldBloc(validators: [FieldBlocValidators.required]);

  /// Get the stream of reports from the DB
  Stream<QuerySnapshot> loadReports() {
    return _firestoreService.getReportsFromDB(_firebaseAuthService.userCredential.user.uid);
  }

  @override
  void onSubmitting() async {
    _firestoreService
        .addReportIntoDB(
          _firebaseAuthService.userCredential.user.uid,
          Report(
            id: RandomId.generate(idLength: 20),
            category: reportCategory.value,
            description: reportText.value,
            date: DateTime.now(),
          ),
        )
        .then((value) => emitSuccess(canSubmitAgain: true))
        .catchError((error) => emitFailure());
  }

  /// Clear all the text field blocs
  void clearControllers() {
    reportCategory.clear();
    reportText.clear();
  }
}
